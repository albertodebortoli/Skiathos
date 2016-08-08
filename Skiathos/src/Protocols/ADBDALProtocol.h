//
//  ADBDALProtocol.h
// 
//
//  Created by Alberto De Bortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADBQueryModelProtocol.h"
#import "ADBCommandModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ADBDALProtocol;

typedef _Nonnull id <ADBDALProtocol> (^ReadDotNotation)(Read read);
typedef _Nonnull id <ADBDALProtocol> (^WriteSyncDotNotation)(Write write);
typedef void (^WriteAsyncDotNotation)(Write write); // async writings are not chainable, return value is void

@protocol ADBDALProtocol <ADBQueryModelProtocol, ADBCommandModelProtocol>

@optional
- (ReadDotNotation)read;
- (WriteSyncDotNotation)writeSync;
- (WriteAsyncDotNotation)writeAsync;

@end

NS_ASSUME_NONNULL_END
