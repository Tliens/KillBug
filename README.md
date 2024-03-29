# KillBug

[![CI Status](https://img.shields.io/travis/tliens/KillBug.svg?style=flat)](https://travis-ci.org/tliens/KillBug)
[![Version](https://img.shields.io/cocoapods/v/KillBug.svg?style=flat)](https://cocoapods.org/pods/KillBug)
[![License](https://img.shields.io/cocoapods/l/KillBug.svg?style=flat)](https://cocoapods.org/pods/KillBug)
[![Platform](https://img.shields.io/cocoapods/p/KillBug.svg?style=flat)](https://cocoapods.org/pods/KillBug)

![img](https://github.com/Tliens/KillBug/blob/main/logo.png)

## 揪心的bug

我们通过第三方工具分析捕获 mach信号或unix信号获取崩溃信息，但有时明明查到了具体的崩溃地点，确觉得这行代码似乎找不出问题。

崩溃无法复现，这个问题可能就不了了之了，崩溃率也就居高不下。

那有没有一个办法可以记录下来用户的操作步骤用于复现呢？可不可以记录现场？

于是我花了一天的时间写了这款工具：*KillBug*

> bugtags 中也有KillBug的功能。我们之前使用过，并成功的把崩溃率降低到了十万分之一。用户交互日志功不可没。


此工具用来收集用户操作步骤：
- 1、可用于bug复现，问题排查
- 2、分析用户操作日志

采用 runtime method swizzle 实现，为了不影响app的启动速度，method swizzle 需要手动开启。

支持Swift、OC以及混编项目。

目前支持采集如下内容：

```
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

```
## 使用
```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    KBAutoTrackManager *manager = [KBAutoTrackManager shared];
    [manager debugInfoHandler:^(NSString * _Nonnull info) {
        NSLog(@"%@", info);
        /// Custom 
    }];
    return YES;
}

```

## 采集日志
```
2021-03-30 11:20:53.215736+0800 KillBug_Example[962:142129] will appear: KBViewController
2021-03-30 11:20:53.265620+0800 KillBug_Example[962:142129] app state: 已经活跃
2021-03-30 11:20:54.720428+0800 KillBug_Example[962:142129] touch: 单击 位置 x:245.333328 y:629.333328
2021-03-30 11:20:54.761609+0800 KillBug_Example[962:142129] will appear: KBViewControllerA
2021-03-30 11:20:59.767387+0800 KillBug_Example[962:142129] touch: 单击 位置 x:138.333328 y:35.333328
2021-03-30 11:20:59.767880+0800 KillBug_Example[962:142129] touch: 单击 位置 x:138.333328 y:35.333328
2021-03-30 11:20:59.776511+0800 KillBug_Example[962:142129] click: UITableView row: 4 section: 0
2021-03-30 11:21:06.493889+0800 KillBug_Example[962:142129] touch: 单击 位置 x:261.000000 y:645.333328
2021-03-30 11:21:09.982150+0800 KillBug_Example[962:142129] click: UIButton txt:ButtonA
2021-03-30 11:21:14.463084+0800 KillBug_Example[962:142129] click: UIButton txt:小明
2021-03-30 11:21:17.768582+0800 KillBug_Example[962:142129] app state: 将非活跃
2021-03-30 11:21:18.677035+0800 KillBug_Example[962:142129] app state: 已进入后台
2021-03-30 11:21:23.629401+0800 KillBug_Example[962:142129] app state: 将进入前台
2021-03-30 11:21:23.954509+0800 KillBug_Example[962:142129] app state: 已经活跃
2021-03-30 11:21:25.641821+0800 KillBug_Example[962:142129] click: UIButton txt:崩溃测试
2021-03-30 11:21:25.643086+0800 KillBug_Example[962:142129] app crash: {
  "appException" : {
    "exceptionreason" : "*** -[__NSSingleObjectArrayI objectAtIndex:]: index 1 beyond bounds [0 .. 0]",
    "exceptionname" : "NSRangeException"
  }
}
```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

KillBug is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'KillBug'
```
## 我的其他开源框架

- [SpeedySwift 独立开发者必备](https://github.com/Tliens/SpeedySwift)

- [CTNet 这是一个可以指定缓存、重试、优先级的轻量级网络库](https://github.com/ours-curiosity/CTNet)

- [Localizable 国际化方案](https://github.com/Tliens/Localizable)

- [SpeedyMetal Metal 加速框架，GPUImage3的尝试演化](https://github.com/Tliens/SpeedyMetal)

- [GPUImageByMetal  GPUImage 3 中文注释版](https://github.com/Tliens/GPUImageByMetal)

## Author

tliens, maninios@163.com

## License

KillBug is available under the MIT license. See the LICENSE file for more info.
