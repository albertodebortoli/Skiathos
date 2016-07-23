//
//  NSManagedObjectContext+JEAdditions.h
//  JUSTEAT
//
//  Created by Alberto De Bortoli on 03/03/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (JEAdditions)

+ (NSManagedObjectContext *)main;
+ (NSManagedObjectContext *)child;

@end
