//
//  AboutUsViewController.m
//  ssrj
//
//  Created by YiDarren on 16/7/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AboutUsViewController.h"

#define baseUrlString @"https://www.ssrj.com/mobile/app_about.jhtml"

@interface AboutUsViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AboutUsViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"关于我们页面"];
    [TalkingData trackPageBegin:@"关于我们页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"关于我们页面"];
    [TalkingData trackPageEnd:@"关于我们页面"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"关于我们";
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.ssrj.com/mobile/app_about.jhtml"]]];
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
