//
//  ADBJustEatCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

// Frameworks
#import <Foundation/Foundation.h>

#import "ADBCoreDataStack.h"

#define JustPersistence [ADBJustEatCoreDataStack sharedInstance].DALService
#define JustPersistenceErrorHandler [ADBJustEatCoreDataStack sharedInstance].errorHandler

@interface ADBJustEatCoreDataStack : ADBCoreDataStack

+ (ADBCoreDataStack *)sharedInstance;

@end
