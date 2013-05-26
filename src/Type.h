//
//  Type.h
//  mDx
//
//  Created by Jobe,Jason on 5/21/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//  Perhaps Taxon is a better name.
//

#import <Foundation/Foundation.h>

@interface Type : NSObject

@property (strong, nonatomic) NSString *namespace;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Class implClass;
@property (strong, nonatomic) NSSet *includedTypes;

+ typeNamed:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)implClass;
+ typeForClass:(Class)iClass ns:(NSString*)ns;
+ typeForClass:(Class)iClass;

- initWithName:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)implClass;

- (void)includeType:(Type*)superType;
- (void)removeIncludedType:(Type*)superType;

- (BOOL)isaType:(Type*)aType;
- (BOOL)conformsToTypeProtocol:(Protocol *)aProtocol;

@end
