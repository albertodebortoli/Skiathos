//
//  ADBGlobals.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ADBPersistenceController;
@class ADBDALService;
@class ADBCoreDataStack;

@interface ADBGlobals : NSObject

+ (ADBPersistenceController *)sharedPersistenceController;
+ (ADBDALService *)sharedDALService;
+ (ADBCoreDataStack *)sharedCoreDataStack;

@end
