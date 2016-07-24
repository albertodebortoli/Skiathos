//
//  JEErrorHandlerProtocol.h
//  JustFoundation
//
//  Created by Alberto De Bortoli on 31/07/2015.
//  Copyright (c) 2015 JUST EAT. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JEErrorHandlerProtocol <NSObject>

- (void)handleError:(NSError *)error;

@end
