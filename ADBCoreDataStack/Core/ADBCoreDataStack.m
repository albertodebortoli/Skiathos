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

- (instancetype)initWithPersistenceController:(id <ADBPersistenceProtocol>)persistenceController
                                   dalService:(id <ADBQueryModelProtocol, ADBCommandModelProtocol>)dalService
{
    self = [super init];
    if (self)
    {
        _persistenceController = persistenceController;
        _DALService = dalService;
        _reactor = [[ADBReactor alloc] initWithPersistenceController:_persistenceController];
        [_reactor initialize];
    }
    return self;
}

@end
