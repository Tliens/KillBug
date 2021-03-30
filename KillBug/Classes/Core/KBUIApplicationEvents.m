//
//  KBUIApplicationEvents.m
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#import "KBUIApplicationEvents.h"
#import "KBAutoTrackManager.h"

static NSUncaughtExceptionHandler *preUncaughtExceptionHandler;

@implementation KBUIApplicationEvents
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setApplicationListeners];
        /// 注册
        preUncaughtExceptionHandler = NSGetUncaughtExceptionHandler();
        NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    }
    return self;
}
/// 抓崩溃
void UncaughtExceptionHandler(NSException *exception){
    if (exception ==nil)return;
    NSString *reason = [exception reason];
    NSString *name  = [exception name];
    /// 这里就只采集描述吧，具体的堆栈信息，去bug收集平台查看
    NSDictionary *dict = @{@"appException":@{@"exceptionreason":reason,@"exceptionname":name}};
    // 把异常抛出去给其他SDK处理，避免其他SDK解析出现问题
    if (preUncaughtExceptionHandler){
        preUncaughtExceptionHandler(exception);
    }
    NSString *info = [KBUIApplicationEvents dictionaryToJson:dict];
    [[KBAutoTrackManager shared] trackApplicationDeadReason:info];
}
+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];

    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
- (void)setApplicationListeners {
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillEnterForeground:)
                               name:UIApplicationWillEnterForegroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidBecomeActive:)
                               name:UIApplicationDidBecomeActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillResignActive:)
                               name:UIApplicationWillResignActiveNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationDidEnterBackground:)
                               name:UIApplicationDidEnterBackgroundNotification
                             object:nil];
    
    [notificationCenter addObserver:self
                           selector:@selector(applicationWillTerminate:)
                               name:UIApplicationWillTerminateNotification
                             object:nil];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification {
    [[KBAutoTrackManager shared] trackApplication:@"将进入前台"];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    [[KBAutoTrackManager shared] trackApplication:@"已进入后台"];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    [[KBAutoTrackManager shared] trackApplication:@"将非活跃"];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [[KBAutoTrackManager shared] trackApplication:@"已经活跃"];
}
/// 只能检测到前台被杀死，
/// 后台杀死检测不到（Terminated due to signal 9）
/// 崩溃也检测不到
- (void)applicationWillTerminate:(NSNotification *)notification {
    [[KBAutoTrackManager shared] trackApplication:@"前台被用户将被杀死"];
}
@end
