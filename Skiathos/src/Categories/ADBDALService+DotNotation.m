//
//  ADBDALService+DotNotation.m
// 
//
//  Created by Alberto DeBortoli on 26/07/2016.
//  Copyright © 2016 Alberto De Bortoli. All rights reserved.
//

#import "ADBDALService+DotNotation.h"

@implementation ADBDALService (DotNotation)

#pragma mark - ADBDALProtocol

- (ReadDotNotation)read
{
    __weak typeof(self) weakSelf = self;
    
    return ^id <ADBDALProtocol>(Read read) {
        return [weakSelf read:read];
    };
}

- (WriteSyncDotNotation)writeSync
{
    __weak typeof(self) weakSelf = self;
    
    return ^id <ADBDALProtocol>(Write write) {
        return [weakSelf writeSync:write];
    };
}

- (WriteAsyncDotNotation)writeAsync
{
    __weak typeof(self) weakSelf = self;
    
    return ^void(Write write) {
        return [weakSelf writeAsync:write];
    };
}

@end
