//
//  AppDelegate.m
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
#import "UMSocialSinaSSOHandler.h"
#import "WXApi.h"
#import "RJWXPayManager.h"
#import <AlipaySDK/AlipaySDK.h>
#import "RJAliPayManager.h"
#import <UMMobClick/MobClick.h>
#import "JPUSHService.h"
//#import "XZMCoreNewFeatureVC.h"
#import "RJBaseTabBarTableViewController.h"
#import "CALayer+Transition.h"
#import "AppDelegate+EaseMob.h"
#import "TalkingData.h"
#import <AdSupport/AdSupport.h>
#import "CYLTabBarControllerConfig.h"
#import "HHTrackingDateView.h"

#import "XHLaunchAd.h"
#import "LaunchAnimationModel.h"
#import "CCFirstInViewController.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate ()<JPUSHRegisterDelegate>

@property (assign, nonatomic) BOOL canShowNewFeature;

//app启动动画模型
//@property (strong, nonatomic) LaunchAnimationModel *launchAnimationModel;
@property (nonatomic,strong) UIButton * debugButton;
@property (nonatomic, strong) UIButton *debugTimeButton;

@end

@implementation AppDelegate
+ (instancetype)shareInstance{

    return (AppDelegate *)[[UIApplication sharedApplication]delegate];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc]init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.backgroundColor = [UIColor whiteColor];
    
    [[RJAppManager sharedInstance]configureApp];
    /**
     *  第三方 注册什么的
     */
    [self thirdSDKInit:application didFinishLaunchingWithOptions:launchOptions];
    
    CYLTabBarControllerConfig *tabBarControllerConfig = [CYLTabBarControllerConfig sharedInstance];
    
    [self.window setRootViewController:tabBarControllerConfig.tabBarController];
    [self.window makeKeyAndVisible];
    
    [NSThread sleepForTimeInterval:2];

    [self getLaunchAnimationData];
    
    [self showFirstInAD];
//    [self setupDebugButton];
    
    return YES;
}
- (void)setupDebugButton {
    
    self.debugButton = [UIButton buttonWithType:0];
    self.debugButton.frame = CGRectMake(SCREEN_WIDTH- 100, SCREEN_HEIGHT - 100, 55, 55);
    [self.debugButton setTitle:@"debug" forState:0];
    self.debugButton.titleLabel.font = GetFont(11);
    [self.debugButton setTitleColor:[UIColor redColor] forState:0];
    //    self.debugButton.trackingId = @"debugButtonID";
    [self.window addSubview:self.debugButton];
    [self.debugButton bringToFront];
    [self.debugButton addTarget:self action:@selector(debugButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.debugTimeButton = [[UIButton alloc] init];
    self.debugTimeButton.frame = CGRectMake(CGRectGetMinX(self.debugButton.frame) - 80, SCREEN_HEIGHT - 100, 60, 55);
    [self.debugTimeButton setTitle:@"debugTime" forState:0];
    self.debugTimeButton.titleLabel.font = GetFont(11);
    [self.debugTimeButton setTitleColor:[UIColor redColor] forState:0];
    //    self.debugButton.trackingId = @"debugButtonID";
    [self.window addSubview:self.debugTimeButton];
    [self.debugTimeButton bringToFront];
    [self.debugTimeButton addTarget:self action:@selector(debugTimeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}
- (void)debugButtonAction:(UIButton *)sender{
    [RJAppManager sharedInstance].trackingDebug = ![RJAppManager sharedInstance].trackingDebug;
    [[RJAppManager sharedInstance]scanAllViewWithView:self.window];
}
- (void)debugTimeButtonAction:(UIButton *)sender {
    [[HHTrackingDateView shareInstance] show];
}

- (void)getLaunchAnimationData {
        
    /**
     *  先取本地数据 看是否要显示广告图
     */
    
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:CCLuanchADDataKey];
    if (str) {
        LaunchAnimationModel *model = [[LaunchAnimationModel alloc]initWithString:str error:nil];
        if (model) {
//#warning debug
//            model.endDate  = @"2016-12-22 19:58:00";
//            model.beginDate  = @"2016-12-01 19:58:00";
//            model.id = @2;
//            model.showUrl = @"http://ohnzw6ag6.bkt.clouddn.com/video0.mp4";
//#warning debug
            /**
             *  判断是否在有效时间内
             */
            switch ([model isInAvailableTimeWithModel]) {
                case 0:
                {
//#warning 上线时候记得打开
                    [[RJAppManager sharedInstance] displayLaunchAnimationWithModel:model];

                }
                    break;
                case 1:
                {
                    //还没开始 以防万一再次和后台确认
                    [[RJAppManager sharedInstance]checkAppLaunchAdData];

                }
                    break;
                case 2:
                {
                    //已经结束
//                    NSLog(@"清除本地数据");
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:CCLuanchADDataKey];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                    [XHLaunchAd clearDiskCache];
                    [[RJAppManager sharedInstance]checkAppLaunchAdData];
                    
                }
                    break;
                    
                default:
                    [[RJAppManager sharedInstance]checkAppLaunchAdData];

                    break;
            }
            
        }else{
            [[RJAppManager sharedInstance]checkAppLaunchAdData];
        }
    }else{
        
        [[RJAppManager sharedInstance]checkAppLaunchAdData];
    }
    
    
    
}



- (void)thirdSDKInit:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [UMSocialData setAppKey:UmengAppkey];
    [UMSocialData openLog:NO];
    [UMSocialWechatHandler setWXAppId:kAppKey_weixin appSecret:kAppSecret_weixin url:ssrjWebUrl];
    [UMSocialQQHandler setQQWithAppId:kAppId_qq appKey:kAppKey_qq url:ssrjWebUrl];
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:kAppKey_weibo secret:kAppSecret_weibo RedirectURL:kRedirectURI_weibo];
    //qq登录 web授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //友盟数据统计
    UMConfigInstance.appKey = UmengAppkey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];
    [MobClick setLogEnabled:NO];
    /**
     * TalkingData
     */
    [TalkingData setExceptionReportEnabled:YES];
    [TalkingData sessionStarted:@"121323001FB34A60C025E88EDB7A7BFB" withChannelId:@"App Store"];
    [TalkingData setLogEnabled:NO];
    
    //初始化环信SDK
    [self easemobApplication:application didFinishLaunchingWithOptions:launchOptions];

    /**
     *  极光推送
     */
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    NSLog(@"ios10方法注册");
#endif
    [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                      UIUserNotificationTypeSound |
                                                      UIUserNotificationTypeAlert)
                                          categories:nil];
    //#warning 发布时候要改为YES
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    [JPUSHService setupWithOption:launchOptions appKey:@"9205f257226e7756a0413aa1"
                          channel:@"App Store"
                 apsForProduction:YES advertisingIdentifier:advertisingId];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(jpushLoginSuccess) name:kJPFNetworkDidLoginNotification object:nil];
    [JPUSHService crashLogON];
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification) {
        /**
         *  下面ios7处理的方法依旧被调用
         */
        NSLog(@"点击推送被启动");
        NSLog(@"remoteNotification=%@",remoteNotification);
    }
    [application setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
}
- (void)showFirstInAD{
    BOOL canShow = [CCFirstInViewController canShowNewFeature];
//    canShow = YES;
    if (canShow) {
        if ([self.window.rootViewController isKindOfClass:[RJBaseTabBarTableViewController class]]) {
            self.window.rootViewController = [CCFirstInViewController newFirstInViewControllerWithImageName:@[@"1.gif",@"2.gif",@"3.gif",@"4.gif"] enterBlock:^{
                CYLTabBarControllerConfig *tabBarControllerConfig = [CYLTabBarControllerConfig sharedInstance];
                [self.window setRootViewController:tabBarControllerConfig.tabBarController];
                [self.window makeKeyAndVisible];
            }];
        }
    }
}
- (void)jpushLoginSuccess{
//    NSLog(@"==极光推送登录成功==开始注册tag");
    NSString *version = [NSString stringWithFormat:@"version_%@",VERSION];
    if (!version.length) {
        return;
    }
    NSString *version2 = [version stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    NSSet *set = [NSSet setWithObjects:@"lc41",version2,nil];
    NSSet * set2 = [JPUSHService filterValidTags:set];
    [JPUSHService setTags:set2 alias:nil fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
        NSLog(@"++++rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags , iAlias);
        if (iResCode == 6002) {
            NSLog(@"超时");
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [JPUSHService setTags:set2 alias:nil fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
////                    NSLog(@"============rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags , iAlias);
//                }];
//            });
         
        }
        
    }];
    if ([RJAccountManager sharedInstance].account.userid) {
        [JPUSHService setTags:nil alias:[RJAccountManager sharedInstance].account.userid fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
//            NSLog(@"============rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags , iAlias);
           
        }];
    }else{
        [JPUSHService setAlias:@"" callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:nil];
    }

}
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias {
    NSLog(@"++++---rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}

//qq weibo weixin 登录
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    if ([url.host isEqualToString:@"safepay"]) {
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            
            if ([RJAliPayManager shareInstance].delegate && [[RJAliPayManager shareInstance].delegate respondsToSelector:@selector(managerDidRecvAliPayResponse:)]) {
                NSDictionary *dic = resultDic;
                [[RJAliPayManager shareInstance].delegate managerDidRecvAliPayResponse:dic];
            }
        }];
        return YES;
    }
    // add according to alipay官网
    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
//            NSLog(@"result = %@",resultDic);
            if ([RJAliPayManager shareInstance].delegate && [[RJAliPayManager shareInstance].delegate respondsToSelector:@selector(managerDidRecvAliPayResponse:)]) {
                NSDictionary *dic = resultDic;
                [[RJAliPayManager shareInstance].delegate managerDidRecvAliPayResponse:dic];
            }
            
        }];
        return YES;

    }
    
    if ([[url absoluteString] rangeOfString:@"wx71d644fc50bc3765://pay"].location == 0) {
//        NSLog(@"WX支付 回调");
        return [WXApi handleOpenURL:url delegate:[RJWXPayManager sharedManager]];
    }
    else {
        
        return ([TencentOAuth HandleOpenURL:url]||[UMSocialSnsService handleOpenURL:url wxApiDelegate:nil]||[UMSocialSnsService handleOpenURL:url]);
//        return [UMSocialSnsService handleOpenURL:url];
    }
}
//// NOTE: 9.0以后使用新API接口
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
//{
//    if ([url.host isEqualToString:@"safepay"]) {
//        //跳转支付宝钱包进行支付，处理支付结果
//        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
//            
//            NSLog(@"result = %@",resultDic);
//            
//        }];
//    }
//    
//    // add according to alipay官网
//    if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回authCode
//        
//        [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
//            //【由于在跳转支付宝客户端支付的过程中，商户app在后台很可能被系统kill了，所以pay接口的callback就会失效，请商户对standbyCallback返回的回调结果进行处理,就是在这个方法里面处理跟callback一样的逻辑】
//            NSLog(@"result = %@",resultDic);
//        }];
//    }
//    
//    return YES;
//}
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [application setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //这里处理新浪微博SSO授权进入新浪微博客户端后进入后台，再返回原来应用
    [UMSocialSnsService applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (application.applicationState == UIApplicationStateActive) {
        NSLog(@"App在前台运行时候收到推送,不处理");
        NSLog(@"推送信息%@",userInfo);
        completionHandler(UIBackgroundFetchResultNewData);
        return;
    }else{
        NSLog(@"在后台运行点击推荐进入");
    }
    
    NSLog(@"================推送信息%@",userInfo);
    // IOS 7 Support Required
    [application setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
    [self didRegisterFormApnsWithInfo:userInfo];
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
#pragma mark - 获得推送信息
// iOS 10 Support
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        [JPUSHService resetBadge];
//        [self didRegisterFormApnsWithInfo:userInfo];
        ///在前台时候收到推送
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService resetBadge];
        [self didRegisterFormApnsWithInfo:userInfo];

        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}
#endif
#pragma mark -客服消息的本地通知处理
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"点击本地推送 %@",notification);
    //    messageType = kefu;
    NSDictionary *dic = notification.userInfo;
    if (dic) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kGetAPNSMessageNotification object:nil userInfo:dic];
//        if ([dic objectForKey:@"messageType"] && [[dic objectForKey:@"messageType"]isEqualToString:@"kefu"]) {
//            if (![[[RJAppManager sharedInstance]currentViewController]isMemberOfClass:[ChatViewController class]]) {
//                
//            }
//        }
    }
}
- (void)didRegisterFormApnsWithInfo:(NSDictionary *)info{
    [[NSNotificationCenter defaultCenter] postNotificationName:kGetAPNSMessageNotification object:nil userInfo:info];
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /**
     *   去环信 AppDelegate+EaseMob 中实现
     */
//    /// Required - 注册 DeviceToken
//    [JPUSHService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    /**
     *   去环信 AppDelegate+EaseMob 中实现
     */
}


@end
