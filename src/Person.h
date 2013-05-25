//
//  Person.h
//  mDx
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Topic.h"

@interface Person : Topic

@property (strong, nonatomic) NSDate* birthDate;
@property (readonly) NSString* age;
@property NSInteger count;

@end
