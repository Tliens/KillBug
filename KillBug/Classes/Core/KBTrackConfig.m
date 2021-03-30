//
//  KBTrackConfig.m
//  KillBug
//
//  Created by 2020 on 2021/3/29.
//

#import "KBTrackConfig.h"

static KBTrackConfig* config;

@implementation KBTrackConfig
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        config = [KBTrackConfig new];
    });
}
- (instancetype)init
{
    self = [super init];
    if(self)
    {
        self.controllers = @[
        @"UICompatibilityInputViewController",
        @"UIKeyboardCandidateGridCollectionViewController",
        @"UIInputWindowController",
        @"UIApplicationRotationFollowingController",
        @"UIApplicationRotationFollowingControllerNoTouches",
        @"UISystemKeyboardDockController",
        @"UINavigationController",
        @"SFBrowserRemoteViewController",
        @"SFSafariViewController",
        @"UIAlertController",
        @"UIImagePickerController",
        @"PUPhotoPickerHostViewController",
        @"UIViewController",
        @"UITableViewController",
        @"UITabBarController",
        @"_UIRemoteInputViewController",
        @"UIEditingOverlayViewController",
        @"_UIAlertControllerTextFieldViewController",
        @"UIActivityGroupViewController",
        @"_UISFAirDropInstructionsViewController",
        @"_UIActivityGroupListViewController",
        @"_UIShareExtensionRemoteViewController",
        @"SLRemoteComposeViewController",
        @"SLComposeViewController",
        ];
    }
    return self;
}
+ (NSArray*)controllers
{
    return config.controllers;
}
@end
