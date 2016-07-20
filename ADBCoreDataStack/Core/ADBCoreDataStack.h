//
//  ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>

// CoreDataStack Core

// Protocols
#import "ADBPersistenceProtocol.h"
#import "ADBDataAccessLayerProtocol.h"

/*
 * This is a facade.
 * And a singleton.
 * 
 * I'm so proud of myself.
 */
@interface ADBCoreDataStack : NSObject

@property (nonatomic, readonly) id <ADBPersistenceProtocol> persistenceController;
@property (nonatomic, readonly) id <ADBDataAccessLayerProtocol> DALService;

+ (ADBCoreDataStack *)sharedInstance;

@end
