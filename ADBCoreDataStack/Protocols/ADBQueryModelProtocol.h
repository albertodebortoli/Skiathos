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

typedef void (^Read)(NSManagedObjectContext * context);

@protocol ADBCommandModelProtocol;

@protocol ADBQueryModelProtocol <NSObject>

@required
- (void)read:(Read)statements;

@end

NS_ASSUME_NONNULL_END
