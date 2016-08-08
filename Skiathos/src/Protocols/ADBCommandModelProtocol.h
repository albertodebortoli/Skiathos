//
//  ADBCommandModelProtocol.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^Write)(NSManagedObjectContext * context);

@protocol ADBCommandModelProtocol <NSObject>

- (instancetype)writeSync:(Write)changes;
- (instancetype)writeSync:(Write)changes completion:(void(^ _Nullable)(NSError * _Nullable error))handler;

// async writings are not chainable, return value is void
- (void)writeAsync:(Write)changes;
- (void)writeAsync:(Write)changes completion:(void(^ _Nullable)(NSError * _Nullable error))handler;

@end

NS_ASSUME_NONNULL_END