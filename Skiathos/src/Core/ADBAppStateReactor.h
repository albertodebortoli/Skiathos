//
//  ADBAppStateReactor.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ADBAppStateReactor;

@protocol ADBAppStateReactorDelegate <NSObject>

- (void)appStateReactorDidReceiveStateChange:(ADBAppStateReactor *)reactor;

@end

@interface ADBAppStateReactor : NSObject

@property (nonatomic, weak) id<ADBAppStateReactorDelegate> delegate;

- (void)initialize;

@end

NS_ASSUME_NONNULL_END
