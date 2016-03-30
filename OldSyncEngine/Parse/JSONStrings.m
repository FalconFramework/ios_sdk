//
//  JSONStrings.m
//  
//
//  Created by Thiago-Bernardes on 10/7/15.
//
//

#import "JSONStrings.h"

@implementation JSONStrings




+(NSString*)JSONStringFromDictionary:(NSString*)dictionary{
    
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSMutableString* jsonString = [[NSMutableString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if ([dictionary valueForKey:@"where"]) {
        [jsonString deleteCharactersInRange:NSMakeRange(0, 2)];
        [jsonString deleteCharactersInRange:NSMakeRange(5, 2)];
        [jsonString deleteCharactersInRange:NSMakeRange([jsonString length] -1, 1)];
        [jsonString insertString:@"=" atIndex:5];
        NSMutableString *tempStr = [NSMutableString stringWithString:jsonString];
        [tempStr replaceOccurrencesOfString:@" " withString:@"+" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [tempStr length])];
        jsonString = (NSMutableString*)[[NSString stringWithFormat:@"%@",tempStr] stringByAddingPercentEncodingWithAllowedCharacters:[[NSCharacterSet alloc] init]];
    }
    
    return jsonString;
}

@end
