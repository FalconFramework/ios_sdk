//
//  SyncEngine+DataStore.h
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine.h"
#import "SyncEngine+Internal.h"

@interface SyncEngine (DataStore)

- (void)processJSONDataRecordsForDeletion;
- (void)processJSONDataRecordsIntoCoreData;
- (NSArray *)managedObjectsForClass:(NSString *)className withSyncStatus:(ObjectSyncStatus)syncStatus;
-(void)deleteAllSyncedData;

@end
