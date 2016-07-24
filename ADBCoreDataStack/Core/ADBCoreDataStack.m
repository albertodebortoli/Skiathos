//
//  ADBCoreDataStack.m
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack.h"
#import "ADBReactor.h"

static NSString *const kDataModelFileName = @"DataModel";

@interface ADBCoreDataStack ()

@property (nonatomic, strong, readwrite) id <ADBPersistenceProtocol> persistenceController;
@property (nonatomic, strong, readwrite) id <ADBQueryModelProtocol, ADBCommandModelProtocol> DALService;
@property (nonatomic, strong, readwrite) id <ADBErrorHandlerProtocol> errorHandler;
@property (nonatomic, strong, readwrite) id <ADBLoggerProtocol> logger;
@property (nonatomic, strong, readwrite) ADBReactor *reactor;

@end

static ADBCoreDataStack *sharedInstance = nil;

@implementation ADBCoreDataStack

- (instancetype)initWithPersistenceController:(id <ADBPersistenceProtocol>)persistenceController
                                   dalService:(id <ADBQueryModelProtocol, ADBCommandModelProtocol>)dalService
                                 errorHandler:(id <ADBErrorHandlerProtocol>)errorHandler
                                       logger:(id <ADBLoggerProtocol>)logger
{
    self = [super init];
    if (self)
    {
        _persistenceController = persistenceController;
        _DALService = dalService;
        _errorHandler = errorHandler;
        _logger = logger;
        _reactor = [[ADBReactor alloc] initWithPersistenceController:_persistenceController];
        [_reactor initialize];
    }
    return self;
}

@end
