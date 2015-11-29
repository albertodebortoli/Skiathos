//
//  NSObject+Introspecta.m
//  Introspecta
//
//  Created by Alberto De Bortoli on 12/19/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <objc/runtime.h>
#import "NSObject+Introspecta.h"
#import "ISVar.h"

@implementation NSObject (Introspecta)

- (NSDictionary *)cocoaSerialization
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    NSArray *iVars = [[self class] properties];
    for (ISVar *iVar in iVars) {
        [dictionary setValue:[self valueForKey:iVar.name] forKey:iVar.name];
    }
    
    return dictionary;
}

+ (NSArray *)iVars
{
    unsigned int varCount;
    
    Ivar *vars = class_copyIvarList([self class], &varCount);
    
    NSMutableArray *retVal = [NSMutableArray array];
    
    for (int i = 0; i < varCount; i++) {
        Ivar var = vars[i];
        
        const char* name = ivar_getName(var);
        const char* type = ivar_getTypeEncoding(var);
        
        NSString *str_name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        NSString *str_type = [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        
        ISVar *iVar = [ISVar iVarWithName:str_name type:str_type];
        
        [retVal addObject:iVar];
    }
    
    free(vars);
    
    Class superClass = class_getSuperclass([self class]);
    if (superClass != nil && ![superClass isEqual:[NSObject class]])
    {
        retVal = [[[superClass iVars] arrayByAddingObjectsFromArray:retVal] mutableCopy];
    }
    
    return retVal;
}

+ (NSArray *)properties
{
    unsigned int proprtiesCount;
    
    objc_property_t *properties = class_copyPropertyList([self class], &proprtiesCount);
    
    NSMutableArray *retVal = [NSMutableArray array];
    
    for (int i = 0; i < proprtiesCount; i++) {
        objc_property_t property = properties[i];
        
        const char* name = property_getName(property);
        const char* attributes = property_getAttributes(property);
        
        NSString *str_name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        NSString *str_attributes = [NSString stringWithCString:attributes encoding:NSUTF8StringEncoding];
        
        ISVar *isProperty = [ISVar iVarWithName:str_name type:str_attributes];
        
        [retVal addObject:isProperty];
    }
    
    free(properties);
    
    Class superClass = class_getSuperclass([self class]);
    if (superClass != nil && ![superClass isEqual:[NSObject class]])
    {
        retVal = [[[superClass properties] arrayByAddingObjectsFromArray:retVal] mutableCopy];
    }
    
    return retVal;
}

+ (NSArray *)methods
{
    unsigned int methodsCount;
    
    Method *methods = class_copyMethodList([self class], &methodsCount);
    
    NSMutableArray *retVal = [NSMutableArray array];
    
    for (int i = 0; i < methodsCount; i++) {
        Method method = methods[i];
        
        SEL selector = method_getName(method);
        
        NSString *selector_name = NSStringFromSelector(selector);
        
        [retVal addObject:selector_name];
    }
    
    free(methods);
    
    Class superClass = class_getSuperclass([self class]);
    if (superClass != nil && ![superClass isEqual:[NSObject class]])
    {
        retVal = [[[superClass methods] arrayByAddingObjectsFromArray:retVal] mutableCopy];
    }
    
    return retVal;
}

+ (NSArray *)protocols
{
    unsigned int protocolsCount;
    
    Protocol * __unsafe_unretained *protocols = class_copyProtocolList([self class], &protocolsCount);
    
    NSMutableArray *retVal = [NSMutableArray array];
    
    for (int i = 0; i < protocolsCount; i++) {
        Protocol *protocol = protocols[i];
        
        const char* name = protocol_getName(protocol);
        
        NSString *str_name = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
        
        [retVal addObject:str_name];
    }
    
    free(protocols);
    
    Class superClass = class_getSuperclass([self class]);
    if (superClass != nil && ![superClass isEqual:[NSObject class]])
    {
        retVal = [[[superClass protocols] arrayByAddingObjectsFromArray:retVal] mutableCopy];
    }
    
    return retVal;
}

@end
