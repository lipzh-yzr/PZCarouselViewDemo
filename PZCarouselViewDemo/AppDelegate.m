//
//  AppDelegate.m
//  PZCarouselViewDemo
//
//  Created by lipzh7 on 2022/2/8.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = [[ViewController alloc] init];
    [_window makeKeyAndVisible];
    return YES;
}


@end
