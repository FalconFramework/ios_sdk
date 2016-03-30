//
//  SyncEngine+DataDownload.h
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine.h"

@interface SyncEngine (DataDownload)


- (void)downloadRecentRemoteDisabledObjects;
- (void)downloadRecentUpdatedRemoteData:(BOOL)useUpdatedAtDate;

@end
