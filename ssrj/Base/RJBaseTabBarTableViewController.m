//
//  RJBaseTabBarTableViewController.m
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright (c) 2016年 ssrj. All rights reserved.
//

#import "RJBaseTabBarTableViewController.h"
#import "MineNewViewController.h"
#import "RJGotoUpDateViewController.h"

#import "RJZhushouNavigationController.h"
#import "RJZhuShouViewController.h"
#import "RJAnswerViewController.h"
#import "RJShareBasicModel.h"
#import "RJWebViewController.h"
#import "ActivityViewController.h"
#import "RJBrandDetailRootViewController.h"
#import "EMCDDeviceManager.h"
#import "EMIMHelper.h"
#import "HomeGoodListViewController.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
#import "EMIMHelper.h"
#import "ChatViewController.h"
//两次提示的默认间隔

static const CGFloat kDefaultPlaySoundInterval = 3.0;


@interface RJBaseTabBarTableViewController ()<UITabBarControllerDelegate,IChatManagerDelegate>
@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@property (nonatomic,strong) UINavigationController * mineNavigationControl;
@end

@implementation RJBaseTabBarTableViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateApp:) name:kNotificationAppShouldUpdate object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAnpsMessageNotification:) name:kGetAPNSMessageNotification object:nil];
    
    [self registerNotifications];

    self.delegate = self;

}
- (instancetype)initWithViewControllers:(NSArray<UIViewController *> *)viewControllers tabBarItemsAttributes:(NSArray<NSDictionary *> *)tabBarItemsAttributes{
    if (self = [super init]) {
        self.tabBarItemsAttributes = tabBarItemsAttributes;
        self.viewControllers = viewControllers;
        self.mineNavigationControl =(UINavigationController *)viewControllers.lastObject;
    }
    return self;
}
- (void)getAnpsMessageNotification:(NSNotification *)info{
    /**
     *  aps =     {
     alert = "\U60a8\U6709\U4e00\U6761\U65b0\U6d88\U606f";
     badge = 1;
     sound = default;
	    };
	    f = MFD2016SSRJ;
	    m = 299616238286410856;
	    t = 537577628a7cf4b33b3e1e7e2f11a3cb;
     */
    NSLog(@"收到推送 要去跳转页面：%@",info);
    /**
     根据目前打开的Tab页 用本Tab页面的Navigation跳转
     */
    NSDictionary *dic = [info.userInfo mutableCopy];
    if ([dic objectForKey:@"pushType"]) {
        NSNumber *type = [dic objectForKey:@"pushType"];
        if (type.intValue == 1) {
            /**
             H5活动推送 带分享信息 不需要用户登录什么的 每个人分享链接都是一样的
             */
            RJShareBasicModel *model = [[RJShareBasicModel alloc]initWithDictionary:dic error:nil];
            if (model) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSLog(@"%@",model);
                    RJWebViewController *webView = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RJWebViewController"];
                    webView.shareModel = model;
                    webView.urlStr = model.showUrl;
                    webView.isPushIn = YES;
                    //分享上报 需要id
                    webView.webId = model.id;
                    [self.selectedViewController pushViewController:webView animated:YES];
                });
            }
        }else if(type.intValue == 2){
            /**
             类似闺蜜节活动
             */
            ActivityViewController *activityViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ActivityViewController"];
            activityViewController.activityId = dic[@"id"];
            activityViewController.show_url = dic[@"showUrl"];
            activityViewController.share_url = dic[@"shareUrl"];
            activityViewController.isLogin = dic[@"isLogin"];
            activityViewController.shareType = dic[@"shareType"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.selectedViewController pushViewController:activityViewController animated:YES];

            });
            
        }else if(type.integerValue == 3){
            /**
             *  跳转原生的界面  3为单品列表页
             */
            if ([dic objectForKey:@"paramValue"]) {
                NSString *paramValue = [dic objectForKey:@"paramValue"];
                NSArray *arr1 = [paramValue componentsSeparatedByString:@"&"];
                NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
                BOOL isBrand = NO;
                NSNumber *brandId;
                for (NSString *str in arr1) {
                    NSArray *arr = [str componentsSeparatedByString:@"="];
                    if (arr.count ==2) {
                        [mDic addEntriesFromDictionary:@{arr[0]:arr[1]}];
                        NSString *str = arr[0];
                        if ([str isEqualToString:@"brands"]) {
                            isBrand = YES;
                            brandId = arr[1];
                        }
                    }
                }
                if (isBrand) {
                    
                    [self pushToNewBrandDetailWithDictionary:mDic brandId:brandId];
                    
                }else{
                    NSString *title = @"";
                    if ([dic objectForKey:@"title"]) {
                        title = [dic objectForKey:@"title"];
                    }
                    [self pushToGoodListWithDictionary:mDic name:title];
                }
                
            }
        }else if(type.integerValue == 4){
            /**
             *  跳转的是品牌页面 原生
             */
            if ([dic objectForKey:@"paramValue"]) {
                NSString *paramValue = [dic objectForKey:@"paramValue"];
                NSArray *arr1 = [paramValue componentsSeparatedByString:@"&"];
                NSMutableDictionary *mDic = [NSMutableDictionary dictionary];
                BOOL isBrand = NO;
                NSNumber *brandId;
                for (NSString *str in arr1) {
                    NSArray *arr = [str componentsSeparatedByString:@"="];
                    if (arr.count ==2) {
                        [mDic addEntriesFromDictionary:@{arr[0]:arr[1]}];
                        NSString *str = arr[0];
                        if ([str isEqualToString:@"brands"]) {
                            isBrand = YES;
                            brandId = arr[1];
                        }
                    }
                }
                if (isBrand) {
                    
                    [self pushToNewBrandDetailWithDictionary:mDic brandId:brandId];
                    
                }
                
            }
        }
    }
    /**
     *  处理客服离线消息
     */
    if ([dic objectForKey:@"f"]&&[[dic objectForKey:@"f"]isEqualToString:@"MFD2016SSRJ"]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[EMIMHelper defaultHelper] loginEasemobSDK];
            NSString *cname = @"mfd2016ssrj";
            ChatViewController *chatViewController = [[ChatViewController alloc]initWithChatter:cname type:eSaleTypeNone];
            chatViewController.title = @"时尚客服";
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.selectedViewController pushViewController:chatViewController  animated:YES];
        });
    }
    
    /**
     *  处理本地通知  客服消息跳转
     */
    if ([dic objectForKey:@"LocationNotifyType"] && [[dic objectForKey:@"LocationNotifyType"]isEqualToString:@"kefu"]) {
        if (![[[RJAppManager sharedInstance]currentViewController]isMemberOfClass:[ChatViewController class]]) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[EMIMHelper defaultHelper] loginEasemobSDK];
                NSString *cname = @"mfd2016ssrj";
                ChatViewController *chatViewController = [[ChatViewController alloc]initWithChatter:cname type:eSaleTypeNone];
                chatViewController.title = @"时尚客服";
                chatViewController.hidesBottomBarWhenPushed = YES;
                [self.selectedViewController pushViewController:chatViewController  animated:YES];
            });
            
        }
    }
    
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    
    UINavigationController *nav = (UINavigationController *)viewController;
    
    /**
     *  2.2.0 穿衣助手不再需要登录才能查看 也不需要做题
     */
    
//    if ([nav isKindOfClass:[RJZhushouNavigationController class]]) {
//        if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//            //2.0.3之前的版本用户 没有这个字段，要去掉接口判断一下
//            if ([RJAccountManager sharedInstance].account.isSurvey == nil) {
//                [self getIsAccountHasZuoti];
//                return NO;
//            }
//            return YES;
//        }else{
//            
//            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
//            
//            [self.selectedViewController presentViewController:loginNav animated:YES completion:^{
//                
//            }];
//            return NO;
//        }
//    }
    

    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        return YES;
    }
    
    if ([[[nav viewControllers]firstObject] isKindOfClass:[MineNewViewController class]]) {
    
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self.selectedViewController presentViewController:loginNav animated:YES completion:^{
            
        }];
        return NO;
    }
    return YES;
}
- (void)getIsAccountHasZuoti{
    //调取接口再判断一下
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/checkSurvey.jhtml"];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
//                NSLog(@"success");
                /**
                 *  debug
                 */
                NSDictionary *dic = responseObject[@"data"];
                RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:dic error:nil];
                if (model) {
                    [[RJAccountManager sharedInstance]registerAccount:model];
//                    RJZhushouNavigationController *nav = self.viewControllers[1];
//                    //之前做过题了 有值了
//                    if ([RJAccountManager sharedInstance].account.isSurvey.boolValue == YES) {
//                        //直接去推荐界面
//                        RJZhuShouViewController *zhushouVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJZhuShouViewController"];
//                        [nav setViewControllers:@[zhushouVc]];
//                        
//                    }else{
//                        RJAnswerViewController *answerVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJAnswerViewController"];
//                        [nav setViewControllers:@[answerVc]];
//                    }
                    [self setSelectedIndex:1];
                    [[HTUIHelper shareInstance]removeHUD];

                }else{
                    
                    [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];

                }
//                [RJAccountManager sharedInstance].account.isSurvey = [NSNumber numberWithBool:YES];
                
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
    }];
}
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
//    if (self.mineNavigationControl) {
//        [self.mineNavigationControl.tabBarItem setBadgeValue:@"3"];
//    }
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)shouldUpdateApp:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id userInfo = notification.object;
        RJGotoUpDateViewController *updateVC = [[RJGotoUpDateViewController alloc] init];
        updateVC.urlStr = [userInfo objectForKey:@"URI"];
        
//        [self presentViewController:updateVC animated:NO completion:^{
//            
//        }];
        [AppDelegate shareInstance].window.rootViewController = updateVC;
    });
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationAppShouldUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kGetAPNSMessageNotification object:nil];

}



#pragma mark -
#pragma mark 环信相关
-(void)registerNotifications
{
    [self unregisterNotifications];
    
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

-(void)unregisterNotifications
{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

- (void)_playSoundAndVibration
{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
    /**
     *  不在客服聊天界面 亮红点
     */
    if (![[RJAppManager sharedInstance].currentViewController isMemberOfClass:[ChatViewController class]]) {
        /**
         *  显示小红点
         */
        [RJAppManager sharedInstance].isNewKeFuMessage = YES;
        [[NSNotificationCenter defaultCenter]postNotificationName:kStatusNewKeFuMessageNotification object:nil];

    }
    
}
// 收到消息回调
-(void)didReceiveMessage:(EMMessage *)message
{
#if !TARGET_IPHONE_SIMULATOR
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    if (!isAppActivity) {
        [self _showNotificationWithMessage:message];
    }else {
        [self _playSoundAndVibration];
    }
#endif
}

- (void)_showNotificationWithMessage:(EMMessage *)message
{
    /**
     *  显示小红点 发送通知
     */
    [RJAppManager sharedInstance].isNewKeFuMessage = YES;
    [[NSNotificationCenter defaultCenter]postNotificationName:kStatusNewKeFuMessageNotification object:nil];
    
    
    EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == ePushNotificationDisplayStyle_messageSummary) {
        id<IEMMessageBody> messageBody = [message.messageBodies firstObject];
        NSString *messageStr = nil;
        switch (messageBody.messageBodyType) {
            case eMessageBodyType_Text:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case eMessageBodyType_Image:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case eMessageBodyType_Location:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case eMessageBodyType_Voice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case eMessageBodyType_Video:{
                messageStr = NSLocalizedString(@"message.vidio", @"Vidio");
            }
                break;
            default:
                break;
        }
        
        NSString *title = message.from;
        notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
    }
    else{
        notification.alertBody = @"您有一条新客服消息";
    }
    
//#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    notification.userInfo = @{@"LocationNotifyType":@"kefu"};
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    NSInteger num = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:num];

//#ifdef NSFoundationVersionNumber_iOS_9_x_Max
//    // 使用 UNUserNotificationCenter 来管理通知
//    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
//    
//    //需创建一个包含待通知内容的 UNMutableNotificationContent 对象，注意不是 UNNotificationContent ,此对象为不可变对象。
//    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
//    content.title = [NSString localizedUserNotificationStringForKey:@"Hello!" arguments:nil];
//    content.body = [NSString localizedUserNotificationStringForKey:@"Hello_message_body"
//                                                         arguments:nil];
//    content.sound = [UNNotificationSound defaultSound];
//    
//    // 在 alertTime 后推送本地推送
//    UNTimeIntervalNotificationTrigger* trigger = [UNTimeIntervalNotificationTrigger
//                                                  triggerWithTimeInterval:.1 repeats:NO];
//    
//    UNNotificationRequest* request = [UNNotificationRequest requestWithIdentifier:@"FiveSecond"
//                                                                          content:content trigger:trigger];
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//
//    }];
//    
//#endif

}
#pragma mark - IChatManagerDelegate 登录状态变化

- (void)didLoginFromOtherDevice
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginAtOtherDevice", @"your login account has been in other places") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
//        alertView.tag = 100;
//        [alertView show];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kHuanXinLoginFromOtherDevice" object:nil];
        [[EMIMHelper defaultHelper]refreshHelperData];
        
    } onQueue:nil];
}

- (void)didRemovedFromServer
{
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO completion:^(NSDictionary *info, EMError *error) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"loginUserRemoveFromServer", @"your account has been removed from the server side") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
//        alertView.tag = 101;
//        [alertView show];
//        [[EMIMHelper defaultHelper]refreshHelperData];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"kHuanXinLoginFromOtherDevice" object:nil];


    } onQueue:nil];
}


#pragma mark - ========去往商品列表界面 传递参数============
- (void)pushToGoodListWithDictionary:(NSDictionary *)dic name:(NSString *)name{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomeGoodListViewController *goodListVc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
    goodListVc.parameterDictionary = [dic copy];
    if (name.length) {
        goodListVc.titleStr = name;
    }
    [self.selectedViewController pushViewController:goodListVc animated:YES];
}
#pragma mark - ===========去往新的品牌界面========
- (void)pushToNewBrandDetailWithDictionary:(NSDictionary *)dic brandId:(NSNumber *)brandid{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
    rootVc.parameterDictionary = dic;
    rootVc.brandId = brandid;
    [self.selectedViewController pushViewController:rootVc  animated:YES];
}
@end
