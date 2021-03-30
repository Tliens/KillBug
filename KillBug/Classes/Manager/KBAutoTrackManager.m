//
//  KBAutoTrackManager.m
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#import "KBAutoTrackManager.h"
#import "KBSwizzler.h"
#import "UIApplication+KBAutoTrack.h"
#import "UIViewController+KBAutoTrack.h"
#import "NSObject+KBSwizzle.h"
#import "KBTrackConfig.h"
#import "KBUIApplicationEvents.h"
#import "UIView+KBAutoTrack.h"
@interface KBAutoTrackManager()
@property(nonatomic,strong)KBUIApplicationEvents *lister;
@end

@implementation KBAutoTrackManager

#pragma mark - Public

+ (instancetype)shared {
    static dispatch_once_t once;
    static KBAutoTrackManager *instance = nil;
    dispatch_once(&once, ^{
        instance = [[[KBAutoTrackManager class] alloc] init];
        [instance autoSwizzle];
        instance.lister = [[KBUIApplicationEvents alloc] init];
    });
    return instance;
}
/// 普通 UIControl 支持xib拖出来的
- (void)trackEventView:(UIView *)view {
    NSLog(@"click: %@ txt:%@",view.class,[KBAutoTrackManager getText:view]);
}
/// tableview&collectionview
- (void)trackEventView:(UIView *)view withIndexPath:(nullable NSIndexPath *)indexPath {
    NSLog(@"click: %@ row: %ld section: %ld",view.class,(long)indexPath.row,(long)indexPath.section);
}
/// viewcontroller
- (void)trackViewControlWillAppear:(UIViewController *)controller {
    if ([self shouldTrackViewContrller:[controller class]]){
        NSLog(@"will appear: %@",[self titleFromViewController:controller]);
    }
}
/// application 活跃状态
- (void)trackApplication:(NSString *)state;{
    NSLog(@"app state: %@",state);
}
/// app 死亡信息
- (void)trackApplicationDeadReason:(NSString *)reason;{
    NSLog(@"app crash: %@",reason);
}
- (void)trackTouch:(NSString *)info;{
    NSLog(@"touch: %@",info);
}
- (BOOL)shouldTrackViewContrller:(Class)aClass {
    return ![KBTrackConfig.controllers containsObject:NSStringFromClass(aClass)];
}
// tableview collectionview
- (void)swizzleSelected:(UIView *)view delegate:(id)delegate {
    if ([view isKindOfClass:[UITableView class]]
        && [delegate conformsToProtocol:@protocol(UITableViewDelegate)]) {
        void (^block)(id, SEL, id, id) = ^(id target, SEL command, UITableView *tableView, NSIndexPath *indexPath) {
            [self trackEventView:tableView withIndexPath:indexPath];
        };
        
        [KBSwizzler swizzleSelector:@selector(tableView:didSelectRowAtIndexPath:)
                            onClass:[delegate class]
                          withBlock:block
                              named:@"kb_table_select"];
    }
    
    if ([view isKindOfClass:[UICollectionView class]]
        && [delegate conformsToProtocol:@protocol(UICollectionViewDelegate)]) {
        
        void (^block)(id, SEL, id, id) = ^(id target, SEL command, UICollectionView *collectionView, NSIndexPath *indexPath) {
            [self trackEventView:collectionView withIndexPath:indexPath];
        };
        [KBSwizzler swizzleSelector:@selector(collectionView:didSelectItemAtIndexPath:)
                            onClass:[delegate class]
                          withBlock:block
                              named:@"kb_collection_select"];
    }
}

- (void)autoSwizzle {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        void (^tableViewBlock)(UITableView *tableView,
                               SEL cmd,
                               id<UITableViewDelegate> delegate) =
        ^(UITableView *tableView, SEL cmd, id<UITableViewDelegate> delegate) {
            if (!delegate) {
                return;
            }
            
            [self swizzleSelected:tableView delegate:delegate];
        };
        
        [KBSwizzler swizzleSelector:@selector(setDelegate:)
                            onClass:[UITableView class]
                          withBlock:tableViewBlock
                              named:@"kb_table_delegate"];
        
        void (^collectionViewBlock)(UICollectionView *, SEL, id<UICollectionViewDelegate>) = ^(UICollectionView *collectionView, SEL cmd, id<UICollectionViewDelegate> delegate) {
            if (nil == delegate) {
                return;
            }
            
            [self swizzleSelected:collectionView delegate:delegate];
        };
        [KBSwizzler swizzleSelector:@selector(setDelegate:)
                            onClass:[UICollectionView class]
                          withBlock:collectionViewBlock
                              named:@"kb_collection_delegate"];
        
        [UIViewController kb_swizzleMethod:@selector(viewWillAppear:)
                                withMethod:@selector(kb_autotrack_viewWillAppear:)
                                     error:NULL];
        
        [UIApplication kb_swizzleMethod:@selector(sendAction:to:from:forEvent:)
                             withMethod:@selector(kb_sendAction:to:from:forEvent:)
                                  error:NULL];
        
        [UIView kb_autoTrack];
    });
}

+ (NSString *)getText:(NSObject *)obj {
    NSString *text = nil;
    if ([obj isKindOfClass:[UIButton class]]) {
        text = ((UIButton *)obj).currentTitle;
    } else if ([obj isKindOfClass:[UITextView class]] ||
               [obj isKindOfClass:[UITextField class]]) {
        //ignore
    } else if ([obj isKindOfClass:[UILabel class]]) {
        text = ((UILabel *)obj).text;
    } else if ([obj isKindOfClass:[UIPickerView class]]) {
        UIPickerView *picker = (UIPickerView *)obj;
        NSInteger sections = picker.numberOfComponents;
        NSMutableArray *titles = [NSMutableArray array];
        
        for(NSInteger i = 0; i < sections; i++) {
            NSInteger row = [picker selectedRowInComponent:i];
            NSString *title;
            if ([picker.delegate
                 respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
                title = [picker.delegate pickerView:picker titleForRow:row forComponent:i];
            } else if ([picker.delegate
                        respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)]) {
                title = [picker.delegate
                         pickerView:picker
                         attributedTitleForRow:row forComponent:i].string;
            }
            [titles addObject:title ?: @""];
        }
        if (titles.count > 0) {
            text = [titles componentsJoinedByString:@","];
        }
    } else if ([obj isKindOfClass:[UIDatePicker class]]) {
        UIDatePicker *picker = (UIDatePicker *)obj;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
        text = [formatter stringFromDate:picker.date];
    } else if ([obj isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *segment = (UISegmentedControl *)obj;
        text =  [NSString stringWithFormat:@"%@", [segment titleForSegmentAtIndex:segment.selectedSegmentIndex]];
    } else if ([obj isKindOfClass:[UISwitch class]]) {
        UISwitch *switchItem = (UISwitch *)obj;
        text = switchItem.on ? @"on" : @"off";
    } else if ([obj isKindOfClass:[UISlider class]]) {
        UISlider *slider = (UISlider *)obj;
        text = [NSString stringWithFormat:@"%f", [slider value]];
    } else if ([obj isKindOfClass:[UIStepper class]]) {
        UIStepper *step = (UIStepper *)obj;
        text = [NSString stringWithFormat:@"%f", [step value]];
    } else {
        if ([obj isKindOfClass:[UIView class]]) {
            for(UIView *subView in [(UIView *)obj subviews]) {
                text = [KBAutoTrackManager getText:subView];
                if ([text isKindOfClass:[NSString class]] && text.length > 0) {
                    break;
                }
            }
        }
    }
    return text;
}

- (NSString *)titleFromViewController:(UIViewController *)viewController {
    NSString *title =  viewController.navigationItem.title;
    NSString *className = NSStringFromClass(viewController.class);
    if (title){
        return [title stringByAppendingString:className];
    }else{
        return className;
    }
}

@end
