//
//  ADBGlobals.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>

// CoreDataStack Core
#import "ADBDALService.h"
#import "ADBPersistenceController.h"
#import "ADBCoreDataStack.h"

@interface ADBGlobals : NSObject

// thinking of a way for not having singletons (dependency injection doesn't fit here)

+ (ADBPersistenceController *)sharedPersistenceController;
+ (ADBDALService *)sharedDALService;
+ (ADBCoreDataStack *)sharedCoreDataStack;

@end
