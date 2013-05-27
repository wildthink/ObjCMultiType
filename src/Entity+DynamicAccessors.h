//
//  Entity+DynamicAccessors.h
//  mDx
//
//  Created by Jobe,Jason on 5/27/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity.h"

#import <objc/runtime.h>

@interface Entity (DynamicAccessors)

+ (void)addGetterNamed:(NSString*)getterName
           forProperty:(NSString*)propertyName
                ofType:(NSString*)ptype;

+ (void)addSetterNamed:(NSString*)setterName
           forProperty:(NSString*)propertyName
                ofType:(NSString*)ptype
                policy:(objc_AssociationPolicy)policy;

@end
