//
//  ADBCoreDataStack.h
//  ADBCoreDataStack
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JustPromises/JustPromises.h>
#import "ADBDataAccessLayerProtocol.h"
#import "ADBPersistenceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface ADBCoreDataStack : NSObject

@property (nonatomic, strong, readonly) id<ADBDataAccessLayerProtocol> DALService;
@property (nonatomic, strong, readonly) id<ADBPersistenceProtocol> persistenceController;

- (instancetype)initWithDALService:(id<ADBDataAccessLayerProtocol>)DALService
             persistenceController:(id<ADBPersistenceProtocol>)persistenceController;

- (void)persist;

@end

NS_ASSUME_NONNULL_END
