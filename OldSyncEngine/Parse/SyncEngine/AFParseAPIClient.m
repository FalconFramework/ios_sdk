//
//  SDAFParseAPIClient.m
//  OnFit
//
//  Created by Thiago-Bernardes on 9/16/15.
//  Copyright (c) 2015 OnfFit. All rights reserved.
//

#import "AFParseAPIClient.h"
#import "JSONStrings.h"
static NSString * const kParseAPIBaseURLString = @"api.parse.com/1/";

static NSString * const kParseAPIApplicationId = @"4mMBsKAXRAnNs0zbNIn4kZAh2CDmlSndKAdg7RMu";
static NSString * const kParseAPIKey = @"T02jQuOieqFX4s4uzAefrARtJiiPJNWXzekdKkG4";

@implementation AFParseAPIClient

+ (AFParseAPIClient *)sharedClient {
    static AFParseAPIClient *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[AFParseAPIClient alloc] initWithBaseURL:[NSURL URLWithString:kParseAPIBaseURLString]];
    });
    
    return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        
        //Set Headers
        //Content type to JSON
        [self.requestSerializer setValue:@"application.json" forHTTPHeaderField:@"Content-Type"];
        //App id of parse
        [self.requestSerializer setValue:kParseAPIApplicationId forHTTPHeaderField:@"X-Parse-Application-Id"];
        //Rest api key of parse
        [self.requestSerializer setValue:kParseAPIKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
        //Set the session token of the current user
        [self.requestSerializer setValue:[[PFUser currentUser] sessionToken] forHTTPHeaderField:@"X-Parse-Session-Token"];

    }
    
    return self;
    
}

- (NSMutableURLRequest *)GETRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;

    NSString* json = [JSONStrings JSONStringFromDictionary:parameters];
    NSString* stringURL = [NSString stringWithFormat:@"%@?%@",[self parseClassUrlForClass:className],json];
    
    request = [self.requestSerializer requestWithMethod:@"GET" URLString:stringURL parameters:nil error:nil];
    
    return request;
}

- (NSMutableURLRequest *)POSTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters {
    NSMutableURLRequest *request = nil;
    
    request = [self.requestSerializer requestWithMethod:@"POST" URLString:[self parseClassUrlForClass:className] parameters:parameters error:nil];
    
    return request;
}

- (NSMutableURLRequest *)PUTRequestForClass:(NSString *)className parameters:(NSDictionary *)parameters forObjectId:(NSString*)objectId {
    NSMutableURLRequest *request = nil;
    
    NSString* urlString = [NSString stringWithFormat:@"%@/%@",[self parseClassUrlForClass:className],objectId];
    request = [self.requestSerializer requestWithMethod:@"PUT" URLString:urlString parameters:parameters error:nil];
    
    return request;
}

-(NSString*)parseClassUrlForClass:(NSString*)className{
    if(![className isEqualToString:@"User"]){
        return [NSString stringWithFormat:@"https://%@classes/%@",kParseAPIBaseURLString,className];
    }else{
        return [NSString stringWithFormat:@"https://%@users",kParseAPIBaseURLString];

    }
}

- (NSMutableURLRequest *)GETRequestForAllRecordsOfClass:(NSString *)className updatedAfterDate:(NSDate *)updatedDate activeObjects:(BOOL)active{
    NSMutableURLRequest *request = nil;
    NSMutableDictionary *parameters = nil;
    if (updatedDate) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.'999Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        
        NSString* updatedAtDateString = [dateFormatter stringFromDate:updatedDate];
        
        NSDictionary *jsonDict= @{ @"updatedAt":@{
                                           @"$gte":@{
                                                   @"__type":@"Date",
                                                   @"iso":updatedAtDateString,
                                          
                                          }
                                  },
                          @"active":[NSNumber numberWithBool:active]
                          };
        
        parameters = [NSMutableDictionary dictionaryWithObject:jsonDict forKey:@"where"];
    }else{
        



        parameters = [NSMutableDictionary dictionaryWithObject:@{@"active":[NSNumber numberWithBool:active]} forKey:@"where"];
    }
    
    
    request = [self GETRequestForClass:className parameters:parameters];
    return request;
}

- (NSMutableURLRequest *)GETRequestForAllKeys:(NSString*)key OfClass:(NSString *)className{
    NSMutableURLRequest *request = nil;
    NSDictionary *parameters = nil;
            NSString *keyQueryConstraint = key;
        
        parameters = [NSDictionary dictionaryWithObject:keyQueryConstraint forKey:@"keys"];
    
    request = [self GETRequestForClass:className parameters:parameters];
    return request;
}



@end
