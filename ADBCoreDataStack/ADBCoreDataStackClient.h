//
//  ADBCoreDataStackClient.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADBCoreDataStack.h"

#define CoreDataClient [ADBCoreDataStackClient sharedInstance].DALService

@interface ADBCoreDataStackClient : ADBCoreDataStack

+ (ADBCoreDataStack *)sharedInstance;

@end
