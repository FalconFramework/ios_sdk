//
//  SyncEngine+DataStore.m
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine+DataStore.h"

#import "CoreDataStack.h"
#import "SyncEngine+DataManagement.h"
#import "SyncEngine+DataDownload.h"
#import "SyncEngine+DataUpload.h"
#import "SyncEngineManagedObject.h"

@implementation SyncEngine (DataStore)


#pragma mark - Process Json Data into Local Object
/**
 *  Get the cached data of the objects that need to be deleted and delete them locally
 *
 */
//Delete local objects deleted on the server
- (void)processJSONDataRecordsForDeletion {
    NSManagedObjectContext *managedObjectContext = [[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext];
    //
    // Iterate over all registered classes to sync
    //
    
    for (NSString *className in self.registeredClassesToSync) {
        //
        // Retrieve the JSON response records from disk
        //
        NSArray *JSONRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
        if ([JSONRecords count] > 0) {
            //
            // If there are any records fetch all locally stored records that are NOT in the list of downloaded records
            //
            NSArray *storedRecords = [self
                                      managedObjectsForClass:className
                                      sortedByKey:@"cloudObjectId"
                                      usingArrayOfIds:[JSONRecords valueForKey:@"objectId"]
                                      inArrayOfIds:YES];
            
            //
            // Schedule the NSManagedObject for deletion and save the context
            //
            [managedObjectContext performBlockAndWait:^{
                for (NSManagedObject *managedObject in storedRecords) {
                    [managedObjectContext deleteObject:managedObject];
                }
                NSError *error = nil;
                BOOL saved = [managedObjectContext save:&error];
                if (!saved) {
                    NSLog(@"Unable to save context after deleting records for class %@ because %@", className, error);
                }
            }];
            
            
        }
        
        [[CoreDataStack sharedApplicationStack] saveBackgroundContext];
        //
        // Delete all JSON Record response files to clean up after yourself
        //
        [self clearJSONDataRecordsForClassWithName:className];
    }
    
    //
    // Download data of objects that need to be updated localy
    //
    [self downloadRecentUpdatedRemoteData:YES];
    
}

/**
 *  Get the cached data of the objects that neeed to be updated and update them locally
 */
- (void)processJSONDataRecordsIntoCoreData {
    //
    // Iterate over all registered classes to sync
    //
    
    for (NSString *registeredClassName in self.registeredClassesToSync) {
        
        NSString* className = registeredClassName;
        
        
        if (![self initialSyncComplete]) {
            //
            // If this is the initial sync then the logic is pretty simple, you will fetch the JSON data from disk
            // for the class of the current iteration and create new NSManagedObjects for each record
            //
            
            
            // import all downloaded data to Core Data for initial sync
            NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
            NSArray *records = [JSONDictionary objectForKey:@"results"];
            for (NSDictionary *record in records) {
                if ([className isEqualToString:@"User"]) {
                    
                    NSManagedObjectContext *managedObjectContext = [[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext];
                    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
                    [managedObjectContext performBlockAndWait:^{
                        NSError *error = nil;
                        NSArray *currentObjects = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                        SyncEngineManagedObject* object = [currentObjects lastObject];
                        [self updateManagedObject:object withRecord:record];
                    }];
                    
                }else{
                    
                    [self newManagedObjectWithClassName:className forRecord:record];
                }
            }
            
        } else {
            //
            // Otherwise you need to do some more logic to determine if the record is new or has been updated.
            // First get the downloaded records from the JSON response, verify there is at least one object in
            // the data, and then fetch all records stored in Core Data whose objectId matches those from the JSON response.
            //
            NSString* className = registeredClassName;
            NSArray *downloadedRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
            if ([downloadedRecords lastObject]) {
                //
                // Now you have a set of objects from the remote service and all of the matching objects
                // (based on objectId) from your Core Data store. Iterate over all of the downloaded records
                // from the remote service.
                //
                NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"cloudObjectId" usingArrayOfIds:[downloadedRecords valueForKey:@"objectId"] inArrayOfIds:YES];
                int currentIndex = 0;
                //
                // If the number of records in your Core Data store is less than the currentIndex, you know that
                // you have a potential match between the downloaded records and stored records because you sorted
                // both lists by objectId, this means that an update has come in from the remote service
                //
                for (NSDictionary *record in downloadedRecords) {
                    NSManagedObject *storedManagedObject = nil;
                    
                    // Make sure we don't access an index that is out of bounds as we are iterating over both collections together
                    if ([storedRecords count] > currentIndex) {
                        storedManagedObject = [storedRecords objectAtIndex:currentIndex];
                    }
                    
                    if ([className isEqualToString:@"User"]) {
                        
                        NSManagedObjectContext *managedObjectContext = [[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext];
                        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
                        [managedObjectContext performBlockAndWait:^{
                            NSError *error = nil;
                            NSArray *currentUser = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
                            [self updateManagedObject:[currentUser lastObject] withRecord:record];
                        }];
                        
                    }else{
                        if ([[storedManagedObject valueForKey:@"cloudObjectId"] isEqualToString:[record valueForKey:@"objectId"]]) {
                            //
                            // Do a quick spot check to validate the objectIds in fact do match, if they do update the stored
                            // object with the values received from the remote service
                            //
                            
                            [self updateManagedObject:[storedRecords objectAtIndex:currentIndex] withRecord:record];
                        } else {
                            
                            //
                            // Otherwise you have a new object coming in from your remote service so create a new
                            // NSManagedObject to represent this remote object locally
                            //
                            
                            [self newManagedObjectWithClassName:className forRecord:record];
                            
                        }
                    }
                    currentIndex++;
                }
            }
        }
        //
        // Once all NSManagedObjects are created in your context you can save the context to persist the objects
        // to your persistent store. In this case though you used an NSManagedObjectContext who has a parent context
        // so all changes will be pushed to the parent context
        //
        [[CoreDataStack sharedApplicationStack] saveBackgroundContext];
        
        
    }
    
    [self processJSONDataRecordsRelationsIntoCoreData];
    
    
}

/**
 *  After update or create the data locally, make the relations between their modeles of accord by the downloaded data
 */
- (void)processJSONDataRecordsRelationsIntoCoreData {
    
    //
    // Iterate over all registered classes to sync
    //
    for (NSString *registeredClassName in self.registeredClassesToSync) {
        
        NSString* className = registeredClassName;
        
        //
        // Otherwise you need to do some more logic to determine if the record is new or has been updated.
        // First get the downloaded records from the JSON response, verify there is at least one object in
        // the data, and then fetch all records stored in Core Data whose objectId matches those from the JSON response.
        //
        NSArray *downloadedRecords = [self JSONDataRecordsForClass:className sortedByKey:@"objectId"];
        if ([downloadedRecords lastObject]) {
            //
            // Now you have a set of objects from the remote service and all of the matching objects
            // (based on objectId) from your Core Data store. Iterate over all of the downloaded records
            // from the remote service.
            //
            NSArray *storedRecords = [self managedObjectsForClass:className sortedByKey:@"cloudObjectId" usingArrayOfIds:[downloadedRecords valueForKey:@"objectId"] inArrayOfIds:YES];
            int currentIndex = 0;
            //
            // If the number of records in your Core Data store is less than the currentIndex, you know that
            // you have a potential match between the downloaded records and stored records because you sorted
            // both lists by objectId, this means that an update has come in from the remote service
            //
            for (NSDictionary *record in downloadedRecords) {
                NSManagedObject *storedManagedObject = nil;
                
                // Make sure we don't access an index that is out of bounds as we are iterating over both collections together
                if ([storedRecords count] > currentIndex) {
                    storedManagedObject = [storedRecords objectAtIndex:currentIndex];
                }
                [self updateManagedObjectRelations:[storedRecords objectAtIndex:currentIndex] withRecord:record];
                currentIndex++;
            }
        }
        
        [[CoreDataStack sharedApplicationStack] saveBackgroundContext];
        
        [self clearJSONDataRecordsForClassWithName:className];
        
    }
    [self disableCloudObjectsLocallyDeleted];
    
}

#pragma mark - Manage NSManagedObjects


/**
 *  Set an value in a property of a NSManagedObject of core data
 *
 *  @param value         Value to be set
 *  @param key           Key that represents the property to be changed
 *  @param managedObject The managed object that will be updated
 */
- (void)setValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
    
    
    if ([key isEqualToString:@"updatedAt"]) {
        
        NSDate *date = [self dateUsingStringFromAPI:value];
        [managedObject setValue:date forKey:key];
        
    }else if([key isEqualToString:@"objectId"]){
        
        [managedObject setValue:value forKey:@"cloudObjectId"];
        
    }else if ([value isKindOfClass:[NSDictionary class]]) {
        
        if ([value objectForKey:@"__type"]) {
            
            NSString *dataType = [value objectForKey:@"__type"];
            
            if ([dataType isEqualToString:@"Date"]) {
                
                NSString *dateString = [value objectForKey:@"iso"];
                NSDate *date = [self dateUsingStringFromAPI:dateString];
                [managedObject setValue:date forKey:key];
                
            }else if ([dataType isEqualToString:@"File"]) {
                
                NSString *urlString = [value objectForKey:@"url"];
//                NSURL *url = [NSURL URLWithString:urlString];
//                NSURLRequest *request = [NSURLRequest requestWithURL:url];
//                NSURLResponse *response = nil;
//                NSError *error = nil;
                
                NSURLSession *session = [NSURLSession sharedSession];
                [[session dataTaskWithURL:[NSURL URLWithString:urlString]
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *error) {
                            // handle response
                            [managedObject setValue:data forKey:key];

                        }] resume];
                
//                [NSURLConnection ]
//                NSData *dataResponse = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
                
            }else{
                NSLog(@"Unknown Data Type Received : %@", dataType );
            }
        }
    }else if([key isEqualToString:@"createdAt"] || [key isEqualToString:@"email"] || [key isEqualToString:@"username"] || [key isEqualToString:@"sessionToken"]){
        
    }else {
        
        
        [managedObject setValue:value forKey:key];
    }
}

/**
 *  Set the relation property for an ManagedObject
 *
 *  @param value         Value to be set, generally is a dictionary with keys _type & Pointer
 *  @param key           Relation property name in the model
 *  @param managedObject ManagedObject of the model to be updated
 */
- (void)setRelationValue:(id)value forKey:(NSString *)key forManagedObject:(NSManagedObject *)managedObject {
    
    
    NSString *dataType = [value objectForKey:@"__type"];
    
    if ([dataType isEqualToString:@"Pointer"]) {
        
        //SET  RELATION . Eg: dailyCharacter.owner is equal a User, retrieve this user object and set them in this property.
        
        NSString* relationedClassName = [value valueForKey:@"className"];
        NSString* relationedObjectId = [value valueForKey:@"objectId"];
        
        if ([relationedClassName isEqualToString:@"_User"]){
            relationedClassName = @"User";
        }
        
        NSFetchRequest *relationedObjectFetchRequest = [NSFetchRequest fetchRequestWithEntityName:relationedClassName];
        NSString* relationedObjectRequestPredicate = [NSString stringWithFormat:@"cloudObjectId == \"%@\"", relationedObjectId];
        relationedObjectFetchRequest.predicate = [NSPredicate predicateWithFormat:relationedObjectRequestPredicate];
        
        NSManagedObjectContext *managedObjectContext = [[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext];
        NSError *error = nil;
        
        //Fetch the parent object and de child object. Eg: (Parent = DailyCharacter, Child = DailyMenu, RelationName = currentMenu). Here i set the DailyCharacter.currentMenu as the child with downloaded id
        NSArray *relationedObjectResult = [managedObjectContext executeFetchRequest:relationedObjectFetchRequest error:&error];
        
        NSManagedObject *relationedObject = [relationedObjectResult lastObject];
        [managedObject setValue:relationedObject forKey:key];
    }else{
        NSLog(@"Unknown Data Type Received");
    }
}

/**
 *  Iterate the properties of the download object and save their values in the correspondent object locally
 *
 *  @param managedObject ManagedObject stored localy
 *  @param record        Downloaded object
 */
- (void)updateManagedObject:(SyncEngineManagedObject*)managedObject withRecord:(NSDictionary*)record{
    
    managedObject.isRecentDownloadedData = YES;
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self setValue:obj forKey:key forManagedObject:managedObject];
    }];
    
}

/**
 *  Iterate the properties of the download object and save their relations in the correspondent object locally
 *
 *  @param managedObject ManagedObject stored localy
 *  @param record        Downloaded object
 */
- (void)updateManagedObjectRelations:(SyncEngineManagedObject*)managedObject withRecord:(NSDictionary*)record{
    
    managedObject.isRecentDownloadedData = YES;
    [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            if ([obj valueForKey:@"__type"] != nil) {
                if ([[obj valueForKey:@"__type"] isEqualToString:@"Pointer"]) {
                    [self setRelationValue:obj forKey:key forManagedObject:managedObject];
                }
            }
        }
    }];
    
}

/**
 *  Iterate the properties of the download object and save their values in the correspondent object locally
 *
 *  @param className Model name to be created localy
 *  @param record        Downloaded object
 */
- (void)newManagedObjectWithClassName:(NSString *)className forRecord:(NSDictionary *)record {
    SyncEngineManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:[[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext]];
    [record setValue:[NSNumber numberWithInt:ObjectSynced] forKey:@"syncStatus"];
    
    [self updateManagedObject:newManagedObject withRecord:record];
    
    
}


#pragma mark - Get managed objects


/**
 *  Get all local data with a determined sync status
 *
 *  @param className  Entity name to be fetched
 *  @param syncStatus Sync status to filter the fetch request
 *
 *  @return Array with the local objects filtered by a sync status
 */
- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(ObjectSyncStatus)syncStatus {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncStatus = %d", syncStatus];
    [fetchRequest setPredicate:predicate];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

/**
 *  Get local objects sorted by an determined property, and that contains any id of the passed array.
 *
 *  @param className Entity name to be fetched
 *  @param key       Property to sort the fetch request
 *  @param idArray   Cloud objectIds that can be fetched locally
 *  @param inIds     If need to use the filter of the ids in the array
 *
 *  @return Array with the objects fetched with the filter
 */
- (NSArray *)managedObjectsForClass:(NSString *)className sortedByKey:(NSString *)key usingArrayOfIds:(NSArray *)idArray inArrayOfIds:(BOOL)inIds {
    __block NSArray *results = nil;
    NSManagedObjectContext *managedObjectContext = [[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:className];
    NSPredicate *predicate;
    if (inIds) {
        predicate = [NSPredicate predicateWithFormat:@"cloudObjectId IN %@", idArray];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"NOT (cloudObjectId IN %@)", idArray];
    }
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:
                                      [NSSortDescriptor sortDescriptorWithKey:@"cloudObjectId" ascending:YES]]];
    [managedObjectContext performBlockAndWait:^{
        NSError *error = nil;
        results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    }];
    
    return results;
}

-(void)deleteAllSyncedData{
    for (NSString* className in self.registeredClassesToSync) {
        
        if (![className isEqual:@"User"]) {
            
            NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:className];
            NSDate* databaseInitialDate = [[NSDate alloc] initWithTimeIntervalSinceReferenceDate:473300000];
            [request setPredicate:[NSPredicate predicateWithFormat:@"updatedAt > %@",databaseInitialDate]];
            NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
            NSError *deleteError = nil;
            
            [[[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext] executeRequest:delete error:&deleteError];
            
        }
    }
    
}

@end
