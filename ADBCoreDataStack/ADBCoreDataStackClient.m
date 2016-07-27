//
//  ADBCoreDataStackClient.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStackClient.h"

#import "ADBCoreDataStack+Helpers.h"

static ADBCoreDataStack *sharedInstance = nil;

@implementation ADBCoreDataStackClient

+ (ADBCoreDataStack *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self sqliteCoreDataStackWithDataModelFileName:@"DataModel"];
    });
    
    return sharedInstance;
}

- (void)handleError:(NSError *)error
{
    // clients should do the right thing here
    NSLog(@"%@", error.description);
}

@end
