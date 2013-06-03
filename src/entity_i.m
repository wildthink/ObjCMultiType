//
//  entity_i.m
//  mDx
//
//  Created by Jobe,Jason on 5/27/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "entity_i.h"
#import "Type.h"


@implementation entity_i

- (id)init{
    self = [super init];
    guid = CFUUIDCreate(NULL);
    weakProperties = [NSMapTable strongToWeakObjectsMapTable];
    strongProperties = [NSMapTable strongToStrongObjectsMapTable];
    e_types = [NSOrderedSet orderedSet];
    return self;
}

- (NSString*)description
{
    NSMutableString *mstr = [NSMutableString stringWithCapacity:([strongProperties count] * 4)];
    [mstr appendFormat:@"<%@:%@", self.class, guid];
    
    [mstr appendString:@"strong: {\n"];
    for (NSString *key in strongProperties) {
        id val = [self valueForKey:key];
        [mstr appendFormat:@"\n\t%@: %@", key, val];
    }
    [mstr appendString:@"\n}\n"];
    
    [mstr appendString:@"weak: {\n"];
    for (NSString *key in weakProperties) {
        id val = [self valueForKey:key];
        [mstr appendFormat:@"\n\t%@: %@", key, val];
    }
    [mstr appendString:@"\n}\n"];
    
    [mstr appendString:@"\n>"];
    return mstr;
}

- (CFUUIDRef) guid {
    return guid;
}

- (NSString *)guidString
{
    CFStringRef string = CFUUIDCreateString(NULL, guid);
    return CFBridgingRelease(string);
}

- (BOOL)conformsToProtocolType:(Protocol*)protocol;
{
    for (Type *t in e_types) {
        if ([t conformsToTypeProtocol:protocol])
            return YES;
    }
    return NO;
}

- (id)valueForKey:(NSString *)key
{
    id anon = [strongProperties objectForKey:key];
    if (anon == nil)
        anon = [weakProperties objectForKey:key];
    return anon;
}

- (void)setValue:(id)value forKey:(NSString *)key
{
    return [self setValue:value forKey:key policy:OBJC_ASSOCIATION_RETAIN];
}

- (void)setValue:(id)value forKey:(NSString *)key policy:(objc_AssociationPolicy)policy
{
    if (value == nil) {
        [weakProperties removeObjectForKey:key];
        [strongProperties removeObjectForKey:key];
        return;
    }
    // else
    switch (policy) {
        case OBJC_ASSOCIATION_ASSIGN:
            [weakProperties setObject:value forKey:key];
            break;
        case OBJC_ASSOCIATION_RETAIN_NONATOMIC:
        case OBJC_ASSOCIATION_RETAIN:
            [strongProperties setObject:value forKey:key];
            break;
        case OBJC_ASSOCIATION_COPY:
        case OBJC_ASSOCIATION_COPY_NONATOMIC:
            [strongProperties setObject:[value copy] forKey:key];
            break;
    }
}

- (void)removeIncludedType:(Type*)superType;
{
    [(NSMutableSet*)e_types removeObject:superType];
}

- (void)includeType:(Type*)aType;
{
    if ([e_types containsObject:aType]) {
        return;
    }
    
    // remove redundant types
    NSMutableOrderedSet *toKeep = [NSMutableOrderedSet orderedSet];
    for (Type *t in e_types) {
        if (![aType doesIncludeType:t])
            [toKeep addObject:t];
    }
    [toKeep addObject:aType];
    e_types = toKeep;
}

@end

