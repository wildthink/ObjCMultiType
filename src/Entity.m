//
//  Entity.m
//  mDx
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity.h"

@interface entity_i : NSObject
{
    @package
    NSInteger pid;
    NSSet *classTypes;
    Type *preferredType;
    NSMutableDictionary *properties;
}


@end

@implementation entity_i

- (BOOL)conformsToProtocolType:(Protocol*)protocol;
{
    for (Class c in classTypes) {
        if ([c conformsToProtocol:protocol])
            return YES;
    }
    return NO;
}

- (id)valueForKey:(NSString *)key
{
    return [properties valueForKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    [properties setValue:value forKey:key];
}

- (void)disassociateFrom:(Type*)superType;
{
    
}

@end

BOOL WTIsProtocol (id type) {
    NSString *name = NSStringFromProtocol(type);
    return (name != nil);
}

BOOL WTIsClass (id type) {
    NSString *name = NSStringFromClass(type);
    return (name != nil);
}

Class WTAsClass (id type) {
    
    Class t_class;

    if ([type isKindOfClass:[NSString class]]) {
        t_class = NSClassFromString(type);
    } else if (WTIsClass(type)){
        t_class = (Class)type;
    } else {
        t_class = Nil;
    }
    return t_class;
}


@interface Entity()
    @property (strong, nonatomic) entity_i *internal;
@end

@implementation Entity

+ entityWithEntity:(Entity*)anObject;
{
    id ent = [[self alloc] initWithEntity:anObject];
    return ent;
}

- init {
    _internal = [[entity_i alloc] init];
    return self;
}

- initWithEntity:(Entity*)anObject;
{
    if ([anObject.types containsObject:[self class]])
        _internal= anObject->_internal;
    
    return self;
}

- (NSInteger)sed {
    return _internal->pid;
}

- (Type*)preferredType {
    return nil;
}

- (void)disassociateFrom:(Type*)superType;
{
    [_internal disassociateFrom:superType];
}

- (NSSet*)types {
    return _internal->classTypes;
}

- asType:type
{
    Class t_class = WTAsClass (type);

    if (t_class == Nil)
        return nil;
    
    Class classToBe = Nil;
    
    for (Class myType in _internal->classTypes) {
        if ([myType isSubclassOfClass:t_class]) {
            classToBe = myType;
            break;
        }
    }
    return (classToBe ? [[classToBe class] entityWithEntity:self] : nil);
}

- (BOOL)isaType:type {
    return NO;
}

- asTypeConformingToProtocol:(Protocol*)proto;
{
    Class classToBe = Nil;
    
    for (Class myType in _internal->classTypes) {
        if ([myType conformsToProtocol:proto]) {
            classToBe = myType;
            break;
        }
    }
    return (classToBe ? [[classToBe class] entityWithEntity:self] : nil);
}

/**
 Returns self as type, adopting type if required.
 */

- becomeType:type
{
    Class t_class = WTAsClass (type);
    
    if ([type isKindOfClass:[NSString class]]) {
        t_class = NSClassFromString(type);
    } else if (WTIsClass(type)){
        t_class = (Class)type;
    } else {
        [NSException raise:@"Illegal type designator" format:@"%@ is NOT a Class or String", type];
    }
    return [[[type class] alloc] initWithEntity:self];
}

- (BOOL)isSameEntity:(Entity*)otherEntity;
{
    return _internal->pid == otherEntity->_internal->pid;
}

#pragma KeyValue overrides

- (id)valueForUndefinedKey:(NSString *)key
{
    return [_internal->properties valueForKey:key];
}

- (id)valueForKey:(NSString *)key
{
    return [_internal->properties valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    [_internal->properties setValue:value forKey:key];
}

- (void)setValue:(id)value forKey:(NSString *)key
{

}


@end
