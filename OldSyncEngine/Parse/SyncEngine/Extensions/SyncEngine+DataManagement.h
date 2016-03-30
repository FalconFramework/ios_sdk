//
//  SyncEngine+DataManagement.h
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine.h"

@interface SyncEngine (DataManagement)
- (NSURL *)applicationCacheDirectory;
- (NSURL *)JSONDataRecordsDirectory;
- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className;
- (NSDictionary *)JSONDictionaryForClassWithName:(NSString *)className;
- (NSArray *)JSONDataRecordsForClass:(NSString *)className sortedByKey:(NSString *)key;
- (void)clearJSONDataRecordsForClassWithName:(NSString *)className;
-(NSDictionary*)dateDictForAPIUsingDate:(NSDate*)date;
-(NSDictionary*)pointerObjectDictForAPIUsingObjectId:(NSString*)objectId andClassName:(NSString*)className;
- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString;
- (NSString *)dateStringForAPIUsingDate:(NSDate *)date;



@end
