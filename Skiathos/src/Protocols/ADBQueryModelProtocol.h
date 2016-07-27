//
//  ADBQueryModelProtocol.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ADBQueryModelProtocol;

typedef void (^Read)(NSManagedObjectContext * context);

@protocol ADBQueryModelProtocol <NSObject>

- (instancetype)read:(Read)statements;

@end

NS_ASSUME_NONNULL_END
