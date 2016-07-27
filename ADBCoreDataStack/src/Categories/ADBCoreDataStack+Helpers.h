//
//  ADBCoreDataStack+Helpers.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import "ADBCoreDataStack.h"

@interface ADBCoreDataStack (Helpers)

+ (instancetype)sqliteCoreDataStackWithDataModelFileName:(NSString *)dataModelFileName;
+ (instancetype)inMemoryCoreDataStackWithDataModelFileName:(NSString *)dataModelFileName;

@end
