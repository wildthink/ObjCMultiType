//
//  Entity.m
//
//  Created by Jobe,Jason on 4/24/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity.h"
#import "Type.h"

#import <objc/runtime.h>


@interface entity_i : NSObject
{
    @package
    CFUUIDRef guid;
    Type *preferredType;
    NSSet *classTypes;
    NSMapTable *strongProperties;
    NSMapTable *weakProperties;
}


@end

@implementation entity_i

- (id)init{
    self = [super init];
    guid = CFUUIDCreate(NULL);
    weakProperties = [NSMapTable strongToWeakObjectsMapTable];
    strongProperties = [NSMapTable strongToStrongObjectsMapTable];
    classTypes = [NSSet set];
    return self;
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
    for (Class c in classTypes) {
        if ([c conformsToProtocol:protocol])
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

- (void)disassociateFrom:(Type*)superType;
{
    
}

- (void)includeType:ctype
{
    if (! [classTypes containsObject:ctype]) {
        classTypes = [classTypes setByAddingObject:ctype];
    }
}

@end
////////////////   END entity_i /////////////////////////////


static BOOL WTIsProtocol (id type) {
    NSString *name = NSStringFromProtocol(type);
    return (name != nil);
}

static BOOL WTIsClass (id type) {
    NSString *name = NSStringFromClass(type);
    return (name != nil);
}

static Class WTAsClass (id type) {
    
    Class t_class;

    if ([type isKindOfClass:[NSString class]]) {
        t_class = NSClassFromString(type);
    } else if ([type isKindOfClass:[Type class]]) {
        t_class = ((Type*)type).implClass;
    } else if (WTIsClass(type)){
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

+ (void)addGetterNamed:(NSString*)getterName
           forProperty:(NSString*)propertyName
                ofType:(NSString*)ptype
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

+ (void)addSetterNamed:(NSString*)setterName
           forProperty:(NSString*)propertyName
                ofType:(NSString*)ptype
                policy:(objc_AssociationPolicy)policy
{
    unichar ch = [ptype characterAtIndex:0];
    
    switch (ch) {
        case 'c':
        case 'C': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, char _v){
                [_s setValue:[NSNumber numberWithChar:_v] forKey:propertyName policy:policy];
            });
        }
            break;
        case 's':
        case 'S': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, short _v){
                [_s setValue:[NSNumber numberWithShort:_v] forKey:propertyName policy:policy];
            });
        }
            break;
        case 'i':
        case 'I': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, int _v){
                [_s setValue:[NSNumber numberWithInt:_v] forKey:propertyName policy:policy];
            });
        }
            break;
        case 'l':
        case 'L': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, long _v){
                [_s setValue:[NSNumber numberWithLong:_v] forKey:propertyName policy:policy];
            });
        }
            break;
        case 'q':
        case 'Q': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, long long _v){
                [_s setValue:[NSNumber numberWithLongLong:_v] forKey:propertyName policy:policy];
            });
        }
            break;
            
        case 'f': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, float _v){
                [_s setValue:[NSNumber numberWithFloat:_v] forKey:propertyName policy:policy];
            });
        }
            break;
            
        case 'd': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, double _v){
                [_s setValue:[NSNumber numberWithDouble:_v] forKey:propertyName policy:policy];
            });
        }
            break;
            
        case '@':
        case '#': // Class
        {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, id _v){
                [_s setValue:_v forKey:propertyName policy:policy];
            });
        }
            break;
        default:
            NSLog (@"Unsupported type %@", ptype);
    }
}

+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    const char *cstrName = sel_getName(sel);
    NSString *name = NSStringFromSelector(sel);
    
    NSString *propertyName = nil;
    
    if ([name hasPrefix:@"set"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(cstrName[3]), (cstrName+4)];
    } else if ([name hasPrefix:@"is"]) {
        propertyName = [NSString stringWithFormat:@"%c%s", tolower(cstrName[2]), (cstrName+3)];
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
        [self addSetterNamed:setterName forProperty:propertyName ofType:propertyType policy:policy];
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
    _internal= anObject->_internal;
    [_internal includeType:[self class]];
    return self;
}

- (CFUUIDRef)guid {
    return _internal->guid;
}

- (NSString*)sguid {
    return [_internal guidString];
}

- (Type*)preferredType {
    return _internal->preferredType;
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

- (BOOL)isaType:type
{
    Class t_class = WTAsClass (type);
    
    if (t_class == Nil)
        return NO;
        
    for (Class myType in _internal->classTypes) {
        if ([myType isSubclassOfClass:t_class]) {
            return YES;
        }
    }
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
 This is much less expensive alternative to forwardInvocation
 */

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    
    for (Class myType in _internal->classTypes) {
        if ([myType instancesRespondToSelector:aSelector]) {
            return [self asType:myType];
        }
    }

//    Type *type = [self firstTypePerformingSelector:aSelector]
//    if (type)
//        return [self asType:type];
    // else
    return [super forwardingTargetForSelector:aSelector];
}

/**
 Returns self as type, adopting type if required.
 */

- becomeType:type
{
    Class t_class = WTAsClass (type);
    
    if (! t_class) {
        [NSException raise:@"Illegal type designator" format:@"%@ is NOT a Class or String", type];
    }
    return [[t_class alloc] initWithEntity:self];
}

- (BOOL)isSameEntityAs:(Entity*)otherEntity;
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
