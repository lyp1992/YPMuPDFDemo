//
//  AppDelegate.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/6/27.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "common.h"

@interface AppDelegate ()

@end

enum{
    ResourceCacheMaxSize = 128<<20	/**< use at most 128M for resource cache */
};

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    queue = dispatch_queue_create("com.artifex.mupdf.queue", NULL);
    
    ctx = fz_new_context(NULL, NULL, ResourceCacheMaxSize);
    fz_register_document_handlers(ctx);
    screenScale = [UIScreen mainScreen].scale;
    
//    判断程序是否是第一次启动
    if (![[NSUserDefaults standardUserDefaults]boolForKey:@"firstLauch"]) {
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"firstLauch"];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"switchNight"];
        
        NSString *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *fileP1 = [filePath stringByAppendingPathComponent:@"01CCE0B568B020371F564DA82D341F4A.pdf"];
        
        NSString *fileB1 = [[NSBundle mainBundle]pathForResource:@"01CCE0B568B020371F564DA82D341F4A.pdf" ofType:nil];
//
        NSString *fileP = [filePath stringByAppendingPathComponent:@"APP-1 10号进近 P193.pdf"];
        
        NSString *fileB = [[NSBundle mainBundle]pathForResource:@"APP-1 10号进近 P193.pdf" ofType:nil];
        
        NSFileManager *FileMa = [NSFileManager defaultManager];
        [FileMa copyItemAtPath:fileB toPath:fileP error:nil];
        [FileMa copyItemAtPath:fileB1 toPath:fileP1 error:nil];

    }
    
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    ViewController *vc = [[ViewController alloc]init];
    UINavigationController *NAV = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = NAV;
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

//- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window  NS_AVAILABLE_IOS(6_0) __TVOS_PROHIBITED{
//
//    if (self.allowRotation) {
//        return UIInterfaceOrientationMaskAll;
//    }
//    
//    return UIInterfaceOrientationMaskPortrait;
//    
//}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
