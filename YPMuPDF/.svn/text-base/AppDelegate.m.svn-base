//
//  AppDelegate.m
//  YPMuPDFDemo
//
//  Created by navchina on 2017/6/27.
//  Copyright © 2017年 LYP. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
//#import "common.h"
#import "SiniCustomePDFViewcontroller.h"

@interface AppDelegate ()
{
    SiniCustomePDFViewcontroller *vc;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"%@",[self class]);
    NSLog(@"%@",[super class]);
     NSFileManager *FileMa = [NSFileManager defaultManager];
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    
    NSString *fileB = [[NSBundle mainBundle]pathForResource:@"01CCE0B568B020371F564DA82D341F4A.pdf" ofType:nil];
     NSString *fileB1 = [[NSBundle mainBundle]pathForResource:@"APP-1 10号进近 P193.pdf" ofType:nil];
    NSString *fileP = [docPath stringByAppendingPathComponent:@"01CCE0B568B020371F564DA82D341F4A"];
    NSString *fileP1 = [docPath stringByAppendingPathComponent:@"APP-1 10号进近 P193.pdf"];
    
    if (![FileMa fileExistsAtPath:fileP]) {
        [FileMa copyItemAtPath:fileB toPath:fileP error:nil];
    }
    if (![FileMa fileExistsAtPath:fileP1]) {
         [FileMa copyItemAtPath:fileB1 toPath:fileP1 error:nil];
    }
    self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
//    ViewController *vc = [[ViewController alloc]init];
    vc = [[SiniCustomePDFViewcontroller alloc]initWithStyleInstance:nil];
    
    UIButton *nightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [nightBtn setTitle:@"夜视" forState:UIControlStateNormal];
    [nightBtn setTitle:@"白天" forState:UIControlStateSelected];
    [nightBtn addTarget:self action:@selector(nightClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *outlineBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [outlineBtn setTitle:@"目录" forState:UIControlStateNormal];
    [outlineBtn addTarget:self action:@selector(outlineBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *forWardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [forWardBtn setTitle:@"前进" forState:UIControlStateNormal];
    [forWardBtn addTarget:self action:@selector(forWardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *goBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [goBackBtn setTitle:@"后退" forState:UIControlStateNormal];
    [goBackBtn addTarget:self action:@selector(goBackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *signatureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [signatureBtn setTitle:@"签名" forState:UIControlStateNormal];
    [signatureBtn addTarget:self action:@selector(signatureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *resignatureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [resignatureBtn setTitle:@"重签名" forState:UIControlStateNormal];
    [resignatureBtn addTarget:self action:@selector(resignatureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    vc.cornerToolsItems = @[vc.siniMuOutlineItem,vc.siniMuSearchItem,vc.siniAnnotationItem,vc.siniLeftRotationItem,vc.siniRightRotationItem,nightBtn/*,outlineBtn,searchBtn,forWardBtn,goBackBtn,signatureBtn,resignatureBtn*/];
    UINavigationController *NAV = [[UINavigationController alloc]initWithRootViewController:vc];
    self.window.rootViewController = NAV;
    [vc displayDocumentWithURL:[NSURL fileURLWithPath:fileP] uid:@"sadjiga"];
    [self.window makeKeyAndVisible];
    
    return YES;
}
- (void)nightClicked:(UIButton *)btn{
    btn.selected = !btn.selected;
    [vc setNightModel:btn.selected];
}

-(void)outlineBtnClick:(UIButton *)sender{
    NSLog(@"++++");
    [vc getOutline];
}
-(void)searchBtnBtnClick:(UIButton *)sender{
    [vc searchPdfWithText:@"MEL"];
}

-(void)forWardBtnClick:(UIButton *)sender{
    [vc redo];
}
-(void)goBackBtnClick:(UIButton *)sender{
    [vc undo];
}

-(void)signatureBtnClick:(UIButton *)sender{
    
    [vc signature];
}

-(void)resignatureBtnClick:(UIButton *)sender{
    [vc reSignature];
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
