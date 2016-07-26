//
//  ADBCQRSProtocol.h
//  ADBCoreDataStack
//
//  Created by Alberto DeBortoli on 26/07/2016.
//  Copyright © 2016 JUST EAT. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ADBQueryModelProtocol.h"
#import "ADBCommandModelProtocol.h"

@protocol ADBCQRSProtocol <ADBQueryModelProtocol, ADBCommandModelProtocol>

@end
