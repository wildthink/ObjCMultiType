//
//  Type.m
//
//  Created by Jobe,Jason on 5/21/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Type.h"

@interface Type ()
@property (strong, readwrite, nonatomic) NSMutableSet *includedTypes;
@end


@implementation Type

+ typeForClass:(Class)iClass {
    return [[[self class] alloc] initWithName:NSStringFromClass(iClass) inNamespace:nil implementationClass:iClass];
}

+ typeForClass:(Class)iClass ns:(NSString*)ns {
    return [[[self class] alloc] initWithName:NSStringFromClass(iClass) inNamespace:ns implementationClass:iClass];
}

+ typeNamed:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)implClass;
{
    return [[[self class] alloc] initWithName:aName inNamespace:ns implementationClass:implClass];
}

- initWithName:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)implClass;
{
    self.namespace = ns;
    self.name = aName;
    self.implClass = implClass;
    return self;
}


- (BOOL)conformsToTypeProtocol:(Protocol *)aProtocol;
{
    if ([self.implClass conformsToProtocol:aProtocol])
        return YES;

    for (Type *t in self.includedTypes) {
        if ([t conformsToTypeProtocol:aProtocol]) {
            return YES;
        }
    }
    return NO;
}

- typeInstancesRespondToSelector:(SEL)aSelector;
{
    if ([self.implClass instancesRespondToSelector:aSelector])
        return self;
    
    for (Type *t in self.includedTypes) {
        if ([t typeInstancesRespondToSelector:aSelector]) {
            return t;
        }
    }
    return nil;
}

/**
 If self is a subtype of atype then do nothing
 If atype is a subtype of any currently included type then remove the old type
 */

- (void)includeType:(Type*)aType;
{
    if ([self isaType:aType]) {
        return;
    }
    
    // remove redundant types
    NSMutableSet *toKeep = [NSMutableSet set];
    for (Type *t in self.includedTypes) {
        if (![t isaType:aType])
            [toKeep addObject:t];
    }
    [toKeep addObject:aType];
}

- (void)removeIncludedType:(Type*)aType;
{
    [(NSMutableSet*)_includedTypes removeObject:aType];
}

- (BOOL)isaType:(Type*)aType
{
    if (aType == self)
        return YES;
    
    if ([self.implClass isKindOfClass:aType.implClass])
        return YES;
    
    for (Type *t in self.includedTypes) {
        if ([aType isaType:aType]) {
             return YES;
        }
    }
    return NO;
}

@end
