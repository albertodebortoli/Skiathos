//
//  SkiathosClient.m
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "SkiathosClient.h"

#import "ADBDALService+Helpers.h"

static SkiathosClient *sharedInstance = nil;

@implementation SkiathosClient

+ (SkiathosClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self sqliteStackWithDataModelFileName:@"DataModel"];
    });
    
    return sharedInstance;
}

- (void)handleError:(NSError *)error
{
    // clients should do the right thing here
    NSLog(@"%@", error.description);
}

@end
