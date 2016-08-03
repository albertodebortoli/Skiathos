//
//  Skiathos.h
// 
//
//  Created by Alberto De Bortoli on 20/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

// Core
#import "ADBCoreDataStack.h"
#import "ADBDALService.h"

// Categories
#import "ADBDALService+DotNotation.h"
#import "NSManagedObject+Skiathos.h"

@interface Skiathos : ADBDALService

+ (instancetype)setupSqliteStackWithDataModelFileName:(NSString *)dataModelFileName;
+ (instancetype)setupInMemoryStackWithDataModelFileName:(NSString *)dataModelFileName;

@end
