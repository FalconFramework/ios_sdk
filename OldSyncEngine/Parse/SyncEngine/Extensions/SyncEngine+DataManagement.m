//
//  SyncEngine+DataManagement.m
//  OnFit
//
//  Created by Thiago-Bernardes on 12/21/15.
//  Copyright © 2015 OnfFit. All rights reserved.
//

#import "SyncEngine+DataManagement.h"

@implementation SyncEngine (DataManagement)

#pragma mark - File Management

/**
 *  Get the application cache directory of the user installation.
 *
 *  @return URL of user cache path url.
 */
- (NSURL *)applicationCacheDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 *  Get the json data storage path as a subpath of cache directory, if the path was not created, created its will be here.
 *
 *  @return JSON data storage path url
 */
- (NSURL *)JSONDataRecordsDirectory{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL URLWithString:@"JSONRecords/" relativeToURL:[self applicationCacheDirectory]];
    NSError *error = nil;
    if (![fileManager fileExistsAtPath:[url path]]) {
        [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return url;
}

/**
 *  Create a JSON file that contains the RESTFUL response data and the class regsitered to sync name, into user cache path for JSON records.
 *
 *  @param response  Data to be stored into the JSON file
 *  @param className The Synced Class name represents the file name here
 */
- (void)writeJSONResponse:(id)response toDiskForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    if (![(NSDictionary *)response writeToFile:[fileURL path] atomically:YES]) {
        NSLog(@"Error saving response to disk, will attempt to remove NSNull values and try again.");
        // remove NSNulls and try again...
        NSArray *records = [response objectForKey:@"results"];
        NSMutableArray *nullFreeRecords = [NSMutableArray array];
        for (NSDictionary *record in records) {
            NSMutableDictionary *nullFreeRecord = [NSMutableDictionary dictionaryWithDictionary:record];
            [record enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSNull class]]) {
                    [nullFreeRecord setValue:nil forKey:key];
                }
            }];
            [nullFreeRecords addObject:nullFreeRecord];
        }
        
        NSDictionary *nullFreeDictionary = [NSDictionary dictionaryWithObject:nullFreeRecords forKey:@"results"];
        
        if (![nullFreeDictionary writeToFile:[fileURL path] atomically:YES]) {
            NSLog(@"Failed all attempts to save response to disk: %@", response);
        }
    }
}


/**
 *  Delete the data in the restful response data cached of one class registered to sync.
 *
 *  @param className Class to get the data cached
 *  @param key Sort parameter to create ordered array
 *
 */
- (NSArray *)JSONDataRecordsForClass:(NSString *)className sortedByKey:(NSString *)key {
    NSDictionary *JSONDictionary = [self JSONDictionaryForClassWithName:className];
    NSArray *records = [JSONDictionary objectForKey:@"results"];
    return [records sortedArrayUsingDescriptors:[NSArray arrayWithObject:
                                                 [NSSortDescriptor sortDescriptorWithKey:key ascending:YES]]];
}

- (NSDictionary *)JSONDictionaryForClassWithName:(NSString *)className {
    NSURL *fileURL = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    return [NSDictionary dictionaryWithContentsOfURL:fileURL];
}

/**
 *  Delete the json file that contains the restful response data cached of one class registered to sync.
 *
 *  @param className Class to delete the data cached
 *
 */
- (void)clearJSONDataRecordsForClassWithName:(NSString *)className {
    NSURL *url = [NSURL URLWithString:className relativeToURL:[self JSONDataRecordsDirectory]];
    NSError *error = nil;
    BOOL deleted = [[NSFileManager defaultManager] removeItemAtURL:url error:&error];
    if (!deleted) {
        NSLog(@"Unable to delete JSON Records at %@, reason: %@", url, error);
    }
}



#pragma mark - Date type management

/**
 *  Convert Date type to Dictionary type to can be sent to the server
 *
 *  @param date Date to be converted
 *
 *  @return Converted data in dictionary format
 */
-(NSDictionary*)dateDictForAPIUsingDate:(NSDate*)date{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            @"Date", @"__type",
            [[SyncEngine sharedEngine] dateStringForAPIUsingDate:date], @"iso" , nil];
}


/**
 *  Convert String type to Date type to can be reaad from the server response
 *
 *  @param dateString String to be converted
 *
 *  @return Date converted
 */
- (NSDate *)dateUsingStringFromAPI:(NSString *)dateString {
    // NSDateFormatter does not like ISO 8601 so strip the milliseconds and timezone
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-5)];
    
    return [self.dateFormatter dateFromString:dateString];
}

- (NSString *)dateStringForAPIUsingDate:(NSDate *)date {
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    // remove Z
    dateString = [dateString substringWithRange:NSMakeRange(0, [dateString length]-1)];
    // add milliseconds and put Z back on
    dateString = [dateString stringByAppendingFormat:@".000Z"];
    
    return dateString;
}

/**
 *
 *  @return Date formatter with the format of Date type in the server
 */
-(NSDateFormatter*)dateFormatter{
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    
    return dateFormatter;
    
}

#pragma mark - Object type management

/**
 *  Convert a Model object to Dictionary pointer object type to be sent to the server
 *
 *  @param objectId  cloud ObjectID of the object pointer
 *  @param className Model class name
 *
 *  @return Dictionary with the the pointer content.
 */
-(NSDictionary*)pointerObjectDictForAPIUsingObjectId:(NSString*)objectId andClassName:(NSString*)className{
    
    if ([objectId length]>0) {
        return [NSDictionary dictionaryWithObjectsAndKeys:
                @"Pointer", @"__type",
                objectId, @"objectId" ,
                className, @"className",
                nil];
    }else{
        return nil;
    }
    
    
}

@end
