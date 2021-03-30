//
//  NSObject+KBSwizzle.h
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//
#pragma mark - NSObject 类的方法交换

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KBSwizzle)
+ (BOOL)kb_swizzleMethod:(SEL)origSel_ withMethod:(SEL)altSel_ error:(NSError **)error_;
+ (BOOL)kb_swizzleClassMethod:(SEL)origSel_ withClassMethod:(SEL)altSel_ error:(NSError **)error_;

@end

NS_ASSUME_NONNULL_END
