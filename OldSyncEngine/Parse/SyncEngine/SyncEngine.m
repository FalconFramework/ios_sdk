//
//  SDSyncEngine.m
//  OnFit
//
//  Created by Thiago-Bernardes on 9/16/15.
//  Copyright (c) 2015 OnfFit. All rights reserved.
//

#import "SyncEngine.h"

#import "CoreDataStack.h"
#import "SyncEngine+DataDownload.h"
#import "SyncEngine+Internal.h"
#import "SyncEngine+DataStore.h"
#import "SyncEngineManagedObject.h"
#import "OnFit-Bridging-Header.h"

NSString * const kSyncEngineTurnOnKey = @"SyncEngineOn";
NSString * const kSyncEngineInitialCompleteKey = @"SyncEngineInitialSyncCompleted";
NSString * const kSyncEngineServerLastLoginUserIdKey = @"SyncEngineServerLastLoginUserId";
NSString * const kSyncEngineSyncCompletedNotificationName = @"SyncEngineSyncCompleted";

@interface SyncEngine()
@property (atomic, readonly) BOOL syncInProgress;
@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;

@end

@implementation SyncEngine


#pragma mark Sync Engine Setup
/**
 *  //Create only one instance of sync engine
 *
 *  @return The single instance of SyncEngine
 */
+ (SyncEngine *)sharedEngine {
    static SyncEngine *sharedEngine = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEngine = [[SyncEngine alloc] init];
    });
    
    return sharedEngine;
}

//Adds a entitie class to the classes that the sync engine will work
/**
 *  Add a class to be managed by the sync engine
 *
 *  @param aClass model class name that will be managed
 */
- (void)registerNSManagedObjectClassToSync:(Class)aClass {
    if (!self.registeredClassesToSync) {
        self.registeredClassesToSync = [NSMutableArray array];
    }
    
    if ([aClass isSubclassOfClass:[SyncEngineManagedObject class]]) {
        NSString* className = NSStringFromClass(aClass);
        if (![self.registeredClassesToSync containsObject:className]) {
            
            NSString* appBundleName = [NSString stringWithFormat:@"%@.",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
            
            if([className containsString:appBundleName]){
                className = [className stringByReplacingOccurrencesOfString:appBundleName withString:@""];
            }
            [self.registeredClassesToSync addObject:className];
        } else {
            NSLog(@"Unable to register %@ as it is already registered", NSStringFromClass(aClass));
        }
    } else {
        NSLog(@"Unable to register %@ as it is not a subclass of NSManagedObject", NSStringFromClass(aClass));
    }
    
}


/**
 *  Start the sync engine process flow
 */
- (void)startSync {
    
    if ([PFUser currentUser] && [self isOn]) {
        
        if ( [self syncEngineServerLoginUserId] != nil && ![[[PFUser currentUser] objectId] isEqual: [self syncEngineServerLoginUserId]]) {
            [self setInitialSyncNotPerformed];
            [self deleteAllSyncedData];
        }
        
        if (!self.syncInProgress) {
            [self willChangeValueForKey:@"syncInProgress"];
            _syncInProgress = YES;
            [self didChangeValueForKey:@"syncInProgress"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                [self downloadRecentRemoteDisabledObjects];
                
            });
        }
    }
    
}

/**
 *  Finish the process of the sync engine
 */
- (void)executeSyncCompletedOperations {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setInitialSyncCompleted];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kSyncEngineSyncCompletedNotificationName
         object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
        [[CoreDataStack sharedApplicationStack] saveContext];
        
    });
}

/**
 *  When SyncServerLogout turn of sync engine and store token off last logged
 */
- (void)executeSyncServerLogoutOperations:(NSString*)lastLoginUserId {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self turnOffSync];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kSyncEngineSyncCompletedNotificationName
         object:nil];
        [self willChangeValueForKey:@"syncInProgress"];
        _syncInProgress = NO;
        [self didChangeValueForKey:@"syncInProgress"];
        
        [self storeSyncEngineServerLoginUserId:lastLoginUserId];
        
        
        [[CoreDataStack sharedApplicationStack] saveContext];
        
    });
}

/**
 *  Indicate if the engine already be synced at least one time
 *
 *  @return Boolean that indica te if the sync engine already be synced at least one time
 */
- (BOOL)initialSyncComplete {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kSyncEngineInitialCompleteKey] boolValue];
}

/**
 *  Set that the engine already synced at least one time
 */
- (void)setInitialSyncCompleted {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kSyncEngineInitialCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  Set that the engine not synced at least one time
 */
- (void)setInitialSyncNotPerformed {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:kSyncEngineInitialCompleteKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


/**
 *  Set that the engine on
 */
- (void)turnOnSync {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:kSyncEngineTurnOnKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  Set that the engine off
 */
- (void)turnOffSync {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:kSyncEngineTurnOnKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  Indicate if the engine already be synced at least one time
 *
 *  @return Boolean that indica te if the sync engine already be synced at least one time
 */
- (BOOL)isOn {
    return [[[NSUserDefaults standardUserDefaults] valueForKey:kSyncEngineTurnOnKey] boolValue];
}


- (NSString*)syncEngineServerLoginUserId{
    return [[NSUserDefaults standardUserDefaults] valueForKey:kSyncEngineServerLastLoginUserIdKey];
}
- (void)storeSyncEngineServerLoginUserId:(NSString*)userId {
    [[NSUserDefaults standardUserDefaults] setValue:userId forKey:kSyncEngineServerLastLoginUserIdKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

