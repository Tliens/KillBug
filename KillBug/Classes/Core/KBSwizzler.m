//
//  KBSwizzle.m
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#import "KBSwizzler.h"
#import <objc/runtime.h>
#define MAPTABLE_ID(x) (__bridge id)((void *)x)

#define MIN_ARGS 2
#define MAX_ARGS 4
@interface KBSwizzle:NSObject

@property (nonatomic, assign) Class class;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, assign) IMP originalMethod;
@property (nonatomic, assign) uint numArgs;
@property (nonatomic, copy) NSMapTable *blocks;

- (instancetype)initWithBlock:(swizzleBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod;

@end

static NSMapTable *swizzles;

static void kb_swizzledMethod_2(id self, SEL _cmd) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    KBSwizzle *swizzle = (KBSwizzle *)[swizzles objectForKey:MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL))swizzle.originalMethod)(self, _cmd);
        
        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
           
            block(self, _cmd);
        }
    }
}
static void kb_swizzledMethod_3(id self, SEL _cmd, id arg) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    KBSwizzle *swizzle = (KBSwizzle *)[swizzles objectForKey:MAPTABLE_ID(aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id))swizzle.originalMethod)(self, _cmd, arg);
        
        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg);
        }
    }
}

static void kb_swizzledMethod_4(id self, SEL _cmd, id arg, id arg2) {
    Method aMethod = class_getInstanceMethod([self class], _cmd);
    KBSwizzle *swizzle = (KBSwizzle *)[swizzles objectForKey:(__bridge id)((void *)aMethod)];
    if (swizzle) {
        ((void(*)(id, SEL, id, id))swizzle.originalMethod)(self, _cmd, arg, arg2);
        
        NSEnumerator *blocks = [swizzle.blocks objectEnumerator];
        swizzleBlock block;
        while((block = [blocks nextObject])) {
            block(self, _cmd, arg, arg2);
        }
    }
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
static void (*kb_swizzledMethods[MAX_ARGS - MIN_ARGS + 1])() = {kb_swizzledMethod_2, kb_swizzledMethod_3, kb_swizzledMethod_4};
#pragma clang diagnostic pop

@implementation KBSwizzler

+ (void)load {
    swizzles = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsOpaqueMemory | NSPointerFunctionsOpaquePersonality)
                                     valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
}

+ (KBSwizzle *)swizzleForMethod:(Method)aMethod {
    return (KBSwizzle *)[swizzles objectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)removeSwizzleForMethod:(Method)aMethod {
    [swizzles removeObjectForKey:MAPTABLE_ID(aMethod)];
}

+ (void)setSwizzle:(KBSwizzle *)swizzle forMethod:(Method)aMethod {
    [swizzles setObject:swizzle forKey:MAPTABLE_ID(aMethod)];
}

+ (BOOL)isLocallyDefinedMethod:(Method)aMethod onClass:(Class)aClass {
    uint count;
    BOOL isLocal = NO;
    Method *methods = class_copyMethodList(aClass, &count);
    for (NSUInteger i = 0; i < count; i++) {
        if (aMethod == methods[i]) {
            isLocal = YES;
            break;
        }
    }
    free(methods);
    return isLocal;
}

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(swizzleBlock)aBlock
                  named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (!aMethod) {
        NSLog(@"SwizzleException:Cannot find method for %@ on %@",NSStringFromSelector(aSelector), NSStringFromClass(aClass));
        return;
    }
    
    uint numArgs = method_getNumberOfArguments(aMethod);
    if (numArgs < MIN_ARGS || numArgs > MAX_ARGS) {
        NSLog(@"Cannot swizzle method with %d args", numArgs);
    }
    
    IMP swizzledMethod = (IMP)kb_swizzledMethods[numArgs - 2];
    [KBSwizzler swizzleSelector:aSelector onClass:aClass withBlock:aBlock andSwizzleMethod:swizzledMethod named:aName];
}

+ (void)swizzleSelector:(SEL)aSelector
                onClass:(Class)aClass
              withBlock:(swizzleBlock)aBlock
       andSwizzleMethod:(IMP)aSwizzleMethod
                  named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    if (!aMethod) {
        NSLog(@"Cannot find method for %@ on %@", NSStringFromSelector(aSelector), NSStringFromClass(aClass));
    }
    
    BOOL isLocal = [self isLocallyDefinedMethod:aMethod onClass:aClass];
    KBSwizzle *swizzle = [self swizzleForMethod:aMethod];
    
    if (isLocal) {
        if (!swizzle) {
            IMP originalMethod = method_getImplementation(aMethod);
            
            // Replace the local implementation of this method with the swizzled one
            method_setImplementation(aMethod, aSwizzleMethod);
            
            // Create and add the swizzle
            @try {
                swizzle = [[KBSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod];
            } @catch (NSException *exception) {
                NSLog(@"%@ error: %@", self, exception);
            }
            [self setSwizzle:swizzle forMethod:aMethod];
        } else {
            [swizzle.blocks setObject:aBlock forKey:aName];
        }
    } else {
        IMP originalMethod = swizzle ? swizzle.originalMethod : method_getImplementation(aMethod);
        
        // Add the swizzle as a new local method on the class.
        if (!class_addMethod(aClass, aSelector, aSwizzleMethod, method_getTypeEncoding(aMethod))) {
            NSLog(@"Could not add swizzled for %@::%@, even though it didn't already exist locally", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
        }
        // Now re-get the Method, it should be the one we just added.
        Method newMethod = class_getInstanceMethod(aClass, aSelector);
        if (aMethod == newMethod) {
            NSLog(@"Newly added method for %@::%@ was the same as the old method", NSStringFromClass(aClass), NSStringFromSelector(aSelector));
        }
        
        KBSwizzle *newSwizzle = [[KBSwizzle alloc] initWithBlock:aBlock named:aName forClass:aClass selector:aSelector originalMethod:originalMethod];
        [self setSwizzle:newSwizzle forMethod:newMethod];
    }
}

+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    KBSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        method_setImplementation(aMethod, swizzle.originalMethod);
        [self removeSwizzleForMethod:aMethod];
    }
}

/*
 Remove the named swizzle from the given class/selector. If aName is nil, remove all
 swizzles for this class/selector
 */
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName {
    Method aMethod = class_getInstanceMethod(aClass, aSelector);
    KBSwizzle *swizzle = [self swizzleForMethod:aMethod];
    if (swizzle) {
        if (aName) {
            [swizzle.blocks removeObjectForKey:aName];
        }
        if (!aName || [swizzle.blocks count] == 0) {
            method_setImplementation(aMethod, swizzle.originalMethod);
            [self removeSwizzleForMethod:aMethod];
        }
    }
}

@end


@implementation KBSwizzle

- (instancetype)init {
    if ((self = [super init])) {
        self.blocks = [NSMapTable mapTableWithKeyOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPersonality)
                                            valueOptions:(NSPointerFunctionsStrongMemory | NSPointerFunctionsObjectPointerPersonality)];
    }
    return self;
}

- (instancetype)initWithBlock:(swizzleBlock)aBlock
                        named:(NSString *)aName
                     forClass:(Class)aClass
                     selector:(SEL)aSelector
               originalMethod:(IMP)aMethod {
    if ((self = [self init])) {
        self.class = aClass;
        self.selector = aSelector;
        self.originalMethod = aMethod;
        [self.blocks setObject:aBlock forKey:aName];
    }
    return self;
}

- (NSString *)description {
    NSString *descriptors = @"";
    NSString *key;
    NSEnumerator *keys = [self.blocks keyEnumerator];
    while ((key = [keys nextObject])) {
        descriptors = [descriptors stringByAppendingFormat:@"\t%@ : %@\n", key, [self.blocks objectForKey:key]];
    }
    return [NSString stringWithFormat:@"Swizzle on %@::%@ [\n%@]", NSStringFromClass(self.class), NSStringFromSelector(self.selector), descriptors];
}

@end
