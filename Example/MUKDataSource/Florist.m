//
//  Florist.m
//  MUKDataSource
//
//  Created by Marco on 08/08/14.
//  Copyright (c) 2014 Muccy. All rights reserved.
//

#import "Florist.h"
#import "Flower.h"

@implementation Florist

+ (void)flowersFromIndex:(NSInteger)startIndex count:(NSInteger)count completion:(void (^)(NSArray *flowers, NSError *error))completionHandler
{
    if (!completionHandler) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
    {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"flowers" withExtension:@"json"];
        NSInputStream *stream = [[NSInputStream alloc] initWithURL:fileURL];
        [stream open];
        
        NSError *error = nil;
        NSArray *JSONArray = [NSJSONSerialization JSONObjectWithStream:stream options:0 error:&error];
        [stream close];
        
        if (!JSONArray) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(nil, error);
            });
        }
        else {
            error = nil;
        }
        
        NSMutableArray *flowers = [[NSMutableArray alloc] initWithCapacity:count];
        for (NSInteger i=startIndex; i < startIndex + count; i++) {
            if (i >= [JSONArray count]) {
                break;
            }
            
            NSDictionary *JSONDictionary = JSONArray[i];
            Flower *flower = [[Flower alloc] init];
            flower.name = JSONDictionary[@"name"];
            flower.botanicalName = JSONDictionary[@"botanical_name"];
            
            [flowers addObject:flower];
        } // for
        
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler([flowers copy], nil);
        });
    });
}

@end
