//
//  KBTrackConfig.h
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#pragma mark - Track 配置

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KBTrackConfig : NSObject
/**
 自动采集默认需要过滤的控制器列表
 */
@property(copy,nonatomic) NSArray* controllers;

+ (NSArray*)controllers;

@end

NS_ASSUME_NONNULL_END
