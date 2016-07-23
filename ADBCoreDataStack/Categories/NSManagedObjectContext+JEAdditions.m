//
//  NSManagedObjectContext+JEAdditions.m
//  JUSTEAT
//
//  Created by Alberto De Bortoli on 03/03/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

#import "NSManagedObjectContext+JEAdditions.h"
#import "ADBCoreDataStack.h"

@implementation NSManagedObjectContext (JEAdditions)

+ (NSManagedObjectContext *)main
{
    return [ADBCoreDataStack sharedInstance].persistenceController.mainContext;
}

+ (NSManagedObjectContext *)child
{
    return [ADBCoreDataStack sharedInstance].persistenceController.slaveContext;
}

@end
