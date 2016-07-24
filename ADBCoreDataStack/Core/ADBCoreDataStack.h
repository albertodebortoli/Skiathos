//
//  ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>

// Protocols
#import "ADBPersistenceProtocol.h"
#import "ADBQueryModelProtocol.h"
#import "ADBCommandModelProtocol.h"

@interface ADBCoreDataStack : NSObject

@property (nonatomic, readonly) id <ADBPersistenceProtocol> persistenceController;
@property (nonatomic, readonly) id <ADBQueryModelProtocol, ADBCommandModelProtocol> DALService;

- (instancetype)initWithPersistenceController:(id <ADBPersistenceProtocol>)persistenceController
                                   dalService:(id <ADBQueryModelProtocol, ADBCommandModelProtocol>)dalService;

- (void)handleError:(NSError *)error;

@end
