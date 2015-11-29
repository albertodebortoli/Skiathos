//
//  ISVar.h
//  Introspecta
//
//  Created by Alberto De Bortoli on 12/19/12.
//  Copyright (c) 2012 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ISVar : NSObject {
    
    NSString *_name;
    NSString *_type;
}

- (id)initWithName:(NSString *)aName type:(NSString *)aType;
+ (ISVar *)iVarWithName:(NSString *)aName type:(NSString *)aType;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;

@end
