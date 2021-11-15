//
//  UIView+KBAutoTrack.m
//  KillBug
//
//  Created by 2020 on 2021/3/30.
//

#import "UIView+KBAutoTrack.h"
#import <objc/runtime.h>
#import "KBAutoTrackManager.h"
/// https://shixiong.name/2019/03/01/the-right-way-to-swizzling/index.html
static IMP __original_TouchesBegan_Method_Imp;

@implementation UIView (KBAutoTrack)

+ (void)kb_autoTrack {
    
    Class class = [self class];
    
    SEL originalSelector = @selector(touchesBegan:withEvent:);
    SEL swizzledSelector = @selector(kb_touchesBegan:withEvent:);
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    __original_TouchesBegan_Method_Imp = method_getImplementation(originalMethod);
    
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)kb_touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //获取触摸对象
    UITouch * touch = touches.anyObject;
    CGPoint p = [touch locationInView:touch.view];
    NSString *content = @"";
    if ([touch.view isKindOfClass:[UILabel class]]){
        content = ((UILabel*)touch.view).text;
    }
    if (touch.tapCount == 1){
        NSString *info = [[NSString alloc] initWithFormat:@"单击 位置 x:%f y:%f",p.x,p.y];
        [[KBAutoTrackManager shared] trackTouch:info];

    }else if (touch.tapCount == 2){
        NSString *info = [[NSString alloc] initWithFormat:@"双击 位置 x:%f y:%f",p.x,p.y];
        [[KBAutoTrackManager shared] trackTouch:info];
    }else{
        NSString *info = [[NSString alloc] initWithFormat:@"%ld次 位置 x:%f y:%f",touch.tapCount,p.x,p.y];
        [[KBAutoTrackManager shared] trackTouch:info];
    }

    
    void (*functionPointer)(id, SEL, NSSet<UITouch *> *, UIEvent *) = (void(*)(id, SEL, NSSet<UITouch *> *, UIEvent*))__original_TouchesBegan_Method_Imp;
    functionPointer(self, _cmd, touches, event);
}
@end
