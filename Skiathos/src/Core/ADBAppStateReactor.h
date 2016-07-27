//
//  ADBAppStateReactor.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADBCoreDataStackProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADBAppStateReactor : NSObject

@property (nonatomic, readonly) id<ADBCoreDataStackProtocol> coreDataStack;

- (instancetype)initWithCoreDataStack:(id<ADBCoreDataStackProtocol>)coreDataStack;
- (void)initialize;

@end

NS_ASSUME_NONNULL_END
