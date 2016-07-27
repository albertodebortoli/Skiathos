//
//  Pet.h
// 
//
//  Created by Alberto De Bortoli on 15/11/2015.
//  Copyright (c) 2015 Alberto De Bortoli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Pet : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) User *relationship;

@end
