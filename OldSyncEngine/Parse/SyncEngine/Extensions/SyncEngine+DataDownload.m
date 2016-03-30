//
//  SyncEngine+DataDownload.m
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine+DataDownload.h"

#import "AFParseAPIClient.h"
#import "SyncEngine+DataManagement.h"
#import "AFHTTPRequestOperation.h"
#import "SyncEngine+DataStore.h"
#import "CoreDataStack.h"


@implementation SyncEngine (DataDownload)


/**
 * Get the recent disabled objects remotelly and delet them locally
 */
- (void)downloadRecentRemoteDisabledObjects{
    
    NSMutableArray *operations = [NSMutableArray array];
    for (NSString *className in self.registeredClassesToSync) {
        NSDate *mostRecentUpdatedDate = nil;
        if ([self initialSyncComplete]) {
            mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
        }
        NSMutableURLRequest *request = [[AFParseAPIClient sharedClient]
                                        GETRequestForAllRecordsOfClass:className updatedAfterDate:mostRecentUpdatedDate activeObjects:false];
        AFHTTPRequestOperation *operation = [[AFParseAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self writeJSONResponse:responseObject toDiskForClassWithName:className];
                // Write JSON files to disk
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Request for class %@ failed with error: %@", className, error);
        }];
        
        [operations addObject:operation];
    }
    
    NSArray *bactchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"01 -> Disable objects complet ");
        // 2
        // Need to process JSON records into Core Data
        [self processJSONDataRecordsForDeletion];
        
    }];
    
    [[NSOperationQueue mainQueue] addOperations:bactchOperations waitUntilFinished:NO];
}




/**
 *  Get the recent remote updated objects and update them locally
 *
 *  @param useUpdatedAtDate flag that determin if want to download all objects or just the objects updated after a last change date
 */
- (void)downloadRecentUpdatedRemoteData:(BOOL)useUpdatedAtDate{
    NSMutableArray *operations = [NSMutableArray array];
    for (NSString *className in self.registeredClassesToSync) {
        NSDate *mostRecentUpdatedDate = nil;
        if (useUpdatedAtDate  && [self initialSyncComplete]) {
            mostRecentUpdatedDate = [self mostRecentUpdatedAtDateForEntityWithName:className];
        }
        NSMutableURLRequest *request = [[AFParseAPIClient sharedClient]
                                        GETRequestForAllRecordsOfClass:className updatedAfterDate:mostRecentUpdatedDate activeObjects:true];
        AFHTTPRequestOperation *operation = [[AFParseAPIClient sharedClient] HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                [self writeJSONResponse:responseObject toDiskForClassWithName:className];
                // Write JSON files to disk
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Request for class %@ failed with error: %@", className, error);
        }];
        
        [operations addObject:operation];
    }
    
    NSArray *bactchOperations = [AFURLConnectionOperation batchOfRequestOperations:operations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"%lu of %lu complete", (unsigned long)numberOfFinishedOperations, (unsigned long)totalNumberOfOperations);
    } completionBlock:^(NSArray *operations) {
        NSLog(@"02 -> Download Objects Completed");
        // 2
        // Need to process JSON records into Core Data
        [self processJSONDataRecordsIntoCoreData];
        
    }];
    
    [[NSOperationQueue mainQueue] addOperations:bactchOperations waitUntilFinished:NO];
    
}

/**
 *  Get the most recent update date of an entity
 *
 *  @param entityName entity that need to be fetched the last update date
 *
 *  @return last update date of an entity
 */
- (NSDate *)mostRecentUpdatedAtDateForEntityWithName:(NSString *)entityName {
    __block NSDate *date = nil;
    //
    // Create a new fetch request for the specified entity
    //
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    //
    // Set the sort descriptors on the request to sort by updatedAt in descending order
    //
    [request setSortDescriptors:[NSArray arrayWithObject:
                                 [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    //
    // You are only interested in 1 result so limit the request to 1
    //
    [request setFetchLimit:1];
    [[[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext] performBlockAndWait:^{
        NSError *error = nil;
        NSArray *results = [[[CoreDataStack sharedApplicationStack] backgroundManagedObjectContext] executeFetchRequest:request error:&error];
        if ([results lastObject])   {
            date = [[results lastObject] updatedAt];
        }
    }];
    
    return date;
}


@end
