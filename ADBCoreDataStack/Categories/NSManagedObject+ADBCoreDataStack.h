//
//  NSManagedObject+ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 29/11/2015.
//  Copyright © 2015 Alberto De Bortoli. All rights reserved.
//

#import <CoreData/CoreData.h>

// Vendors
#import <JustPromises/JustPromises.h>

@interface NSManagedObject (ADBCoreDataStack)

+ (JEFuture *)all;
+ (JEFuture *)first;
+ (JEFuture *)save:(NSArray *)plainObjects;
+ (JEFuture *)deleteAll;

@end
