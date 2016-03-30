//
//  SyncEngineManagedObject.m
//  OnFit
//
//  Created by Thiago-Bernardes on 1/17/16.
//  Copyright © 2016 OnfFit. All rights reserved.
//

#import "SyncEngineManagedObject.h"
#import "OnFit-Bridging-Header.h"

@implementation SyncEngineManagedObject

@dynamic active;
@dynamic cloudObjectId;
@dynamic updatedAt;
@dynamic syncStatus;
@synthesize isRecentDownloadedData;

-(void)willSave{
    
    NSDate *now = [NSDate date];
    if (self.updatedAt == nil || [now timeIntervalSinceDate:self.updatedAt] > 1.0) {
        
        if ( self.syncStatus.integerValue == ObjectSynced ||
            self.syncStatus.integerValue  == ObjectUpdated) {
            
            if (!self.isRecentDownloadedData) {
                
                
                NSMutableArray* changedValuesNames = [NSMutableArray arrayWithArray:[[self changedValues] allKeys]];
                
                [changedValuesNames filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString* evaluatedObject, NSDictionary *bindings) {
                    BOOL isNotSyncEngineProperty = ![evaluatedObject isEqualToString:@"syncStatus"] && ![evaluatedObject isEqualToString:@"cloudObjectId"] && ![evaluatedObject isEqualToString:@"updatedAt"];
                    BOOL isNotRelationshipProperty = ![[[self.entity relationshipsByName] allKeys] containsObject:evaluatedObject];
                    
                    BOOL isValidChangedValue = isNotRelationshipProperty && isNotSyncEngineProperty;
                    
                    return isValidChangedValue;
                }]];
                
                
                BOOL hasUpdates = [changedValuesNames count] > 0 ? YES : NO;
                if (hasUpdates){
                    self.syncStatus = [NSNumber numberWithInt:ObjectUpdated];
                    
                }else{
                    self.syncStatus = [NSNumber numberWithInt:ObjectSynced];
                }
            }
        }
        else
            if (self.syncStatus.integerValue == ObjectCreated ||
                self.syncStatus == nil){
                
                self.syncStatus = [NSNumber numberWithInt:ObjectCreated];
            }
        
        self.updatedAt = now;
        
        
    }
    
}

-(void)didSave{
    [super didSave];
    self.isRecentDownloadedData = NO;
}

-(void)delete{
    
    if ([PFUser currentUser] != nil){
        self.syncStatus = [NSNumber numberWithInt:ObjectDeleted];
    }else{
        if (![self isDeleted]){
            [[[CoreDataStack sharedApplicationStack] contextCoreData] deleteObject:self];
        }
    }
    NSDictionary* relations =  [self.entity relationshipsByName];
    
    for (id key in relations) {
        
        if (![key isEqualToString:@"owner"] && ![key containsString:@"owner"]) {
            
            
            NSRelationshipDescription* currentRelation = relations[key];
            
            if (currentRelation.toMany) {
                
                NSMutableSet* set = [self valueForKey:currentRelation.name];
                
                for (SyncEngineManagedObject* managedObject in set) {
                    [managedObject delete];
                }
                
            }else{
                SyncEngineManagedObject* relationObject = [self valueForKey:currentRelation.name];
                [relationObject delete];
            }
        }
    }
    
}

/**
 *  Convert the NSManagedObject into a JSON.
 *  @return A dictionary representing the json.
 */
- (NSDictionary *)JSONToCreateObjectOnServer {
    
    NSMutableDictionary* jsonObject = [[NSMutableDictionary alloc] init];
    NSArray* entityAttributesNames = [[[self entity] attributesByName] allKeys];
    
    for (NSString* attributeName in entityAttributesNames) {
        
        if (![attributeName isEqual: @"updatedAt"] &&
            ![attributeName  isEqual: @"syncStatus"] &&
            ![attributeName  isEqual: @"cloudObjectId"]){
            
            id attributeValue = [self valueForKey:attributeName];
            if (attributeValue != nil) {
                
                NSAttributeType attributeType = [[[[self entity] attributesByName] valueForKey:attributeName] attributeType];
                switch (attributeType) {
                        
                    case NSInteger16AttributeType:
                    case NSInteger32AttributeType:
                    case NSInteger64AttributeType:
                    case NSDecimalAttributeType:
                    case NSDoubleAttributeType:
                    case NSFloatAttributeType: {
                        [jsonObject setValue:@([attributeValue floatValue]) forKey:attributeName];
                        break;
                    }
                    case NSBooleanAttributeType: {
                        [jsonObject setValue: ([attributeValue boolValue] ? @YES : @NO) forKey:attributeName];
                        break;
                    }
                    case NSStringAttributeType: {
                        [jsonObject setValue:attributeValue forKey:attributeName];
                        break;
                    }
                    case NSDateAttributeType: {
                        NSDictionary *dateAttribute = [[SyncEngine sharedEngine] dateDictForAPIUsingDate:attributeValue];
                        [jsonObject setValue:dateAttribute forKey:attributeName];
                        break;
                    }
                    case NSBinaryDataAttributeType: {
                        //format photos
                        break;
                    }
                    case NSTransformableAttributeType:
                    case NSObjectIDAttributeType:
                    case NSUndefinedAttributeType: {
                        break;
                    }
                }
            }
        }
    }
    
    NSDictionary* userAccess = @{@"read" : @YES, @"write" : @YES};
    NSDictionary* acl = @{ [[PFUser currentUser] objectId] : userAccess};
    [jsonObject setValue:acl forKey:@"ACL"];
    
    
    
#warning TODO: photo and achievements
    
    return jsonObject;
}


/**
 *  Convert the NSManagedObject pointer relation into a JSON.
 *  @return A dictionary representing the json.
 */
- (NSDictionary *)JSONToCreateObjectRelationsOnServer {
    
    NSDictionary *jsonDictionary = [[NSDictionary alloc] init];
    
    NSDictionary* relations =  [self.entity relationshipsByName];
    NSRelationshipDescription* ownerRelation = relations[@"owner"];
    if (ownerRelation != nil) {
        
        SyncEngineManagedObject* owner = [self valueForKey:ownerRelation.name];
        NSString* className = ![ [[owner class] description] isEqual: @"User"] ? [[owner class] description] : @"_User";
        
        
        NSString* ownerCloudObjectId = owner.cloudObjectId;
        if([className isEqual:@"_User"]){
            if (ownerCloudObjectId == nil) {
                ownerCloudObjectId = [[PFUser currentUser] objectId];
            }
        }
        NSDictionary *ownerDictionary = [[SyncEngine sharedEngine] pointerObjectDictForAPIUsingObjectId:ownerCloudObjectId andClassName:className];
        jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                          ownerDictionary, @"owner",
                          nil];
        
    }
    
    
    
    return jsonDictionary;
}


/**
 *  Create a JSON that represents a deleted NSManagedObject
 *
 *  @return A dictionary representing the json of a deleted NSManagedObject.
 */
-(NSDictionary *)JSONToDisableObjectOnServer{
    
    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @NO,@"active",
                                    nil];
    
    
    
    return jsonDictionary;
    
    
}


@end
