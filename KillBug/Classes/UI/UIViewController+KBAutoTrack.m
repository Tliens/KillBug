//
//  UIViewController+KBAutoTrack.m
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#import "UIViewController+KBAutoTrack.h"
#import "KBAutoTrackManager.h"

@implementation UIViewController (KBAutoTrack)

- (void)kb_autotrack_viewWillAppear:(BOOL)animated; {
    [[KBAutoTrackManager shared] trackViewWillAppear:self];
    [self kb_autotrack_viewWillAppear:animated];
}

@end
