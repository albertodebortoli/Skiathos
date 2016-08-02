//
//  ADBCoreDataStackProtocol.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol ADBCoreDataStackProtocol <NSObject>

@property (nonatomic, readonly) NSManagedObjectContext *mainContext;
@property (nonatomic, readonly) NSManagedObjectContext *rootContext;

- (void)save:(void(^)(NSError *error))handler;

@end
