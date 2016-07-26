//
//  ADBCommandModelProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADBCommandModelProtocol <NSObject>

- (void)write:(void(^)(NSManagedObjectContext *context))changes;
- (void)write:(void(^)(NSManagedObjectContext *context))statements completion:(void(^ _Nullable)(NSError * _Nullable error))handler;

@end

NS_ASSUME_NONNULL_END