//
//  UIViewController+KBAutoTrack.h
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#pragma mark - viewWillAppear 交换

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (KBAutoTrack)
- (void)kb_autotrack_viewWillAppear:(BOOL)animated;
@end

NS_ASSUME_NONNULL_END
