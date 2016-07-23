//
//  ADBQueryModelProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADBQueryModelProtocol <NSObject>

// Readings

- (void)read:(void(^)(NSManagedObjectContext *))changes;

@end

NS_ASSUME_NONNULL_END
