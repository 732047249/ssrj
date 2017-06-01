
#import "RJAppManager.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "LaunchAnimationModel.h"
#import "XHLaunchAd.h"
#import "RJSqlitManager.h"
#import <AdSupport/AdSupport.h>
#import "LKDBHelper.h"
#import "RJTrackingModel.h"
@interface RJAppManager ()
@property (nonatomic,strong) NSDateFormatter * dateFormatter;
@property (nonatomic,strong) NSDateFormatter * fullDateFormatter;

@end

@implementation RJAppManager

+ (instancetype)sharedInstance {
	static RJAppManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}
/**
 *  初始化信息配置
 */
- (void)configureApp{
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    [[UINavigationBar appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithHexString:@"#ffffff"],NSForegroundColorAttributeName, nil]];
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [UINavigationBar appearance].translucent = NO;

    /**
     *  基本颜色设置
     */
    [UITabBar appearance].translucent = NO;

    [[UITabBar appearance] setBarTintColor:[UIColor colorWithHexString:@"#f8f8f8"]];
    //    tabbar.alpha = .6;
    [[UINavigationBar appearance]setBarTintColor:APP_BASIC_COLOR];
    
    
    
    [self setupNetWork];
//    [[RJSqlitManager sharedInstance]openDBWithPath:[DocumentPath stringByAppendingPathComponent:@"rj_db.db"]];
    //自动登录
    [[RJAccountManager sharedInstance]setup];

//    [self cheackAppVersion];
    
    //token 验证
    [self checkAccoutnToken];
    
    //[self getWhiteVerdionList];
    
    [[SDImageCache sharedImageCache]setShouldDecompressImages:NO];
    
    [[SDWebImageDownloader sharedDownloader]setShouldDecompressImages:NO];
    
    
    /**
     *  统计上报
     */
    [[RJAppManager sharedInstance]uploapTrackingJsonStingWithSql];
    [[RJAppManager sharedInstance]uploapTrackingDataWithSql];
    
}
/**
 *  懒加载
 */
- (CCAppVersionModel *)versionInfo{
    if (!_versionInfo) {
        _versionInfo = [CCAppVersionModel new];
    }
    return _versionInfo;
}


- (NSMutableArray *)statisticalModelArr {
    
    if (!_statisticalModelArr) {
        _statisticalModelArr = [NSMutableArray array];
    }
    
    return _statisticalModelArr;
}



- (void)setupNetWork{
    [ZHNetworkManager sharedInstance];
    //缓冲
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
}
/**
 *  版本更新是否退出登录 或者清除数据库什么的 暂时用不到
 */
- (void)cheackAppVersion{
    
}
/**
 *  检查Token有效期
 */
- (void)checkAccoutnToken{
    if ([RJAccountManager sharedInstance].token) {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        requestInfo.URLString = @"/api/v5/token/check.jhtml";
//        NSLog(@"Token校验");
//        [RJAccountManager sharedInstance].account.token = @"111";
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSNumber *state = responseObject[@"state"];
//#warning debug
//            state = @2;
            if (state.intValue == 0) {
//                NSLog(@"==========token合法==========");
                [RJAccountManager sharedInstance].isCheckTokenAvaiable = YES;
                return ;
                
            }
//            else if (state.intValue == 2){
//                [self showTokenDisableLoginVc];
//                
//            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [RJAccountManager sharedInstance].isCheckTokenAvaiable = NO;

        }];
    }
}
- (void)checkAppVersionIsInitiative:(BOOL)flag{
    
    NSString *URLString = [NSString stringWithFormat:@"https://itunes.apple.com/lookup?id=%@", APP_ID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:15.0f];
    __weak __typeof(&*self)weakSelf = self;
    __block NSHTTPURLResponse *urlResponse = nil;
    __block NSError *error = nil;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        if (recervedData && recervedData.length > 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:recervedData options:NSJSONReadingMutableLeaves error:&error];
            NSArray *infoArray = [dict objectForKey:@"results"];
            if (infoArray && infoArray.count > 0) {
                NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                //描述
                weakSelf.versionInfo.releaseNote = releaseInfo[@"releaseNotes"];
                weakSelf.versionInfo.version = releaseInfo[@"version"];
                weakSelf.versionInfo.URI = releaseInfo[@"trackViewUrl"];
                
                if (weakSelf.needsForceUpdate) {
                    //强制更新
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAppShouldUpdate object:@{@"URI":weakSelf.versionInfo.URI}];
                    return;
                }
                //是否忽略这个版本
                weakSelf.versionIgnored = ([weakSelf.versionInfo.version isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:UDkUpdateIgnoredVersion]]);
                //要判断这里忽略过的版本是不是更新了 和本地版本号已经一样了
                if ([VERSION isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:UDkUpdateIgnoredVersion]]) {
                    weakSelf.versionIgnored = NO;
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:UDkUpdateIgnoredVersion];
                }
                weakSelf.hasNewVersion = ([VERSION compare:weakSelf.versionInfo.version options:NSNumericSearch] == NSOrderedAscending);
                
                if (weakSelf.versionIgnored&&!flag) {
//                    NSLog(@"忽略的版本");
                    return;
                }
                if (weakSelf.hasNewVersion) {
                    if (!flag) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"新版本%@",weakSelf.versionInfo.version] message:[NSString stringWithFormat:@"%@",weakSelf.versionInfo.releaseNote] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"立即更新",@"忽略此版本", nil];
                        alert.tag = 10000;
                        [alert show];
                        
                    }else{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"新版本%@",weakSelf.versionInfo.version] message:[NSString stringWithFormat:@"%@",weakSelf.versionInfo.releaseNote] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
                        alert.tag = 10000;
                        [alert show];
                    }
                    
                } else {
                    if (flag) {
                        
//                        [HTUIHelper alertMessage:@"已经是最新版本"];
                        
                    }
                }
            } else {
                if (flag) {
                    
//                    [HTUIHelper alertMessage:@"检测失败,请稍后再试"];
                    
                }
            }
        }
        else {
            //            [HTUIHelper alertMessage:@"检测失败,请稍后再试"];
        }
        
    }];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            //            NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=%@&mt=8", APP_ID];
            NSURL *url = [NSURL URLWithString:self.versionInfo.URI];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }else if(buttonIndex ==2){
            //忽略此版本
            [self ignoreCurrentVersion];
        }
    }
}

- (void)ignoreCurrentVersion {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.versionInfo.version forKey:UDkUpdateIgnoredVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)getWhiteVerdionList {
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v2/version/ios";
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *array = (NSArray *)responseObject[@"data"];
                if (array && [array isKindOfClass:[NSArray class]]) {
                    NSDictionary *dict = [array objectAtIndex:0];
                    NSArray *whiteList = [dict objectForKey:@"ios"];
                    BOOL needUpdate = YES;
                    for (NSString *version in whiteList) {
                        NSString *verStr;
                        if (version.length > 4) {
                            verStr = [version substringToIndex:5];
                        } else {
                            verStr = version;
                        }
                        if ([verStr isEqualToString:VERSION]) {
                            needUpdate = NO;
                        }
                    }
                    if (needUpdate) {
                        [RJAppManager sharedInstance].needsForceUpdate = YES;
                    }
                    
                    [[RJAppManager sharedInstance]checkAppVersionIsInitiative:NO];
                    
                }
                
            }else{
                
                [[RJAppManager sharedInstance]checkAppVersionIsInitiative:NO];

            }
        }else{
            [[RJAppManager sharedInstance]checkAppVersionIsInitiative:NO];

        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[RJAppManager sharedInstance]checkAppVersionIsInitiative:NO];
    }];
    ///嘿嘿嘿
    
    NSString *IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];

//    if (IDFA.length) {
//        ZHRequestInfo *requestInfo2 = [ZHRequestInfo new];
//        requestInfo2.URLString = @"https://ssrj.com/api/v2/cps/aso/openApp";
//        [requestInfo2.postParams addEntriesFromDictionary:@{@"name":IDFA}];
//        [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo2 success:^(AFHTTPRequestOperation *operation, id responseObject) {
////            NSLog(@"%@",responseObject);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            
//        }];
//    }
    
    
    //生成唯一随机数
    //去当前时间 加随机数 上报服务器
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults]objectForKey:RJCustomerDeviceIDKey];
 
    if (deviceKey) {
//        NSLog(@"已存在 %@",deviceKey);
    }else{
        //生成一个新的Key
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
        NSString * timeStr = [dateFormatter stringFromDate:[NSDate date]];
        int randomX = arc4random() % 100000 + 1;
        NSString *key = [NSString stringWithFormat:@"%@-%d",timeStr,randomX];
        NSLog(@"%@",key);
        [[NSUserDefaults standardUserDefaults]setObject:key forKey:RJCustomerDeviceIDKey];
        deviceKey = key;
    
    }
    //上报服务器
    ZHRequestInfo *info = [ZHRequestInfo new];
    info.URLString = @"/b180/api/v1/statistics/uv";
    [info.getParams addEntriesFromDictionary:@{@"idfa":IDFA,@"deviceID":deviceKey}];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:info success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"--------------%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"---------------%@",error);

    }];
}
- (NSString*)currentViewControllerName{
    return NSStringFromClass([[[RJAppManager sharedInstance]currentViewController]class]);
}
- (UIViewController*)currentViewController
{
    UIViewController* vc = [self appRootViewController];
    if ([vc isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tab = (UITabBarController*)vc;
        if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* nav = (UINavigationController*)tab.selectedViewController;
            return [nav.viewControllers lastObject];
        }
        else {
            return tab.selectedViewController;
        }
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        UINavigationController* nav = (UINavigationController*)vc;
        return [nav.viewControllers lastObject];
    }
    else {
        return vc;
    }
    return nil;
}
- (UIViewController*)appRootViewController
{
    UIViewController* appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController* topVC = appRootVC;
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}
- (void)showTokenDisableLoginVc{
//    NSLog(@"===========token失效=========");
    if ([RJAccountManager sharedInstance].token) {
        [[RJAccountManager sharedInstance]unregisterAccountWithHud:NO];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        [HTUIHelper addHUDToWindowWithString:@"长时间未登录，请重新登录" hideDelay:2];
        [[self currentViewController] presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
  
}
- (void)showTokenDisableLoginVcWithMessage:(NSString *)msg{
//    NSLog(@"===========token失效=========");
    if ([RJAccountManager sharedInstance].token) {
        [[RJAccountManager sharedInstance]unregisterAccountWithHud:NO];
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        NSString *str = msg.length?msg:@"长时间未登录，请重新登录";
        [HTUIHelper addHUDToWindowWithString:str hideDelay:2];
        [[self currentViewController] presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
}
- (UINavigationController *)getLoginViewController{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
    return loginNav;
}

- (NSString *)IDFA{
    if (!_IDFA) {
        _IDFA = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }
    return _IDFA;
}

- (NSString *)nowTimeString{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd HH时"];
        [_dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    }
    
    NSString * timeStr = [_dateFormatter stringFromDate:[NSDate date]];
    return timeStr;
}
- (NSString *)nowTimeFullString{
    if (!_fullDateFormatter) {
        _fullDateFormatter = [[NSDateFormatter alloc]init];
        [_fullDateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [_fullDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    }

    NSString * timeStr = [_fullDateFormatter stringFromDate:[NSDate date]];
    return timeStr;

}

/**
 *  检测App启动图数据
 */
- (void)checkAppLaunchAdData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSNumber *DeviceType = [NSNumber numberWithInt:0];
    if (DEVICE_IS_IPHONE4) {
        
        DeviceType = [NSNumber numberWithInt:1];
    }
    else if (DEVICE_IS_IPHONE5) {
        
        DeviceType = [NSNumber numberWithInt:2];
    }
    else if (DEVICE_IS_IPHONE6) {
        
        DeviceType = [NSNumber numberWithInt:3];
    }
    else if (DEVICE_IS_IPHONE6Plus) {
        
        DeviceType = [NSNumber numberWithInt:4];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"api/v5/bootAnimation/view.jhtml?type=%@",DeviceType];
    requestInfo.URLString = urlStr;
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                LaunchAnimationModel * model = [[LaunchAnimationModel alloc] initWithDictionary:responseObject[@"data"] error:nil];
//#warning debug
//                model.endDate  = @"2017-02-09 19:58:00";
//                model.beginDate  = @"2016-12-01 19:58:00";
//                model.id = @3;
//                model.showUrl = @"http://ohnzw6ag6.bkt.clouddn.com/video0.mp4";
//                model.playTime = @10000;
//                model.forceClose = @YES;
//#warning debug

                if (model) {
                    /**
                     *  优化空间  后台返回forceClose = YES 清除本地所有数据
                     *
                     */
                    
                    if (model.forceClose&&model.forceClose.boolValue) {
                        NSLog(@"强制清除本地所有视频");
                        NSLog(@"清除本地数据");
                        [[NSUserDefaults standardUserDefaults]removeObjectForKey:CCLuanchADDataKey];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        [XHLaunchAd clearDiskCache];
                        return;
                    }
                    
                    
                    /**
                     *  判断结束时间 超出结束时间则不用下载
                     */
                    if ([model isInAvailableTimeWithModel] == 2) {
//                        NSLog(@"服务器最新的已经结束 清除本地数据");
                        [[NSUserDefaults standardUserDefaults]removeObjectForKey:CCLuanchADDataKey];
                        [[NSUserDefaults standardUserDefaults]synchronize];
                        [XHLaunchAd clearDiskCache];
                        return ;
                    }
                    
                    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:CCLuanchADDataKey];
                    if (str) {
                        LaunchAnimationModel *localModel = [[LaunchAnimationModel alloc]initWithString:str error:nil];
                        /**
                         *  和本地作对比
                         */
                        if (localModel) {
                            if (model.id.intValue > localModel.id.intValue) {
                                //去下载最新的
                                [weakSelf upLoadLocalLaunchDataWithModel:model shouldDownLoad:YES];
                            }else if(model.id.intValue == localModel.id.intValue){
                                [weakSelf upLoadLocalLaunchDataWithModel:model shouldDownLoad:NO];
                            }
                        }
                    }
                    /**
                     *  本地没有数据
                     */
                    else{
                        [weakSelf upLoadLocalLaunchDataWithModel:model shouldDownLoad:YES];
                    }
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        
    }];


}
- (void)upLoadLocalLaunchDataWithModel:(LaunchAnimationModel *)model shouldDownLoad:(BOOL)flag{
    /**
     *  保存返回的数据
     */
    if (flag) {
        //下载视频
        [[XHLaunchAdDownloader sharedDownloader] downloadVideoWithURL:[NSURL URLWithString:model.showUrl] progress:^(unsigned long long total, unsigned long long current) {
//            NSLog(@"%llu",current);
        } completed:^(NSURL * _Nullable location, NSError * _Nullable error) {
            if (!error && location) {
//                NSLog(@"下载完成 %@",[location path]);
                NSString *str2 = [model toJSONString];
                [[NSUserDefaults standardUserDefaults]
                 setObject:str2 forKey:CCLuanchADDataKey];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }];
    }else{
        NSString *str2 = [model toJSONString];
        [[NSUserDefaults standardUserDefaults]
         setObject:str2 forKey:CCLuanchADDataKey];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
#pragma mark -显示启动页视频GIF方法封装
- (void)displayLaunchAnimationWithModel:(LaunchAnimationModel *)model {
    
    //显示广告
    //gif 暂不考虑
    if ([model.showType isEqualToNumber: @1]) {
    }
    //video
    else if ([model.showType isEqualToNumber: @2]) {
        
        XHLaunchVideoAdConfiguratuon *videoAdconfiguratuon = [XHLaunchVideoAdConfiguratuon defaultConfiguratuon];
        
        //广告停留时间
        videoAdconfiguratuon.duration = model.playTime.floatValue / 1000.0;
        //广告frame
        videoAdconfiguratuon.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        //广告视频URLString/或本地视频名(请带上后缀)
        //注意:视频广告只支持先缓存,下次显示
        videoAdconfiguratuon.videoNameOrURLString = model.showUrl;
        //视频缩放模式
        videoAdconfiguratuon.scalingMode = MPMovieScalingModeAspectFill;
        //广告点击打开链接
        videoAdconfiguratuon.openURLString = @"";//暂无此需求
        //广告显示完成动画
        videoAdconfiguratuon.showFinishAnimate =ShowFinishAnimateFadein;
        //后台返回时,是否显示广告
        videoAdconfiguratuon.showEnterForeground = NO;
        //跳过按钮类型
        videoAdconfiguratuon.skipButtonType = SkipTypeTimeText;
        
        [XHLaunchAd videoAdWithVideoAdConfiguration:videoAdconfiguratuon delegate:self];
        
    }
    
}
- (NSDate *)localNowDate{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    return localeDate;
}

#pragma mark -
-(void)xhLaunchShowFinish:(XHLaunchAd *)launchAd{
    //    NSLog(@"启动广告播放完");
    [[RJAppManager sharedInstance]checkAppLaunchAdData];
    
}

#pragma mark -统计接口，上报点击事件post
- (void)reportStatisticalDataWithModel:(ReportStatisticalDataModel *)model mutableArr:(NSMutableArray *)arr{
    
    NSMutableArray *arrayM = [NSMutableArray array];

    if (arr && arr.count > 0) {
        
        for (ReportStatisticalDataModel *model in arr) {
            
            NSDictionary *dic = @{@"currentVCName":model.currentVCName,@"NextVCName":model.NextVCName,@"entranceType":model.entranceType,@"entranceTypeId":model.entranceTypeId,@"tapId":model.tapId?:@""};
            
            [arrayM addObject:dic];
        }
    }
    
    NSString *JSONString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:arrayM options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"upload_type":model.entranceType,@"upload_infor":model.entranceTypeId, @"json":JSONString}];
    
//    NSString *str = @"http://report.ssrj.com/api/v1/statistics/upload";
    NSString *str = @"/b180/api/v1/statistics/upload";
    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = str;
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[responseObject objectForKey:@"msg"] hideDelay:1];
                
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[error localizedDescription] hideDelay:1];
        
    }];
    

}
#pragma mark -
//- (NSNumber *)getCustomerIdWithView:(UIView *)view rootView:(UIView *   )rootView TagId:(NSInteger)tag{
//    rootView.customerTreeId = [NSNumber numberWithInteger:tag];
//    if (view == rootView) {
//        return [NSNumber numberWithInteger:tag];
//    }
//    for (UIView * subView in rootView.subviews) {
//        if ([subView isKindOfClass:[RJClickCountLabel class]]) {
//            continue;
//        }
//        tag++;
//        subView.customerTreeId = [NSNumber numberWithInteger:tag];
//        if (subView == view) {
//            return [NSNumber numberWithInteger:tag];
//        }
//       
//        NSNumber *num = [self getCustomerIdWithView:view rootView:subView TagId:tag];
//        if (num.integerValue!= NSIntegerMax) {
//            return num;
//        }
//    }
//    return [NSNumber numberWithInteger:NSIntegerMax];
//}
//- (NSString *)getCustomerIdentiferWihtView:(UIView *)viewOne{
//    
//    UIView *view = viewOne.superview;
//    while (view) {
//        //        NSLog(@"%@",view);
//        UIView *view2 = view.superview;
//        if (view2== nil) {
//            [[RJAppManager sharedInstance]getCustomerIdWithView:viewOne rootView:view TagId:1];
//            
//        }
//        view = view2;
//    }
//    
//    NSMutableArray *arr = [NSMutableArray array];
//    if (viewOne.customerTreeId) {
//        [arr addObject:viewOne.customerTreeId];
//    }
//    UIView *superView = viewOne.superview;
//    while (superView) {
//        if (superView.customerTreeId) {
//            [arr addObject:superView.customerTreeId];
//        }
//        superView = superView.superview;
//    }
//    
//    NSString *className = NSStringFromClass([[RJAppManager sharedInstance]currentViewController].class);
//    [arr addObject:className];
//    NSArray *arr2 = [[arr reverseObjectEnumerator]allObjects];
//    if (arr2.count&& !viewOne.trackingId.length) {
//        [viewOne setTrackingId:[arr2 componentsJoinedByString:@"-"]];
////        NSLog(@"%@",viewOne.trackingId);
//    }
//    return viewOne.trackingId;
//}
- (BOOL)scanAllViewWithView:(UIView *)view{
    if (view.trackingId) {
        if ([RJAppManager sharedInstance].trackingDebug) {
            RJClickCountLabel *label = [[RJClickCountLabel alloc]initWithFrame:CGRectMake(0, 0, 30, 10)];
            label.backgroundColor = [UIColor blueColor];
            view.numView = label;
            [view showLabel];
        }else{
            [view removeLabel];
        }
    }
    if (!view.subviews.count) {
        return NO;
    }
    for (UIView *subView in view.subviews) {
        if (subView.trackingId.length) {
            if ([RJAppManager sharedInstance].trackingDebug) {
                //                NSLog(@"找到button%@",subView);
                RJClickCountLabel *label = [[RJClickCountLabel alloc]initWithFrame:CGRectMake(0, 0, 30, 10)];
                label.backgroundColor = [UIColor blueColor];
                view.numView = label;
                [view showLabel];
                //                [button.numView ccSizeFit];
                
            }else{
                [view removeLabel];
            }
            
        }
        [self scanAllViewWithView:subView];
    }
    return YES;
}
/**
 *  目标被点击了 插入表格
 */
- (void)trackingWithTrackingId:(NSString *)trackingId{
//    NSLog(@"插入表格 %@",trackingId);
    RJTrackingModel *model = [[RJTrackingModel alloc]init];
    model.trackingId = trackingId;
    model.date = [[RJAppManager sharedInstance]nowTimeFullString];
    [LKDBHelper insertByAsyncToDB:model];
    
}
#pragma mark - 遍历数据库 生成上报数据
- (void)uploapTrackingDataWithSql{
   NSMutableArray *arr = [RJTrackingModel searchWithWhere:nil];
    if (arr.count) {
        RJTrackingArrayModel *dataModel = [[RJTrackingArrayModel alloc]init];
        //清除数据库
//        [LKDBHelper clearTableData:[RJTrackingModel class]];
        if ([RJTrackingModel deleteWithWhere:nil]) {
//            NSLog(@"清除数据了");
        }else{
//            NSLog(@"清除失败");
        }
        
        dataModel.dataArray = [arr copy];
        
        NSString *jsonString = [dataModel toJSONString];
//        NSLog(@"%@",jsonString);
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        requestInfo.URLString = @"/b180/api/v1/statistics/count";
        NSString *deviceKey = [[NSUserDefaults standardUserDefaults]objectForKey:RJCustomerDeviceIDKey];
        if (!deviceKey.length) {
            deviceKey = @"";
        }
        __weak __typeof(&*self)weakSelf = self;
        /**
         *  上报服务器接口
         */
        requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{@"idfa":self.IDFA,@"deviceID":deviceKey,@"json":jsonString}];
        [[ZHNetworkManager sharedInstance]postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //有返回就默认上传成功了
//            NSLog(@"成功上报了 %lu条数据",(unsigned long)[arr count]);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"需要延迟上报");
            //延迟30秒再次上报
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf delayUploapTrackingDataWithJsonString:jsonString];
            });
        }];
    }
    //https://ssrj.com/b180/api/v1/statistics/getcount?tracking_id=GoodsDetailViewController_back:_200
    //https://ssrj.com/b180/api/v1/statistics/getcount?tracking_id=GoodsDetailViewController_back:_200
}
- (void)delayUploapTrackingDataWithJsonString:(NSString *)jsonString{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b180/api/v1/statistics/count";
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults]objectForKey:RJCustomerDeviceIDKey];
    if (!deviceKey.length) {
        deviceKey = @"";
    }
    /**
     *  上报服务器接口
     */
    requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{@"idfa":self.IDFA,@"deviceID":deviceKey,@"json":jsonString}];
    [[ZHNetworkManager sharedInstance]postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //有返回就默认上传成功了
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //延迟30秒上报依旧失败则不再上报 存入数据库
//        NSLog(@"延迟上报失败  插入表");
        RJTrackingJsonStringModel *model = [[RJTrackingJsonStringModel alloc]init];
        model.jsonString = jsonString;
        [LKDBHelper insertByAsyncToDB:model];
    }];
    
}
/**
 *  上次上传失败的存在表里 继续上传
 */
- (void)uploapTrackingJsonStingWithSql{
    NSMutableArray *arr = [RJTrackingJsonStringModel searchWithWhere:nil];
    if ([arr count]) {
        for (RJTrackingJsonStringModel *model in arr) {
            ZHRequestInfo *requestInfo = [ZHRequestInfo new];
            requestInfo.URLString = @"/b180/api/v1/statistics/count";
            NSString *deviceKey = [[NSUserDefaults standardUserDefaults]objectForKey:RJCustomerDeviceIDKey];
            if (!deviceKey.length) {
                deviceKey = @"";
            }
            /**
             *  上报服务器接口
             */
            if (!model.jsonString) {
                continue;
            }
            requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{@"idfa":self.IDFA,@"deviceID":deviceKey,@"json":model.jsonString}];
            [[ZHNetworkManager sharedInstance]postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                //有返回就默认上传成功了 然后删除表里数据
                [model deleteToDB];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                //不做处理
            }];
        }
    }
}
@end
