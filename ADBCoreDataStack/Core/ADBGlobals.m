//
//  ADBGlobals.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBGlobals.h"

@implementation ADBGlobals

static ADBCoreDataStack *sharedCoreDataStack = nil;
static ADBDALService *sharedDALService = nil;
static ADBPersistenceController *sharedPersistenceController = nil;

#pragma mark - Singleton

+ (ADBPersistenceController *)sharedPersistenceController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ADBPersistenceController *pc = [[ADBPersistenceController alloc] initSQLiteStoreWithDataModelFileName:@"DataModel"];
        sharedPersistenceController = pc;
    });
    
    return sharedPersistenceController;
}

+ (ADBDALService *)sharedDALService
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ADBDALService *dalService = [[ADBDALService alloc] initWithPersistenceController:[self sharedPersistenceController]];
        sharedDALService = dalService;
    });
    
    return sharedDALService;
}

+ (ADBCoreDataStack *)sharedCoreDataStack
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ADBCoreDataStack *cds = [[ADBCoreDataStack alloc] initWithPersistenceController:[self sharedPersistenceController]];
        sharedCoreDataStack = cds;
    });
    
    return sharedCoreDataStack;
}

@end
