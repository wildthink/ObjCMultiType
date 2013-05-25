//
//  Type.m
//  mDx
//
//  Created by Jobe,Jason on 5/21/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Type.h"

@implementation Type

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

- (void)derivesFrom:(Type*)superType
{
    if (![self.superTypes containsObject:superType]) {
        self.superTypes = [self.superTypes setByAddingObject:superType];
    }
}

- (void)disassociateFrom:(Type*)superType;
{
    [NSException raise:@"Not Implemented" format:@"%@", NSStringFromSelector(_cmd)];
}

- (BOOL)isaType:(Type*)aType
{
    if (aType == self)
        return YES;
    
    for (Type *t in self.superTypes) {
        if ([aType isaType:aType]) {
             return YES;
        }
    }
    return NO;
}

@end
