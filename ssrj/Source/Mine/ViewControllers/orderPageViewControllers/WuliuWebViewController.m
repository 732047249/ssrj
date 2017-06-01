//
//  WuliuWebViewController.m
//  ssrj
//
//  Created by YiDarren on 16/7/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "WuliuWebViewController.h"

//#define urtString @"http://www.ssrj.com/api/v2/member/order/logistics.jhtml?token=xxx&shippingSn=发货单号"


@interface WuliuWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webVeiw;

@end

@implementation WuliuWebViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"物流页面"];
    [TalkingData trackPageBegin:@"物流页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"物流页面"];
    [TalkingData trackPageEnd:@"物流页面"];

}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    _webVeiw.userInteractionEnabled = YES;
    _webVeiw.scrollView.scrollEnabled = YES;
    NSString *string = _wuliuUrlString;
    
    NSURL *url = [NSURL URLWithString:string];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    [_webVeiw loadRequest:request];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [[HTUIHelper shareInstance]removeHUD];
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中" xOffset:0 yOffset:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
