//
//  SyncEngine+Internal.h
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine.h"




@interface SyncEngine(Internal)

//Model Entitie Classes that sync engine will work
@property (nonatomic, strong) NSMutableArray *registeredClassesToSync;
- (BOOL)initialSyncComplete;
- (void)executeSyncCompletedOperations;

@end
