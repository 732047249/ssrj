//
//  HHHTMLViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHHTMLViewController.h"

@interface HHHTMLViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation HHHTMLViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    [self setTitle:@"预览" tappable:NO];
    self.webView = ({
        UIWebView *webView = [[UIWebView alloc] init];
        webView.dataDetectorTypes = UIDataDetectorTypeNone;
        [self.view addSubview:webView];
        webView;
    });
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self.webView loadHTMLString:self.HTMLString baseURL:nil];
    [MobClick beginLogPageView:@"创建资讯-预览页面"];
    [TalkingData trackPageBegin:@"创建资讯-预览页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建资讯-预览页面"];
    [TalkingData trackPageEnd:@"创建资讯-预览页面"];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.webView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setHTMLString:(NSString *)HTMLString {
    
    _HTMLString = [HTMLString copy];
    if (self.webView) {
        [self.webView loadHTMLString:HTMLString baseURL:nil];
    }
}

@end
