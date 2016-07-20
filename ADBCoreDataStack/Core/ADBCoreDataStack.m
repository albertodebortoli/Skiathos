//
//  ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack.h"

#import "ADBDALService.h"
#import "ADBPersistenceController.h"
#import "ADBReactor.h"

static NSString *const kDataModelFileName = @"DataModel";

@interface ADBCoreDataStack ()

@property (nonatomic, strong, readwrite) ADBPersistenceController *persistenceController;
@property (nonatomic, strong, readwrite) ADBDALService *DALService;
@property (nonatomic, strong, readwrite) ADBReactor *reactor;

@end

static ADBCoreDataStack *sharedInstance = nil;

@implementation ADBCoreDataStack

+ (ADBCoreDataStack *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initTheWayWeWantIt];
    });
    
    return sharedInstance;
}

- (instancetype)initTheWayWeWantIt
{
    self = [super init];
    if (self)
    {
        _persistenceController = [[ADBPersistenceController alloc] initSQLiteStoreWithDataModelFileName:kDataModelFileName];
        _DALService = [[ADBDALService alloc] initWithPersistenceController:_persistenceController];
        _reactor = [[ADBReactor alloc] initWithPersistenceController:_persistenceController];
        [_reactor initialize];
    }
    return self;
}

@end
