//
//  VipLevelViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "VipLevelViewController.h"
#define baseUrlString @"https://ssrj.com/common/memberGrade.jhtml"

@interface VipLevelViewController ()<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *vipLevelWebView;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *LevelImageView;

@property (weak, nonatomic) IBOutlet UILabel *levelDescribe;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *jifenLabelX;

@property (weak, nonatomic) IBOutlet UILabel *userPointLabel;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
//进度条左边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewX;
//进度条右边距
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewY;

@end

@implementation VipLevelViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [MobClick beginLogPageView:@"会员等级页面"];
    [TalkingData trackPageBegin:@"会员等级页面"];

    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"会员等级页面"];
    [TalkingData trackPageEnd:@"会员等级页面"];

}

- (void)setUerInfoDataActionWithAccount:(RJAccountModel *) account{
    
    //----------------用户属性设置----------------
    //用户头像
    NSString *imageStr = account.avatar;
    NSURL *imageUrl = [NSURL URLWithString:imageStr];
    
    [_userImageView sd_setImageWithURL:imageUrl];
    
    //用户名称
    _userNameLabel.text = account.username;
    _userPointLabel.text = [account.point stringValue];
    //会员等级
    if ([account.memberRank intValue] == 1) {
        _levelDescribe.text = @"铜牌会员";
        _LevelImageView.image = [UIImage imageNamed:@"Bronze_icon"];
    }
    if ([account.memberRank intValue] == 2) {
        _levelDescribe.text = @"银牌会员";
        _LevelImageView.image = [UIImage imageNamed:@"Silver_icon"];
    }
    if ([account.memberRank intValue] == 3) {
        _levelDescribe.text = @"金牌会员";
        _LevelImageView.image = [UIImage imageNamed:@"Gold_icon"];
    }

    //积分进度条
//    此方法不出进度条颜色效果
//    _progressView.progressTintColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"progressColor"]];
    
    _progressView.progressTintColor = [UIColor blueColor];
    _progressView.backgroundColor = [UIColor whiteColor];
    _progressView.trackTintColor = [UIColor lightGrayColor];
    
    _progressViewX.constant = SCREEN_WIDTH*0.125;
    _progressViewY.constant = SCREEN_WIDTH*0.125;
    
    int jifen = [account.point intValue];
    
////    test
//    jifen = 70000;
//    _userPointLabel.text = [NSString stringWithFormat:@"%d", jifen];
    
    
    if (jifen <= 20000) {
        _progressView.progress = 0.5*jifen/20000.0;
    }
    if (jifen > 20000 && jifen <= 59999) {
        _progressView.progress = 0.5+0.5*(jifen-20000.0)/40000.0;
    }
    if (jifen >= 60000) {
        _progressView.progress = 1.01;
    }
    _jifenLabelX.constant = SCREEN_WIDTH/8.0+_progressView.progress*_progressView.frame.size.width-30;
}




- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self addBackButton];
    self.title = @"会员等级";
    
    _userImageView.layer.cornerRadius = 20.0f;
    _userImageView.clipsToBounds = YES;
    
    __weak __typeof(&*self)weakSelf = self;
    
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    
    [self.scrollView.mj_header beginRefreshing];
    
// for webView
    self.view.backgroundColor = [UIColor whiteColor];
    
    _webView.userInteractionEnabled = NO;
    _webView.scrollView.scrollEnabled = NO;
    
    NSURL *url = [NSURL URLWithString:baseUrlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    [_webView loadRequest:request];
    
}


-(void)getData {
    
    __weak typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/index.jhtml"];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
                
            NSNumber *state = [responseObject objectForKey:@"state"];
                
            if ([state intValue] == 0) {
                //请求成功
                NSDictionary *dic = [responseObject objectForKey:@"data"];
                    
                RJAccountModel *account = [[RJAccountModel alloc] initWithDictionary:dic error:nil];
                    
                //将网络数据存于本地
                [[RJAccountManager sharedInstance] registerAccount:account];
                    
                //----------------用户属性设置----------------
                [weakSelf setUerInfoDataActionWithAccount:account];
                    
            } else {
                    
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
                
        }
        
        [weakSelf.scrollView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.scrollView.mj_header endRefreshing];
        
    }];
}




#pragma mark --UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"正在加载..." xOffset:0 yOffset:0];
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
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
