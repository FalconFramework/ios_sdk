//
//  SyncEngine+DataUpload.m
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine+DataUpload.h"
#import "SyncEngine+DataStore.h"
#import "SyncEngine+DataManagement.h"
#import "SyncEngineManagedObject.h"
#import "AFNetworking.h"
#import "CoreDataStack.h"
#import "AFParseAPIClient.h"
@implementation SyncEngine (DataUpload)
/**
 *  Disable remotelly all data disabled locally and after this, delete locally the disabled data
 */
- (void)disableCloudObjectsLocallyDeleted{
    NSMutableArray *operations = [NSMutableArray array];
    //
    // Iterate over all register classes to sync
    //
    for (NSString *className in self.registeredClassesToSync) {
        //
        // Fetch all objects from Core Data whose syncStatus is equal to ObjectDeleted
        //
        NSArray *objectsToDisable = [self managedObjectsForClass:className withSyncStatus:ObjectDeleted];
        
        //
        // Iterate over all fetched objects who syncStatus is equal to ObjectDeleted
        //
        for (SyncEngineManagedObject *objectToDisable in objectsToDisable) {
            
            NSString* objectToDisableCloudObjectId = objectToDisable.cloudObjectId;
            
            if (objectToDisableCloudObjectId != nil && [objectToDisableCloudObjectId length] > 0) {
                // Get the JSON representation of the NSManagedObject
                //
                NSDictionary *jsonString = [objectToDisable JSONToDisableObjectOnServer];
                //
                // Create a request using your PUT method with the JSON representation of the NSManagedObject
                //
                NSMutableURLRequest *request = [[AFParseAPIClient sharedClient] PUTRequestForClass:className parameters:jsonString forObjectId:objectToDisableCloudObjectId];
                
                AFHTTPRequestOperation *operation = [[AFParseAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //
                    // Set the completion block for the operation to DISABLE the NSManagedObject remotely, then delete locally.
                    //
                    NSLog(@"Success disable: %@", responseObject);
                    [[[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext] deleteObject:objectToDisable];
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    //
                    // Log an error if there was one, proper error handling should be done if necessary, in this case it may not
                    // be required to do anything as the object will attempt to sync again next time. There could be a possibility
                    // that the data was malformed, fields were missing, extra fields were present etc.
                    //
                    NSLog(@"Failed deletion: %@", operation.error);
                }];
                //
                // Add all operations to the operations NSArray
                //
                [operations addObject:operation];
            }else{
                
                [[[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext] deleteObject:objectToDisable];
            }
            
        }
        //
        
    }
    
    //
    // Pass off operations array to the sharedClient so that they are all executed
    //
    if (operations.count > 0) {
        NSArray *bactchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        } completionBlock:^(NSArray *operations) {
            NSLog(@"03 -> Delete Remotelly completed");
            // 2
            
            [[CoreDataStack sharedApplicationStack] saveBackgroundContext];
            [self postLocalObjectsOnCloud];
        }];
        
        [[NSOperationQueue mainQueue] addOperations:bactchOperations waitUntilFinished:NO];
    }else{
        [self postLocalObjectsOnCloud];
        
        
    }
}

/**
 *  Create remotelly the new objects created locally
 */
- (void)postLocalObjectsOnCloud {
    
    NSMutableDictionary* successCreatedObjectsClasses = [[NSMutableDictionary alloc] init];
    NSMutableArray *operations = [NSMutableArray array];
    //
    // Iterate over all register classes to sync
    //
    for (NSString *className in self.registeredClassesToSync) {
        
        NSMutableArray* successCreatedObjects = [[NSMutableArray alloc] init];
        
        //
        // Fetch all objects from Core Data whose syncStatus is equal to SDObjectCreated
        //
        NSArray *objectsToCreate = [self managedObjectsForClass:className withSyncStatus:ObjectCreated];
        //
        // Iterate over all fetched objects who syncStatus is equal to SDObjectCreated
        //
        for (SyncEngineManagedObject *objectToCreate in objectsToCreate) {
            //
            // Get the JSON representation of the NSManagedObject
            //
            NSDictionary *jsonString = [objectToCreate JSONToCreateObjectOnServer];
            //
            // Create a request using your POST method with the JSON representation of the NSManagedObject
            //
            NSMutableURLRequest *request = [[AFParseAPIClient sharedClient] POSTRequestForClass:className parameters:jsonString];
            
            AFHTTPRequestOperation *operation = [[AFParseAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //
                // Set the completion block for the operation to update the NSManagedObject with the createdDate from the
                // remote service and objectId, then set the syncStatus to SDObjectSynced so that the sync engine does not
                // attempt to create it again
                //
                NSLog(@"Success creation: %@", responseObject);
                NSDictionary *responseDictionary = responseObject;
                objectToCreate.cloudObjectId = [responseDictionary valueForKey:@"objectId"];
                [successCreatedObjects addObject:objectToCreate];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //
                // Log an error if there was one, proper error handling should be done if necessary, in this case it may not
                // be required to do anything as the object will attempt to sync again next time. There could be a possibility
                // that the data was malformed, fields were missing, extra fields were present etc.
                //
                NSLog(@"Failed creation: %@", operation.error);
            }];
            //
            // Add all operations to the operations NSArray
            //
            [operations addObject:operation];
        }
        
        [successCreatedObjectsClasses setValue:successCreatedObjects forKey:className];
        
    }
    
    //
    // Pass off operations array to the sharedClient so that they are all executed
    //
    if (operations.count > 0) {
        NSArray *bactchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        } completionBlock:^(NSArray *operations) {
            NSLog(@"04 -> Create Remotelly completed");
            // 2
            
            [[CoreDataStack sharedApplicationStack] saveBackgroundContext];
            [self pushCloudObjectsRelationsLocallyUpdated:successCreatedObjectsClasses];
        }];
        
        [[NSOperationQueue mainQueue] addOperations:bactchOperations waitUntilFinished:NO];
    }else{
        
        [self pushCloudObjectsRelationsLocallyUpdated:successCreatedObjectsClasses];
        
        
        
    }
    
    
}

/**
 *  Update remotelly all data pointer relations
 *
 *  @param objectsClassesToPush recent model objects created in the server, in nsdictionary format.
 */
- (void)pushCloudObjectsRelationsLocallyUpdated:(NSDictionary*)objectsClassesToPush{
    NSMutableArray *operations = [NSMutableArray array];
    //
    // Iterate over all created classes to sync the relations
    //
    for (NSString *className in [objectsClassesToPush allKeys]) {
        
        NSArray* objectsToPush = [objectsClassesToPush valueForKey:className];
        //
        // Iterate over all  objects who was recently created on the server
        //
        for (SyncEngineManagedObject *objectToPush in objectsToPush) {
            
            NSString* objectToPushCloudObjectId = objectToPush.cloudObjectId;
            
            if (objectToPushCloudObjectId != nil && [objectToPushCloudObjectId length] > 0) {
                // Get the JSON representation of the NSManagedObject pointer relation
                //
                NSDictionary *jsonString = [objectToPush JSONToCreateObjectRelationsOnServer];
                
                if (jsonString.count > 0) {
                    //
                    // Create a request using your PUT method with the JSON representation of the NSManagedObject
                    //
                    
                    NSMutableURLRequest *request = [[AFParseAPIClient sharedClient] PUTRequestForClass:className parameters:jsonString forObjectId:objectToPushCloudObjectId];
                    
                    AFHTTPRequestOperation *operation = [[AFParseAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                        //
                        // Set the completion block for the operation to Push the NSManagedObject remotely, then change its status locally.
                        //
                        NSLog(@"Success pushed relation: %@", responseObject);
                        objectToPush.syncStatus = [NSNumber numberWithInteger:ObjectSynced];
                        
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        //
                        // Log an error if there was one, proper error handling should be done if necessary, in this case it may not
                        // be required to do anything as the object will attempt to sync again next time. There could be a possibility
                        // that the data was malformed, fields were missing, extra fields were present etc.
                        NSLog(@"Failed pushe relation: %@", operation.error);
                    }];
                    //
                    // Add all operations to the operations NSArray
                    //
                    [operations addObject:operation];
                }
                
            }else{}
        }
    }
    
    
    //
    // Pass off operations array to the sharedClient so that they are all executed
    //
    if (operations.count > 0) {
        NSArray *bactchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
            NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
        } completionBlock:^(NSArray *operations) {
            NSLog(@"04 -> Create Remotelly completed");
            // 2
            
            [[CoreDataStack sharedApplicationStack] saveBackgroundContext];
            [self pushCloudObjectsLocallyUpdated];
        }];
        
        [[NSOperationQueue mainQueue] addOperations:bactchOperations waitUntilFinished:NO];
    }else{
        
        
        [self pushCloudObjectsLocallyUpdated];
        
        
    }
    
    
}


/**
 *  Push remotelly all data disabled locally and after this, delete locally the disabled data
 */
- (void)pushCloudObjectsLocallyUpdated{
    NSMutableArray *operations = [NSMutableArray array];
    //
    // Iterate over all register classes to sync
    //
    for (NSString *className in self.registeredClassesToSync) {
        //
        // Fetch all objects from Core Data whose syncStatus is equal to ObjectUpdated
        //
        NSArray *objectsToPush = [self managedObjectsForClass:className withSyncStatus:ObjectUpdated];
        
        //
        // Iterate over all fetched objects who syncStatus is equal to ObjectUpdated
        //
        for (SyncEngineManagedObject *objectToPush in objectsToPush) {
            
            NSString* objectToPushCloudObjectId = objectToPush.cloudObjectId;
            
            if (objectToPushCloudObjectId != nil && [objectToPushCloudObjectId length] > 0) {
                // Get the JSON representation of the NSManagedObject
                //
                NSDictionary *jsonString = [objectToPush JSONToCreateObjectOnServer];
                //
                // Create a request using your PUT method with the JSON representation of the NSManagedObject
                //
                NSMutableURLRequest *request = [[AFParseAPIClient sharedClient] PUTRequestForClass:className parameters:jsonString forObjectId:objectToPushCloudObjectId];
                
                AFHTTPRequestOperation *operation = [[AFParseAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    //
                    // Set the completion block for the operation to Push the NSManagedObject remotely, then change its status locally.
                    //
                    NSLog(@"Success push object: %@", responseObject);
                    objectToPush.syncStatus = [NSNumber numberWithInteger:ObjectSynced];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    //
                    // Log an error if there was one, proper error handling should be done if necessary, in this case it may not
                    // be required to do anything as the object will attempt to sync again next time. There could be a possibility
                    // that the data was malformed, fields were missing, extra fields were present etc... so it is a good idea to
                    // determine the best error handling approach for your production applications.
                    //
                    NSLog(@"Failed push object: %@", operation.error);
                }];
                //
                // Add all operations to the operations NSArray
                //
                [operations addObject:operation];
            }else{}
        }
        
    }
    
    //
    // Pass off operations array to the sharedClient so that they are all executed
    //
    
    NSArray *bactchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"05 -> Update Remotelly completed");
        // 2
        
        [[CoreDataStack sharedApplicationStack] saveBackgroundContext];
        [self executeSyncCompletedOperations];
    }];
    
    [[NSOperationQueue mainQueue] addOperations:bactchOperations waitUntilFinished:NO];
    
}





@end
