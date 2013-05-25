//
//  Topic.h
//  mDx
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity.h"

@interface Topic : Entity

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *summary;
@property (strong, nonatomic) CIImage *image;

+ entityNamed:(NSString*)name;

@end
