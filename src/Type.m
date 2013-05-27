//
//  Type.m
//
//  Created by Jobe,Jason on 5/21/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Type.h"
#import "Entity.h"

@interface Type ()
@property (strong, readwrite, nonatomic) NSMutableSet *includedTypes;
@end


@implementation Type

static NSMutableDictionary *type_cache = nil;

+ (void)initialize
{
    // do once
    if (type_cache == nil)
        type_cache = [NSMutableDictionary dictionary];
}

+ typeForClass:(Class)iClass {
    return [self typeForClass:iClass ns:nil];
}

+ typeForClass:(Class)iClass ns:(NSString*)ns
{
    return [self typeNamed:NSStringFromClass(iClass) inNamespace:ns implementationClass:iClass];
}

+ typeNamed:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)iClass;
{
    NSString *key = NSStringFromClass(iClass);
    Type *type = [type_cache objectForKey:key];
    if (! type) {
        type = [[[self class] alloc] initWithName:key inNamespace:ns implementationClass:iClass];
        [type_cache setObject:type forKey:key];
    }
    return type;
}

+ typeFor:typeDesignation
{
    // Its a Class proper
    if ([typeDesignation respondsToSelector:@selector(isSubclassOfClass:)]) {
        return [self typeForClass:(Class)typeDesignation];
    }
    // If already a Type make sure its in our cache
    else if ([typeDesignation isKindOfClass:[Type class]]) {
        Type *td = (Type*)typeDesignation;
        Type *t = [type_cache valueForKey:td.name];
        if (t) {
            return t;
        } else {
            [type_cache setObject:td forKey:td.name];
            return td;
        }
    }
    else if ([typeDesignation isKindOfClass:[NSString class]]) {
        Class t_class = NSClassFromString(typeDesignation);
        return [self typeForClass:t_class];
    }
    else {
        return nil;
    }
}

- initWithName:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)implClass;
{
    self.namespace = ns;
    self.name = aName;
    self.implClass = implClass;
    self.includedTypes = [NSMutableSet set];
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
    if ([self.includedTypes containsObject:aType]) {
        return;
    }
    
    // remove redundant types
    NSMutableSet *toKeep = [NSMutableSet set];
    for (Type *t in self.includedTypes) {
        if (![t doesIncludeType:aType])
            [toKeep addObject:t];
    }
    [toKeep addObject:aType];
}

- (void)removeIncludedType:(Type*)aType;
{
    [(NSMutableSet*)_includedTypes removeObject:aType];
}

- (BOOL)doesIncludeType:(Type*)aType
{
    if (aType == self)
        return YES;
    
    if ([self.implClass isSubclassOfClass:aType.implClass])
        return YES;
    
    for (Type *t in self.includedTypes) {
        if ([aType doesIncludeType:aType]) {
             return YES;
        }
    }
    return NO;
}

- instantiateEntity:(Entity*)ent {
    return [[self.implClass alloc] initWithEntity:ent];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"<Type %@ :: %@>", self.name, self.includedTypes];
}

@end
