//
//  Entity+DynamicAccessors.m
//  mDx
//
//  Created by Jobe,Jason on 5/27/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import "Entity+DynamicAccessors.h"
#import "entity_i.h"


@implementation Entity (DynamicAccessors)

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
    
    // NOTE: we hard-wire to OBJC_ASSOCIATION_RETAIN for C types that we are auto-boxing
    switch (ch) {
        case 'c':
        case 'C': {
            addMethodBlock (self, setterName, "@c:", ^void(id _s, char _v){
                [_s setValue:[NSNumber numberWithChar:_v] forKey:propertyName policy:OBJC_ASSOCIATION_RETAIN];
            });
        }
            break;
        case 's':
        case 'S': {
            addMethodBlock (self, setterName, "@s:", ^void(id _s, short _v){
                [_s setValue:[NSNumber numberWithShort:_v] forKey:propertyName policy:OBJC_ASSOCIATION_RETAIN];
            });
        }
            break;
        case 'i':
        case 'I': {
            addMethodBlock (self, setterName, "@i:", ^void(id _s, int _v){
                [_s setValue:[NSNumber numberWithInt:_v] forKey:propertyName policy:OBJC_ASSOCIATION_RETAIN];
            });
        }
            break;
        case 'l':
        case 'L': {
            addMethodBlock (self, setterName, "@l:", ^void(id _s, long _v){
                [_s setValue:[NSNumber numberWithLong:_v] forKey:propertyName policy:OBJC_ASSOCIATION_RETAIN];
            });
        }
            break;
        case 'q':
        case 'Q': {
            addMethodBlock (self, setterName, "@q:", ^void(id _s, long long _v){
                [_s setValue:[NSNumber numberWithLongLong:_v] forKey:propertyName policy:OBJC_ASSOCIATION_RETAIN];
            });
        }
            break;
            
        case 'f': {
            addMethodBlock (self, setterName, "@f:", ^void(id _s, float _v){
                [_s setValue:[NSNumber numberWithFloat:_v] forKey:propertyName policy:OBJC_ASSOCIATION_RETAIN];
            });
        }
            break;
            
        case 'd': {
            addMethodBlock (self, setterName, "@d:", ^void(id _s, double _v){
                [_s setValue:[NSNumber numberWithDouble:_v] forKey:propertyName policy:OBJC_ASSOCIATION_RETAIN];
            });
        }
            break;
            
        case '@':
        case '#': // Class
        {
            addMethodBlock (self, setterName, "@@:", ^void(id _s, id _v){
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

@end
