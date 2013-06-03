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

@property (readonly) CFUUIDRef guid;
@property (readonly) NSString* sguid;
@property (readonly, nonatomic) NSOrderedSet *types;


- initWithEntity:(Entity*)aObject;

- (Type*)preferredType;

/**
 Returns self cast into type if it is one.
 If type is NOT a member of types then nil is returned;
*/
- as_a:type;

-(BOOL)is_a:type;

/** nil if no conforming type Class is found
 */
- becomeTypeConformingToProtocol:(Protocol*)proto;

/**
 Returns self as a potentially new Class for the type, adopting type if required. 
 NOTE: This is likely to be a new instance pointer.
 */
- becomeClassForType:type;

/*
 This does NOT compare properties. It only confirms that self and otherEntity
 are semantically the same.
 */
- (BOOL)is:(Entity*)otherEntity;

/** 
 This methods ONLY compares the properties.
 */
- (BOOL)isIsomorphicTo:(Entity*)otherEntity;


- (NSString*)longDescription;

@end
