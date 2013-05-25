//
//  Type.h
//  mDx
//
//  Created by Jobe,Jason on 5/21/13.
//  Copyright (c) 2013 Jobe,Jason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Type : NSObject

@property (strong, nonatomic) NSString *namespace;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) Class implClass;
@property (strong, nonatomic) NSSet *superTypes;

+ typeNamed:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)implClass;

- initWithName:(NSString*)aName inNamespace:(NSString*)ns implementationClass:(Class)implClass;

- (void)derivesFrom:(Type*)superType;
- (void)disassociateFrom:(Type*)superType;

- (BOOL)isaType:(Type*)aType;

@end
