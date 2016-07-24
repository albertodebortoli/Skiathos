//
//  ADBJustEatCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBJustEatCoreDataStack.h"

#import "ADBDALService.h"
#import "ADBPersistentController.h"

static NSString *const kDataModelFileName = @"DataModel";

static ADBCoreDataStack *sharedInstance = nil;

@implementation ADBJustEatCoreDataStack

+ (ADBCoreDataStack *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ADBPersistentController *pc = [[ADBPersistentController alloc] initWithStoreType:ADBStoreTypeInMemory dataModelFileName:kDataModelFileName];
        ADBDALService *dalService = [[ADBDALService alloc] initWithPersistenceController:pc];
        sharedInstance = [[self alloc] initWithPersistenceController:pc dalService:dalService];
    });
    
    return sharedInstance;
}

- (void)handleError:(NSError *)error
{
    // clients should do the right thing here
    NSLog(@"%@", error.description);
}

@end
