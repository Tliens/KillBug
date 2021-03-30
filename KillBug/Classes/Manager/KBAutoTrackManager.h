//
//  KBAutoTrackManager.h
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#pragma mark - 自动跟踪管理

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DebugInfoHandler)(NSString *info);

@interface KBAutoTrackManager : NSObject

@property(nonatomic,strong)DebugInfoHandler infoHandler;

///单例
+ (instancetype)shared;

/// 普通 UIControl
- (void)trackEventView:(UIView *)view;

/// tableview&collectionview
- (void)trackEventView:(UIView *)view withIndexPath:(nullable NSIndexPath *)indexPath;

/// viewWillAppear
- (void)trackViewWillAppear:(UIViewController *)controller;

/// uiapplication 活跃状态
- (void)trackApplication:(NSString *)state;

/// uiapplication 死亡信息
- (void)trackApplicationDeadReason:(NSString *)reason;

/// 用户的touch事件
- (void)trackTouch:(NSString *)info;

/// 日志回调
- (void)debugInfoHandler:(DebugInfoHandler)handler;

@end

NS_ASSUME_NONNULL_END
