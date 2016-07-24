//
//  JustEatPersistenceClient.m
//  JUSTEAT
//
//  Created by Alberto De Bortoli on 02/05/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

#import "JustEatPersistenceClient.h"

// Helpers
#import "JustEatPersistenceErrorHandler.h"
#import "JustEatPersistenceLogger.h"

static JustEatPersistenceClient *sharedInstance = nil;

@implementation JustEatPersistenceClient

#pragma mark - Singleton

+ (JustEatPersistenceClient *)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithDBName:@"JEDB"
                                         errorHandler:[[JustEatPersistenceErrorHandler alloc] init]
                                               logger:[[JustEatPersistenceLogger alloc] init]];
    });
    
    return sharedInstance;
}

@end
