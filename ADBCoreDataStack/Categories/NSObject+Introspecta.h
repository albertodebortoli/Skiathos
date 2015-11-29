//
//  NSObject+Introspecta.h
//  Introspecta
//
//  Created by Alberto De Bortoli on 12/19/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Introspecta)

- (NSDictionary *)cocoaSerialization;
+ (NSArray *)iVars;
+ (NSArray *)properties;
+ (NSArray *)methods;
+ (NSArray *)protocols;

@end
