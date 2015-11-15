//
//  NSArray+Functional.m
//  
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (NSArray *)mapUsingBlock:(MapBlock )block
{
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:[self count]];
    for (id o in self)
    {
        [a addObject:block(o)];
    }
    return [NSArray arrayWithArray:a];
}

- (NSArray *)filterUsingBlock:(FilterBlock)block
{
    NSIndexSet *indexSet = [self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    return [self objectsAtIndexes:indexSet];
}

@end
