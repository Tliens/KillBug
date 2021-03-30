//
//  KBSwizzler.h
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#pragma mark - 方法交换器

#import <Foundation/Foundation.h>
/// 消除警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
typedef void (^swizzleBlock)();
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@interface KBSwizzler : NSObject
+ (void)swizzleSelector:(SEL)aSelector onClass:(Class)aClass withBlock:(swizzleBlock)block named:(NSString *)aName;
+ (void)unswizzleSelector:(SEL)aSelector onClass:(Class)aClass named:(NSString *)aName;
@end

NS_ASSUME_NONNULL_END
