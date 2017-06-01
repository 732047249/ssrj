//
//  ActivityViewController.m
//  ssrj
//
//  Created by MFD on 16/8/10.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ActivityViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "GoodsDetailViewController.h"
#import "CollectionsViewController.h"
#import "RJHomeShareViewController.h"
#import "WXApi.h"
#import "RJPushWebViewController.h"
#import "HomeGoodListViewController.h"
#import "RJBrandDetailRootViewController.h"
@interface ActivityViewController ()<UIWebViewDelegate,UMSocialUIDelegate,NJKWebViewProgressDelegate>
{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}
@end

@implementation ActivityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//#warning debug
//    self.show_url = @"http://www.ssrj.com/share/app/share.jhtml";
    [self addBackButton];
    NSArray *arr = @[@2];
    [self addBarButtonItems:arr onSide:RJNavRightSide];
    
    _progressProxy = [[NJKWebViewProgress alloc]init];
    self.webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;

    
    if (self.show_url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.show_url]]];
    }
}
#pragma mark -webViewDelegate
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
                    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
                }
                if ([value1 isEqualToString:@"collocationId"]) {
                    //搭配详情
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
                    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
                    collectionViewController.collectionId = (NSNumber *)value2;
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
//        NSLog(@"%@",arr);
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
                    [self.navigationController pushViewController:goodListVc animated:YES];
                    
                }else if([type isEqualToString:@"2"]){
                    NSDictionary *dic = @{itemArr[2]:itemArr[3]};
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
                    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
                    rootVc.parameterDictionary = dic;
                    NSString *idStr = itemArr.lastObject;
                    rootVc.brandId = [NSNumber numberWithInt:[idStr intValue]];
                    [self.navigationController pushViewController:rootVc animated:YES];
                }
                else if([type isEqualToString:@"3"]){
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Can" bundle:nil];
                    RJPushWebViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJPushWebViewController"];
                    NSString *idStr = itemArr.lastObject;
                    vc.activityId = [NSNumber numberWithInt:[idStr intValue]];
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
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //        NSLog(@"加载完成");
    //    [[HTUIHelper shareInstance]removeHUD];
    //    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //    [self setTitle:title tappable:NO];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setTitle:title tappable:NO];
    });
}


#pragma mark - share
- (void)share:(id)sender{
    if (!self.shareType.length || [self.shareType isEqualToString:@"0,1"]) {
        if (![WXApi isWXAppInstalled]) {
            //        [HTUIHelper addHUDToWindowWithString:@"请下载微信客户端" hideDelay:2];
            [HTUIHelper alertMessage:@"请安装微信客户端"];
            return;
        }
        
    }

    if (self.isLogin) {
        if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self presentViewController:loginNav animated:YES completion:^{
                
            }];
            return;
        }else{
            if (self.share_url) {
                [self getShareData];
            }
        }
        
    }else{
        [self getShareData];
    }

}

#pragma mark -lifeCircle
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar addSubview:_progressView];
    
    [MobClick beginLogPageView:@"活动弹窗页面"];
    [TalkingData trackPageBegin:@"活动弹窗页面"];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
    
    [MobClick endLogPageView:@"活动弹窗页面"];
    [TalkingData trackPageEnd:@"活动弹窗页面"];

}


- (void)getShareData{
//#warning debug
//    
//    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
//    
//    NSString *imageUrl = @"http://www.ssrj.com/resources/shop/mobile/images/gift_share.jpg";
//    NSString *comment =  @"测试描述";
//    NSString *shareUrl = @"http://www.ssrj.com/share/mobile/shareReceive/16149/723.jhtml";
//    [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
//    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"测试标题";
//    [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
//    [HTUIHelper removeHUDToWindow];
//    
//    
//    NSArray *types = [self.shareType componentsSeparatedByString:@","];
//    NSMutableArray *mArr = [NSMutableArray array];
//    for (NSString *str in types) {
//        if ([str isEqualToString:@"0"]) {
//            [mArr addObject:UMShareToWechatSession];
//        }
//        if ([str isEqualToString:@"1"]) {
//            [mArr addObject:UMShareToWechatTimeline];
//            
//        }
//        if ([str isEqualToString:@"2"]) {
//            [mArr addObject:UMShareToSina];
//            [UMSocialData defaultData].extConfig.sinaData.shareText =[NSString stringWithFormat:@"%@%@",comment,shareUrl];
//            
//        }
//        if ([str isEqualToString:@"3"]) {
//            [mArr addObject:UMShareToQQ];
//            [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
//            [UMSocialData defaultData].extConfig.qqData.title = @"测试标题";
//            
//        }
//        if ([str isEqualToString:@"4"]) {
//            [mArr addObject:UMShareToQzone];
//            [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
//            [UMSocialData defaultData].extConfig.qzoneData.title = @"测试标题";
//        }
//    }
//    
//    NSArray *shareType = [NSArray arrayWithArray:[mArr copy]];
//    //调用快速分享接口
//    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
//    
//    [UMSocialSnsService presentSnsIconSheetView:self
//                                         appKey:UmengAppkey
//                                      shareText:comment
//                                     shareImage:nil
//                                shareToSnsNames:shareType
//                                       delegate:self];
//    return;
    
    
    
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    if (self.share_url) {
        requestInfo.URLString = self.share_url;
    }
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.activityId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"activityVersion":@1.0,@"id":self.activityId}];
    }
//    __weak __typeof(&*self)weakSelf = self;
    
    [HTUIHelper addHUDToWindowWithString:@"获取分享地址中"];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state.intValue == 0) {
            if (!self.shareType.length) {
                self.shareType = @"0,1";
            }
  

            RJHomeShareModel *model = [[RJHomeShareModel alloc]initWithDictionary:responseObject[@"data"] error:nil];;
            [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
            
            NSString *imageUrl = model.share_img;
            NSString *comment =  model.content;
            NSString *shareUrl = model.redirectUrl;
            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = model.title;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
            [HTUIHelper removeHUDToWindow];
            
            
            NSArray *types = [self.shareType componentsSeparatedByString:@","];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSString *str in types) {
                if ([str isEqualToString:@"0"]) {
                    [mArr addObject:UMShareToWechatSession];
                }
                if ([str isEqualToString:@"1"]) {
                    [mArr addObject:UMShareToWechatTimeline];
                    
                }
                if ([str isEqualToString:@"2"]) {
                    [mArr addObject:UMShareToSina];
                    [UMSocialData defaultData].extConfig.sinaData.shareText =[NSString stringWithFormat:@"%@%@",comment,shareUrl];

                }
                if ([str isEqualToString:@"3"]) {
                    [mArr addObject:UMShareToQQ];
                    [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
                    [UMSocialData defaultData].extConfig.qqData.title = model.title;
                    
                }
                if ([str isEqualToString:@"4"]) {
                    [mArr addObject:UMShareToQzone];
                    [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
                    [UMSocialData defaultData].extConfig.qzoneData.title = model.title;
                }
            }
            [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];

            NSArray *shareType = [NSArray arrayWithArray:[mArr copy]];
            //调用快速分享接口
//#warning  debug
//            imageUrl =@"http://www.ssrj.com/resources/shop/mobile/images/huodong/160812/icon.png";
                [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
            
                [UMSocialSnsService presentSnsIconSheetView:self
                                                     appKey:UmengAppkey
                                                  shareText:comment
                                                 shareImage:nil
                                            shareToSnsNames:shareType
                                                   delegate:self];
            [HTUIHelper removeHUDToWindow];

        }else if(state.intValue == 1){
            [HTUIHelper removeHUDToWindowWithEndString:responseObject[@"msg"] image:nil delyTime:2];
        }
//        else if(state.intValue == 2){
//            if ([RJAccountManager sharedInstance].token) {
//                [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//            }
//        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [HTUIHelper removeHUDToWindowWithEndString:@"请求失败，请稍后再试" image:nil delyTime:2];
    }];

}
//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
//    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {

        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        if (!self.activityId) {
            self.activityId = @0;
        }
        requestInfo.URLString =[NSString stringWithFormat:@"/b180/api/v1/point/variation?type=35&id=%d",self.activityId.intValue];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //                        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //                        NSLog(@"%@",error);
        }];
    }
}
@end
