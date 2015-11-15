//
//  NSArray+Functional.h
//
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id(^MapBlock)(id obj);

typedef BOOL (^FilterBlock)(id obj);

@interface NSArray (Functional)

- (NSArray *)mapUsingBlock:(MapBlock)block;
- (NSArray *)filterUsingBlock:(FilterBlock)block;

@end
