//
//  SyncEngineManagedObject.h
//  OnFit
//
//  Created by Thiago-Bernardes on 1/17/16.
//  Copyright © 2016 OnfFit. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SyncEngineManagedObject : NSManagedObject

@property (nonatomic, retain) NSNumber * active;
@property (nonatomic, retain) NSString * cloudObjectId;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSNumber * syncStatus;
@property(nonatomic) BOOL isRecentDownloadedData;
-(void)delete;
-(NSDictionary *)JSONToCreateObjectOnServer;
-(NSDictionary *)JSONToCreateObjectRelationsOnServer;
-(NSDictionary *)JSONToDisableObjectOnServer;
@end
