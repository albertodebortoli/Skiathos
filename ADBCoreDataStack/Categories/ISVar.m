//
//  ISVar.m
//  Introspecta
//
//  Created by Alberto De Bortoli on 12/19/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import "ISVar.h"

@implementation ISVar

- (id)initWithName:(NSString *)aName type:(NSString *)aType
{
    self = [super init];
    
    if (self) {
        _name = [aName copy];
        _type = [aType copy];
    }
    
    return self;
}

+ (ISVar *)iVarWithName:(NSString *)aName type:(NSString *)aType
{
    return [[ISVar alloc] initWithName:aName type:aType];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p> name: %@; type: %@", [self class], self, self.name, self.type];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[ISVar class]]) {
        ISVar *var = (ISVar *)object;
        BOOL sameName = [self.name isEqualToString:var.name];
        BOOL sameType = [self.type isEqualToString:var.type];
        return (sameName && sameType);
    }
    
    return NO;
}

@end
