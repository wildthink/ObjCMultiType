//
//  Entity.m
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity.h"
#import "Type.h"
#import "entity_i.h"
#import "Entity+DynamicAccessors.h"

#import <objc/runtime.h>

@interface entity_i (EntityPrivate)
- (void)setValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy;
@end


static BOOL _WTIsProtocol (id type) {
    NSString *name = NSStringFromProtocol(type);
    return (name != nil);
}

static BOOL _WTIsClass (id type) {
    NSString *name = NSStringFromClass(type);
    return (name != nil);
}

static Class WTAsClass (id type) {
    
    Class t_class;
    
    if ([type isKindOfClass:[NSString class]]) {
        t_class = NSClassFromString(type);
    } else if ([type isKindOfClass:[Type class]]) {
        t_class = ((Type*)type).implClass;
    } else if (_WTIsClass(type)){
        t_class = (Class)type;
    } else {
        t_class = Nil;
    }
    return t_class;
}

static BOOL areGUIDSEqual (CFUUIDRef g1, CFUUIDRef g2) {
    CFUUIDBytes gb1 = CFUUIDGetUUIDBytes(g1);
    CFUUIDBytes gb2 = CFUUIDGetUUIDBytes(g2);
    size_t size = sizeof(gb1);
    int cmp = memcmp(&gb1, &gb2, size);
    return (cmp == 0);
}

//////////////////////////  ENTITY  /////////////////////////////////////////

@interface Entity()
    @property (strong, nonatomic) entity_i *internal;
@end


@implementation Entity


+ entityWithEntity:(Entity*)anObject;
{
    if ([anObject isKindOfClass:[self class]])
        return anObject;
    // else
    id ent = [[self alloc] initWithEntity:anObject];
    return ent;
}

- init {
    _internal = [[entity_i alloc] init];
    [_internal includeType:[Type typeForClass:[self class]]];
    return self;
}

- initWithEntity:(Entity*)anObject;
{
    _internal= anObject->_internal;
    [_internal includeType:[Type typeForClass:[self class]]];
    return self;
}

- (CFUUIDRef)guid {
    return _internal->guid;
}

- (NSString*)sguid {
    return [_internal guidString];
}

- (Type*)preferredType {
    return (_internal->preferredType ? _internal->preferredType : [_internal->e_types firstObject]);
}

- (void)disassociateFrom:(Type*)superType;
{
    [_internal removeIncludedType:superType];
}

/**
 A Set of Types
 */
- (NSOrderedSet*)types {
    return _internal->e_types;
}

- as_a:type
{
    Type *t = [Type typeFor:type];

    if (t == nil)
        return nil;
    
    if ([[self class] isSubclassOfClass:t.implClass])
        return self;
    
    for (Type *myType in _internal->e_types) {
        if ([myType doesIncludeType:t])
            return [myType instantiateEntity:self];
    }
    return nil;
}

- (BOOL)is_a:type
{
    Type *t_type = [Type typeFor:type];
    
    if (t_type == nil)
        return NO;
    
    if ([[self class] isSubclassOfClass:t_type.implClass])
        return YES;
    
    for (Type *myType in _internal->e_types) {        
        if ([myType doesIncludeType:t_type])
            return YES;
    }
    return NO;
}

- becomeTypeConformingToProtocol:(Protocol*)proto;
{
    Class classToBe = Nil;
    
    for (Type *myType in _internal->e_types) {
        if ([myType conformsToTypeProtocol:proto]) {
            classToBe = myType.implClass;
            break;
        }
    }
    return (classToBe ? [[classToBe class] entityWithEntity:self] : nil);
}

/**
 This is much less expensive alternative to forwardInvocation
 */

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    
    for (Type *myType in _internal->e_types) {
        if ([myType typeInstancesRespondToSelector:aSelector]) {
            return [self as_a:myType];
        }
    }
    // else
    return [super forwardingTargetForSelector:aSelector];
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    for (Type *myType in _internal->e_types) {
        if ([myType typeInstancesRespondToSelector:aSelector]) {
            return YES;
        }
    }
    return NO;
}

/**
 Returns self as type, adopting type if required.
 */

- becomeClassForType:type
{
    Type *t = [Type typeFor:type];
    
    if (! t) {
        [NSException raise:@"Illegal type designator" format:@"%@ is NOT a Type, Class or String", type];
    }
    if ([[self class] isSubclassOfClass:t.implClass])
        return self;
    // else
    return [t instantiateEntity:self];
}

- (BOOL)is:(Entity *)otherEntity
{
    return areGUIDSEqual(_internal->guid, otherEntity->_internal->guid);
}

- (BOOL)isIsomorphicTo:(Entity*)otherEntity
{
    return
    ([_internal->strongProperties isEqual:otherEntity->_internal->strongProperties]
     && [_internal->weakProperties isEqual:otherEntity->_internal->weakProperties]);
}


- (NSString*)longDescription
{
    NSMutableString *mstr = [NSMutableString stringWithCapacity:([_internal->strongProperties count] * 4)];
    [mstr appendFormat:@"<%@:%@", self.class, self.sguid];
    
    for (NSString *key in _internal->strongProperties) {
        id val = [self valueForKey:key];
        [mstr appendFormat:@"\n\t%@: %@", key, val];
    }
    [mstr appendString:@">"];
    return mstr;
}

#pragma mark KeyValueOverrides

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_internal valueForKey:key];
}

- (id)valueForKey:(NSString *)key
{
    return [_internal valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [_internal setValue:value forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [_internal setValue:value forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy
{
    [_internal setValue:value forKey:key policy:policy];
}

@end
