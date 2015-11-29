//
//  NSManagedObject+ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto DeBortoli on 29/11/2015.
//  Copyright © 2015 JUST EAT. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "JEFuture.h"

@interface NSManagedObject (ADBCoreDataStack)

+ (JEFuture *)all;
+ (JEFuture *)first;
+ (JEFuture *)save:(NSArray *)plainObjects;

@end
