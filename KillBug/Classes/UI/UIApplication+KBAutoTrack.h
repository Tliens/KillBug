//
//  UIApplication+KBAutoTrack.h
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#pragma mark - action 交换

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (KBAutoTrack)
- (BOOL)kb_sendAction:(SEL)action
                   to:(nullable id)to
                 from:(nullable id)from
             forEvent:(nullable UIEvent *)event;

@end

NS_ASSUME_NONNULL_END
