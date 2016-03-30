//
//  SDSyncEngine.h
//  OnFit
//
//  Created by Thiago-Bernardes on 9/16/15.
//  Copyright (c) 2015 OnfFit. All rights reserved.
//

#import <CoreData/CoreData.h>

typedef enum {
    ObjectCreated = 0,
    ObjectSynced,
    ObjectUpdated,
    ObjectDeleted
} ObjectSyncStatus;


@interface SyncEngine : NSObject

+ (SyncEngine *)sharedEngine;
- (void)registerNSManagedObjectClassToSync:(Class)aClass;
- (void)startSync;
- (void)executeSyncServerLogoutOperations:(NSString*)lastLoginUserId;
- (void)turnOnSync;
- (void)turnOffSync;
- (BOOL)isOn;
@end

