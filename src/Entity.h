//
//  Entity.h
//  mDx
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Type;

@interface Entity : NSObject

@property (readonly) NSInteger  sed; // simple entity designation
@property (readonly, nonatomic) NSSet *types;


- initWithEntity:(Entity*)aObject;

- (Type*)preferredType;

/**
 Returns self cast into type if it is one.
 If type is NOT a member of types then nil is returned;
*/
- asType:type;

- (BOOL)isaType:type;

/** nil if no conforming type Class is found
 */
- asTypeConformingToProtocol:(Protocol*)proto;

/**
 Returns self as type, adopting type if required.
 */
- becomeType:type;

/*
 This does NOT compare properties. It only confirms that self and otherEntity
 are semantically the same.
 */
- (BOOL)isSameEntity:(Entity*)otherEntity;

@end
