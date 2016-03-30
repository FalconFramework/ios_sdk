//
//  SDAFParseAPIClient.h
//  OnFit
//
//  Created by Thiago-Bernardes on 9/16/15.
//  Copyright (c) 2015 OnfFit. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import <Parse/Parse.h>

@interface AFParseAPIClient : AFHTTPRequestOperationManager

+ (AFParseAPIClient *)sharedClient;
- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate activeObjects:(BOOL)active;
- (NSMutableURLRequest *)GETRequestForAllKeys:(NSString*)key OfClass:(NSString *)className;
- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters;
- (NSMutableURLRequest *)PUTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters forObjectId:(NSString*)objectId;
@end
