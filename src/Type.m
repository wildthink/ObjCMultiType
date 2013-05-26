//
//  Type.m
//
//  Created by Jobe,Jason on 5/21/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Type.h"

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

- (void)includeType:(Type*)superType;
{
    if (! [self isaType:superType]) {
        self.includedTypes = [self.includedTypes setByAddingObject:superType];
    }
}

- (void)removeIncludedType:(Type*)superType;
{
    [NSException raise:@"Not Implemented" format:@"%@", NSStringFromSelector(_cmd)];
}

- (BOOL)isaType:(Type*)aType
{
    if (aType == self)
        return YES;
    
    for (Type *t in self.includedTypes) {
        if ([aType isaType:aType]) {
             return YES;
        }
    }
    return NO;
}

@end
