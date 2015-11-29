//
//  ADBCoreDataStackClient.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStackClient.h"
#import "ADBDALService.h"
#import "ADBPersistenceController.h"

@implementation ADBCoreDataStackClient

static ADBCoreDataStackClient *sharedInstance = nil;

#pragma mark - Singleton

+ (ADBCoreDataStackClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ADBPersistenceController *pc = [[ADBPersistenceController alloc] initSQLiteStoreWithDataModelFileName:@"DataModel"];
        ADBDALService *dalService = [[ADBDALService alloc] initWithPersistenceController:pc];
        sharedInstance = [[super alloc] initWithDALService:dalService persistenceController:pc];
    });
    
    return sharedInstance;
}

@end
