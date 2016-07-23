//
//  ADBDALService.h
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

NS_ASSUME_NONNULL_BEGIN

@interface ADBDALService : NSObject <ADBQueryModelProtocol, ADBCommandModelProtocol>

- (instancetype)initWithPersistenceController:(id<ADBPersistenceProtocol>)persistenceController;

@end

NS_ASSUME_NONNULL_END