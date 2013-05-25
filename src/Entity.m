//
//  Entity.m
//  mDx
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity.h"
#import <objc/runtime.h>


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

- (id)init{
    self = [super init];
    pid = 123;
    properties = [NSMutableDictionary dictionary];
    return self;
}

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

void addMethodBlock (Class c, NSString *gname, const char *signature, id block)
{
    IMP getterIMP = imp_implementationWithBlock(block);
    class_addMethod(c, NSSelectorFromString(gname), getterIMP, signature);
}
/*
 Table 6-1  Objective-C type encodings
 Code
 Meaning
 c A char
 C An unsigned char
 i An int
 I An unsigned int
 s A short
 S An unsigned short
 l A long l is treated as a 32-bit quantity on 64-bit programs.
 L An unsigned long
 q A long long
 Q An unsigned long long
 f A float
 d A double
 B A C++ bool or a C99 _Bool
 v A void
 * A character string (char *)
 @ An object (whether statically typed or typed id)
 # A class object (Class)
 : A method selector (SEL)
 [array type] An array
 {name=type...} A structure
 (name=type...) A union
 bnum A bit field of num bits
 ^type A pointer to type
 ? An unknown type (among other things, this code is used for function pointers)
*/

+ (void)addGetterNamed:(NSString*)getterName forProperty:(NSString*)propertyName ofType:(NSString*)ptype
{
    unichar ch = [ptype characterAtIndex:0];
    
    switch (ch) {
        case 'c':
        case 'C': {
            addMethodBlock (self, getterName, "c@:", ^char(id _s){
                return [[_s valueForKey:propertyName] charValue];
            });
        }
            break;
        case 's':
        case 'S': {
            addMethodBlock (self, getterName, "s@:", ^short(id _s){
                return [[_s valueForKey:propertyName] shortValue];
            });
        }
            break;
        case 'i':
        case 'I': {
            addMethodBlock (self, getterName, "i@:", ^int(id _s){
                return [[_s valueForKey:propertyName] intValue];
            });
        }
            break;
        case 'l':
        case 'L': {
            addMethodBlock (self, getterName, "@l:", ^long(id _s){
                return [[_s valueForKey:propertyName] longValue];
            });
        }
            break;
        case 'q':
        case 'Q': {
            addMethodBlock (self, getterName, "q@:", ^long long(id _s){
                return [[_s valueForKey:propertyName] longLongValue];
            });
        }
            break;

        case 'f': {
            addMethodBlock (self, getterName, "f@:", ^float(id _s){
                return [[_s valueForKey:propertyName] floatValue];
            });
        }
            break;

        case 'd': {
            addMethodBlock (self, getterName, "d@:", ^double(id _s){
                return [[_s valueForKey:propertyName] doubleValue];
            });
        }
            break;

        case '@':
        case '#': // Class
        {
            addMethodBlock (self, getterName, "@@:", ^id(id _s){
                return [_s valueForKey:propertyName];
            });
        }
            break;
        default:
            NSLog (@"Unsupported type %@", ptype);
    }
}

+ (void)addSetterNamed:(NSString*)setterName forProperty:(NSString*)propertyName ofType:(NSString*)ptype
{
    unichar ch = [ptype characterAtIndex:0];
    
    switch (ch) {
        case 'c':
        case 'C': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, char _v){
                [_s setValue:[NSNumber numberWithChar:_v] forKey:propertyName];
            });
        }
            break;
        case 's':
        case 'S': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, short _v){
                [_s setValue:[NSNumber numberWithShort:_v] forKey:propertyName];
            });
        }
            break;
        case 'i':
        case 'I': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, int _v){
                [_s setValue:[NSNumber numberWithInt:_v] forKey:propertyName];
            });
        }
            break;
        case 'l':
        case 'L': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, long _v){
                [_s setValue:[NSNumber numberWithLong:_v] forKey:propertyName];
            });
        }
            break;
        case 'q':
        case 'Q': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, long long _v){
                [_s setValue:[NSNumber numberWithLongLong:_v] forKey:propertyName];
            });
        }
            break;
            
        case 'f': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, float _v){
                [_s setValue:[NSNumber numberWithFloat:_v] forKey:propertyName];
            });
        }
            break;
            
        case 'd': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, double _v){
                [_s setValue:[NSNumber numberWithDouble:_v] forKey:propertyName];
            });
        }
            break;
            
        case '@':
        case '#': // Class
        {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, id _v){
                [_s setValue:_v forKey:propertyName];
            });
        }
            break;
        default:
            NSLog (@"Unsupported type %@", ptype);
    }
}


+ (BOOL)resolveInstanceMethod:(SEL)sel {
    const char *rawName = sel_getName(sel);
    NSString *name = NSStringFromSelector(sel);
    
    NSString *propertyName = nil;
    
    if ([name hasPrefix:@"set"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(rawName[3]), (rawName+4)];
    } else if ([name hasPrefix:@"is"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(rawName[2]), (rawName+3)];
    } else {
        propertyName = name;
    }
    propertyName = [propertyName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    Class cls = self;
    objc_property_t property = NULL;
    const char *propertyName_cstr = [propertyName UTF8String];
    for (cls = self; cls != nil && property == NULL; cls = [cls superclass]) {
        property = class_getProperty(cls, propertyName_cstr);
    }
    
    if (property == NULL) {
        return NO;
    }
    
    const char *rawPropertyName = property_getName(property);
    propertyName = [NSString stringWithUTF8String:rawPropertyName];
    
    NSString *getterName = nil;
    NSString *setterName = nil;
    NSString *propertyType = nil;
    BOOL isReadonly = NO;
    BOOL isAtomic = YES;
    objc_AssociationPolicy policy = OBJC_ASSOCIATION_ASSIGN;
    
    NSString *propertyInfo = [NSString stringWithUTF8String:property_getAttributes(property)];
    NSArray *propertyAttributes = [propertyInfo componentsSeparatedByString:@","];
    
    for (NSString *attribute in propertyAttributes) {
        if ([attribute hasPrefix:@"G"] && getterName == nil) {
            getterName = [attribute substringFromIndex:1];
        } else if ([attribute hasPrefix:@"S"] && setterName == nil) {
            setterName = [attribute substringFromIndex:1];
        } else if ([attribute hasPrefix:@"t"] && propertyType == nil) {
            propertyType = [attribute substringFromIndex:1];
        } else if ([attribute hasPrefix:@"T"] && propertyType == nil) {
            propertyType = [attribute substringFromIndex:1];
        } else if ([attribute isEqualToString:@"N"]) {
            isAtomic = NO;
        } else if ([attribute isEqualToString:@"R"]) {
            isReadonly = YES;
        } else if ([attribute isEqualToString:@"C"]) {
            policy = OBJC_ASSOCIATION_COPY;
        } else if ([attribute isEqualToString:@"&"]) {
            policy = OBJC_ASSOCIATION_RETAIN;
        }
    }
    
    if (getterName == nil) {
        getterName = propertyName;
    }
    
    [self addGetterNamed:getterName forProperty:propertyName ofType:propertyType];
    
    if (isReadonly == NO) {
        if (setterName == nil) {
            setterName = [NSString stringWithFormat:@"set%c%s:", toupper(rawPropertyName[0]), (rawPropertyName+1)];
        }
        [self addSetterNamed:setterName forProperty:propertyName ofType:propertyType];
    }    
    return YES;
}

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
    [_internal->properties setValue:value forKey:key];
}


@end
