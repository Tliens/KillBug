# KillBug

[![CI Status](https://img.shields.io/travis/tliens/KillBug.svg?style=flat)](https://travis-ci.org/tliens/KillBug)
[![Version](https://img.shields.io/cocoapods/v/KillBug.svg?style=flat)](https://cocoapods.org/pods/KillBug)
[![License](https://img.shields.io/cocoapods/l/KillBug.svg?style=flat)](https://cocoapods.org/pods/KillBug)
[![Platform](https://img.shields.io/cocoapods/p/KillBug.svg?style=flat)](https://cocoapods.org/pods/KillBug)

此工具用来收集用户操作步骤：
1、可用于bug复现，问题排查
2、分析用户操作日志

采用 runtime method swizzle 实现，为了不影响app的启动速度，method swizzle 需要手动开启。

目前支持采集如下内容：

```
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

## Author

tliens, maninios@163.com

## License

KillBug is available under the MIT license. See the LICENSE file for more info.
