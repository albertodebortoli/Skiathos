//
//  ADBCoreDataStack+Helpers.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack+Helpers.h"
#import "ADBPersistentController.h"
#import "ADBDALService.h"

@implementation ADBCoreDataStack (Helpers)

+ (instancetype)sqliteCoreDataStackWithDataModelFileName:(NSString *)dataModelFileName
{
    ADBPersistentController *pc = [[ADBPersistentController alloc] initWithStoreType:ADBStoreTypeSQLite dataModelFileName:dataModelFileName];
    ADBDALService *dalService = [[ADBDALService alloc] initWithPersistenceController:pc];
    return [[self alloc] initWithPersistenceController:pc dalService:dalService];
}

+ (instancetype)inMemoryCoreDataStackWithDataModelFileName:(NSString *)dataModelFileName
{
    ADBPersistentController *pc = [[ADBPersistentController alloc] initWithStoreType:ADBStoreTypeInMemory dataModelFileName:dataModelFileName];
    ADBDALService *dalService = [[ADBDALService alloc] initWithPersistenceController:pc];
    return [[self alloc] initWithPersistenceController:pc dalService:dalService];
}

@end
