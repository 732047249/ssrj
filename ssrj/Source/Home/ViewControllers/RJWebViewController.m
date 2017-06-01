
#import "RJWebViewController.h"
#import "UIWebView+AFNetworking.h"
#import "GoodsDetailViewController.h"
#import "CollectionsViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#import "HomeGoodListViewController.h"
#import "RJBrandDetailRootViewController.h"
#import "RJPushWebViewController.h"

@interface RJWebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate,UMSocialUIDelegate>{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}
@end

@implementation RJWebViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    if (self.shareModel) {
        [self addBarButtonItem:RJNavShareButtonItem onSide:RJNavRightSide];
    }
    self.view.trackingId = [NSString stringWithFormat:@"RJWebViewController&viewWillAppear&webId=%@",self.webId];
//#warning debug
//    self.urlStr = @"http://192.168.1.56:8090/ssrj-h5/views/index/pajama_party.jsp";
    _progressProxy = [[NJKWebViewProgress alloc]init];
    self.webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]]];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.isPushIn) {
        [MobClick beginLogPageView:@"推送活动界面"];
        [TalkingData trackPageBegin:@"推送活动界面"];


    }else{
        [MobClick beginLogPageView:@"首页banner活动页面"];
        [TalkingData trackPageBegin:@"首页banner活动页面"];

    }
    [self.navigationController.navigationBar addSubview:_progressView];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.isPushIn) {
        [MobClick endLogPageView:@"推送活动界面"];
        [TalkingData trackPageEnd:@"推送活动界面"];
        
    }else{
        [MobClick endLogPageView:@"首页banner活动页面"];
        [TalkingData trackPageEnd:@"首页banner活动页面"];
    }
    [_progressView removeFromSuperview];
    
    // add 12.19
    [[RJAppManager sharedInstance].statisticalModelArr removeLastObject];

}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *urlstr = request.URL.absoluteString;
    if ([urlstr hasPrefix:@"app-ssrj:"]) {
//        NSLog(@"拦截请求%@",urlstr);
        NSArray *arr = [urlstr componentsSeparatedByString:@":"];
        NSString *str = arr.lastObject;
        if (str.length) {
            NSArray *parametArr = [str componentsSeparatedByString:@"&"];
            NSString *str2 = parametArr.firstObject;
            NSArray *valueArr = [str2 componentsSeparatedByString:@"="];
            if (valueArr.count == 2) {
                NSString * value1 = [valueArr firstObject];
                NSString *value2 = [valueArr lastObject];
                if ([value1 isEqualToString:@"goodsId"]) {
                    //单品详情
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
                    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
                    NSNumber *goodId2 = (NSNumber *)value2;
                    goodsDetaiVC.goodsId = goodId2;
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//                    statisticalDataModel.entranceType = _webId;
//                    statisticalDataModel.entranceTypeId = goodId2;
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    
                    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
                }
                if ([value1 isEqualToString:@"collocationId"]) {
                    //搭配详情
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
                    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
                    collectionViewController.collectionId = (NSNumber *)value2;
                    
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//                    statisticalDataModel.entranceType = _webId;
//                    statisticalDataModel.entranceTypeId = (NSNumber *)value2;
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    [self.navigationController pushViewController:collectionViewController animated:YES];

                }
                
            }
        }
        return NO;
        
    }
    else if ([urlstr hasPrefix:@"app-userid-ssrj:"]){
        if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
            NSString * func = [NSString stringWithFormat:@"app_ssrj_JSAction_userId('%@');",[RJAccountManager sharedInstance].account.id];
            [self.webView stringByEvaluatingJavaScriptFromString:func];
        }else{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self presentViewController:loginNav animated:YES completion:^{
                
            }];
            return NO;
        }
        return NO;
    }
    /**
     *  点击多个按钮 获取按钮的tag值，然后调用JS函数
     *
     *  @param hasPrefix:@"app-userid-ssrj-tag:"] 定义的拦截事件
        JS函数名固定app_ssrj_JSAction_userId_tag(userid,tag)
     */
    else if([urlstr hasPrefix:@"app-userid-ssrj-tag:"]){
        if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
           [self presentViewController:[[RJAppManager sharedInstance]getLoginViewController] animated:YES
        completion:^{
            
        }];
            return NO;
        }else{
            NSArray *arr = [urlstr componentsSeparatedByString:@":"];
            NSString *str = arr.lastObject;
            if (str.length) {
                NSArray *valueArr = [str componentsSeparatedByString:@"="];
                if (valueArr.count == 2) {
                    NSString *tag = valueArr.lastObject;
                    NSString * func = [NSString stringWithFormat:@"app_ssrj_JSAction_userId_tag('%@','%@');",[RJAccountManager sharedInstance].account.id,tag];
                    [self.webView stringByEvaluatingJavaScriptFromString:func];

                }
            }

        }
        return NO;
    }
    /**
     *  2.2.0扩展的跳转原生界面
     *
     * 1、app-ssrj-pushNative:type=1&tagsId=88
     * 2、app-ssrj-pushNative:type=2&brands=99
     * 3、app-ssrj-pushNative:type=3&id=77(调用接口/api/v5/event/view.jhtml?appVersion=xx&token=xx&id=xx取数据)
     *  @param hasPrefix:@"app-ssrj-pushNative:"]
     
     */
    else if([urlstr hasPrefix:@"app-ssrj-pushnative:"]){
        NSArray *arr = [urlstr componentsSeparatedByString:@":"];
        NSLog(@"%@",arr);
        if (arr.count == 2) {
            NSString *str2 = arr.lastObject;
            NSArray *itemArr = [str2 componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&="]];
            if (itemArr.count == 4) {
                NSString *type = itemArr[1];
                if ([type isEqualToString:@"1"]) {
                    NSDictionary *dic = @{itemArr[2]:itemArr[3]};
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    HomeGoodListViewController *goodListVc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
                    goodListVc.parameterDictionary = [dic copy];
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(goodListVc.class);
//                    statisticalDataModel.entranceType = _webId;
//                    NSNumber *tagsId = [dic objectForKey:@"tagsId"];
//                    if (tagsId) {
//                        statisticalDataModel.entranceTypeId = tagsId;
//                    }
//                    else {
//                        statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//                    }
//                    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    
                    [self.navigationController pushViewController:goodListVc animated:YES];
                    
                }else if([type isEqualToString:@"2"]){
                    NSDictionary *dic = @{itemArr[2]:itemArr[3]};
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
                    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
                    rootVc.parameterDictionary = dic;
                    NSString *idStr = itemArr.lastObject;
                    rootVc.brandId = [NSNumber numberWithInt:[idStr intValue]];
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(rootVc.class);
//                    statisticalDataModel.entranceType = _webId;
//                    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:[idStr intValue]];
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    [self.navigationController pushViewController:rootVc animated:YES];
                }
                else if([type isEqualToString:@"3"]){
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Can" bundle:nil];
                    RJPushWebViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJPushWebViewController"];
                    NSString *idStr = itemArr.lastObject;
                    vc.activityId = [NSNumber numberWithInt:[idStr intValue]];
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//                    statisticalDataModel.entranceType = _webId;
//                    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:[idStr intValue]];
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
        return NO;
    }
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
//    NSLog(@"开始加载");
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setTitle:title tappable:NO];
    });}

#pragma mark -
#pragma mark 分享
- (void)share:(id)sender{
    
//    NSArray *shareType = [NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,nil];
    NSArray *shareType = [NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,nil];

    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    NSString *imageUrl = self.shareModel.img;
    NSString *comment = self.shareModel.memo;
    NSString *shareUrl = self.shareModel.shareUrl.length?self.shareModel.shareUrl:@"www.ssrj.com";
    [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = self.shareModel.title;
    
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qqData.title = self.shareModel.title;
    
    [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qzoneData.title = self.shareModel.title;
    
    [UMSocialData defaultData].extConfig.sinaData.shareText =[NSString stringWithFormat:@"%@%@",comment,shareUrl];
    
    //调用快速分享接口
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
//    if (!imageUrl.length) {
//        [UMSocialData defaultData].shareImage = [UIImage imageNamed:@"Icon_for_share"];
//    }
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UmengAppkey
                                      shareText:comment
                                     shareImage:nil
                                shareToSnsNames:shareType
                                       delegate:self];
    
}
-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    //    NSLog(@"didClose is %d",fromViewControllerType);
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
//        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        if (!self.webId) {
            self.webId = @0;
        }
        requestInfo.URLString =[NSString stringWithFormat:@"/b180/api/v1/point/variation?type=35&id=%d",self.webId.intValue];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        NSLog(@"%@",error);
        }];
    }
}

//下面设置点击分享列表之后，可以直接分享
//-(BOOL)isDirectShareInIconActionSheet
//{
//    return YES;
//}

//-(UMSocialShakeConfig)didShakeWithShakeConfig
//{
//    //下面可以设置你用自己的方法来得到的截屏图片
////    [UMSocialShakeService setScreenShotImage:[UIImage imageNamed:@"UMS_social_demo"]];
//    return UMSocialShakeConfigDefault;
//}

//-(void)didCloseShakeView
//{
//    NSLog(@"didCloseShakeView");
//}

-(void)didFinishShareInShakeView:(UMSocialResponseEntity *)response
{
    //    NSLog(@"finish share with response is %@",response);
}

@end
