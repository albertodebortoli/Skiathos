//
//  ADBDALService+Helpers.m
// 
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import "ADBDALService+Helpers.h"
#import "ADBCoreDataStack.h"
#import "ADBDALService.h"

@implementation ADBDALService (Helpers)

+ (instancetype)sqliteStackWithDataModelFileName:(NSString *)dataModelFileName
{
    ADBCoreDataStack *cds = [[ADBCoreDataStack alloc] initWithStoreType:ADBStoreTypeSQLite dataModelFileName:dataModelFileName];
    return [[ADBDALService alloc] initWithCoreDataStack:cds];
}

+ (instancetype)inMemoryStackWithDataModelFileName:(NSString *)dataModelFileName
{
    ADBCoreDataStack *cds = [[ADBCoreDataStack alloc] initWithStoreType:ADBStoreTypeInMemory dataModelFileName:dataModelFileName];
    return [[ADBDALService alloc] initWithCoreDataStack:cds];
}

@end
