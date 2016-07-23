//
//  ADBJustEatCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBJustEatCoreDataStack.h"

#import "ADBDALService.h"
#import "ADBPersistenceController.h"
#import "ADBReactor.h"

static NSString *const kDataModelFileName = @"DataModel";

static ADBCoreDataStack *sharedInstance = nil;

@implementation ADBJustEatCoreDataStack

+ (ADBCoreDataStack *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ADBPersistenceController *pc = [[ADBPersistenceController alloc] initSQLiteStoreWithDataModelFileName:kDataModelFileName];
        ADBDALService *dalService = [[ADBDALService alloc] initWithPersistenceController:pc];
        sharedInstance = [[self alloc] initWithPersistenceController:pc
                                                          dalService:dalService];
    });
    
    return sharedInstance;
}

@end
