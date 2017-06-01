//
//  UseRuleForRedbagViewController.m
//  ssrj
//
//  Created by YiDarren on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UseRuleForRedbagViewController.h"
#define baseUrlString @"https://m.ssrj.com/views/commons/coupon/coupon_desc.jsp"

@interface UseRuleForRedbagViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

@end

@implementation UseRuleForRedbagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"红包使用说明";
    
    self.webView.delegate = self;
    
    self.webView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    [self.view addSubview:self.webView];
    
    // for webView
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:baseUrlString]]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"红包使用说明页面"];
    [TalkingData trackPageBegin:@"红包使用说明页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"红包使用说明页面"];
    [TalkingData trackPageEnd:@"红包使用说明页面"];
}

- (UIWebView *)webView {
    
    if (_webView == nil) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    }
    return _webView;
}

#pragma mark --UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"正在加载..." xOffset:0 yOffset:0];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    [[HTUIHelper shareInstance] removeHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:( NSError *)error{
    
    [[HTUIHelper shareInstance] removeHUDWithEndString:@"网络有误..." image:nil delyTime:2.5];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
