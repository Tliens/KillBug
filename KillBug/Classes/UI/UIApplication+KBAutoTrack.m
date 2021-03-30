//
//  UIApplication+KBAutoTrack.m
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#import "UIApplication+KBAutoTrack.h"
#import "KBAutoTrackManager.h"

@implementation UIApplication (KBAutoTrack)
- (BOOL)kb_sendAction:(SEL)action to:(id)to from:(id)from forEvent:(UIEvent *)event; {
    if ([from isKindOfClass:[UIControl class]]) {
        //UISegmentedControl  UISwitch  UIStepper  UISlider
        if (([from isKindOfClass:[UISwitch class]] ||
            [from isKindOfClass:[UISegmentedControl class]] ||
            [from isKindOfClass:[UIStepper class]])) {
            [[KBAutoTrackManager shared] trackEventView:from];
        }
        
        //UIButton UIPageControl UITabBarButton _UIButtonBarButton
        else if ([event isKindOfClass:[UIEvent class]] && event.type == UIEventTypeTouches && [[[event allTouches] anyObject] phase] == UITouchPhaseEnded) {
            [[KBAutoTrackManager shared] trackEventView:from];
        }
    }
    
    return [self kb_sendAction:action to:to from:from forEvent:event];
}

@end
