//
//  KBAutoTrackManager.h
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#pragma mark - 自动跟踪管理

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KBAutoTrackManager : NSObject
+ (instancetype)shared;
/// 普通 UIControl
- (void)trackEventView:(UIView *)view;
/// tableview&collectionview
- (void)trackEventView:(UIView *)view withIndexPath:(nullable NSIndexPath *)indexPath;
/// viewcontroller
- (void)trackViewControlWillAppear:(UIViewController *)controller;
/// uiapplication 活跃状态
- (void)trackApplication:(NSString *)state;
/// uiapplication 死亡信息
- (void)trackApplicationDeadReason:(NSString *)reason;
/// 用户的touch事件
- (void)trackTouch:(NSString *)info;
@end

NS_ASSUME_NONNULL_END
