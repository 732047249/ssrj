//
//  UnusedHongBaoTableTableViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UnusedHongBaoTableTableViewController.h"
#import "HongBaoViewController.h"
#import "CouponCellTableViewCell.h"
#import "CouponModel.h"
#import "NSAttributedString+YYText.h"
#import "CouponCodeTableViewCell.h"

static NSString *cellID = @"couponCell";

@interface UnusedHongBaoTableTableViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) CouponModel *couponModel;

@property (strong, nonatomic) NSMutableArray *dataArr;

@end

@implementation UnusedHongBaoTableTableViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"未使用的红包页面"];
    [TalkingData trackPageBegin:@"未使用的红包页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"未使用的红包页面"];
    [TalkingData trackPageEnd:@"未使用的红包页面"];

}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArr = [NSMutableArray array];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
    [self setHidesBottomBarWhenPushed:YES];
    __weak typeof(&*self)weakSelf = self;
    
    
    self.tableView.tableHeaderView = nil;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
        
    }];

    [self.tableView registerNib:[UINib nibWithNibName:@"CouponCodeTableViewCell" bundle:nil] forCellReuseIdentifier:@"CouponCodeTableViewCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CouponCellTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    [weakSelf.tableView.mj_header beginRefreshing];

}

-(void)getData{
    
    __weak typeof(&*self)weakSelf = self;
    
    //取用户ID(字段不规范)
     NSNumber *userId = [[RJAccountManager sharedInstance] account].id;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //取token
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"/b82/api/v2/user/findcoupon?userId=%@", userId];

//    NSString *urlStr = [NSString stringWithFormat:@"http://www.ssrj.com/api/v2/logout.jhtml?token=163706d51f7c2facc3ddb5d9207fb247"];
//#warning debug
//    [RJAccountManager sharedInstance].account.token = @"12345";
    requestInfo.URLString = urlStr;

//    [HTUIHelper addHUDToWindowWithString:@"加载中..."];
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
                
                NSNumber *state = [responseObject objectForKey:@"state"];
                //请求成功，后续模型赋值操作
                if (state.intValue == 0) {
                    
                    //未用优惠券
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    NSArray *expireCouponArr = [data objectForKey:@"notUsedCoupon"];
                    
                    [weakSelf.dataArr removeAllObjects];
                    
                    NSMutableArray *arrayModels = [NSMutableArray array];
                    
                    for (NSDictionary *tempDic in expireCouponArr) {
                        
                        CouponModel *model = [[CouponModel alloc] initWithDictionary:tempDic error:nil];
                        [arrayModels addObject:model];
                    }
                    weakSelf.dataArr = [arrayModels mutableCopy];
                    [weakSelf.tableView reloadData];

                }
                else if(state.intValue == 1){
                    
                    [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                    
                }else if(state.intValue ==2){
                    
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
                }
                
                
        }
        
        else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data sourc

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }else{
        return self.dataArr.count;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        CouponCodeTableViewCell *codeCell = [tableView dequeueReusableCellWithIdentifier:@"CouponCodeTableViewCell"];
        codeCell.textField.tag = 1000;
        codeCell.textField.userInteractionEnabled = YES;
        [codeCell.duiHuanBtn addTarget:self action:@selector(duihuan) forControlEvents:UIControlEventTouchUpInside];

        return codeCell;
    }else{
        
        CouponCellTableViewCell *couponCell = [tableView dequeueReusableCellWithIdentifier:cellID];

        //直接取值即可
        CouponModel *model = self.dataArr[indexPath.row];
        
        couponCell.couponImageView.image = [UIImage imageNamed:@"Coupon_Enable"];
        couponCell.couponStateImageView.hidden = YES;
        couponCell.moneyLabel.text = [model.price stringValue];
        couponCell.deadLineLabel.text = model.memo;
        [couponCell.topButton addTarget:self action:@selector(topButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//        couponCell.useRuleButton.tag = indexPath.row;
//        [couponCell.useRuleButton addTarget:self action:@selector(useRuleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if (model.remark.length) {
            
            CGRect frame = couponCell.deadLineLabel.frame;
            frame.origin.x = SCREEN_WIDTH-70;
            frame.origin.y = SCREEN_WIDTH*0.432-50;
            frame.size = CGSizeMake(50, 35);
            UILabel *useRuleLabel = [[UILabel alloc]initWithFrame:frame];
            useRuleLabel.text = @"使用规则";
            useRuleLabel.textColor = [UIColor colorWithHexString:@"#5D32B5"];
            useRuleLabel.font = [UIFont systemFontOfSize:11];
            useRuleLabel.userInteractionEnabled = YES;
            couponCell.useRuleLabel = useRuleLabel;
            couponCell.useRuleLabel.tag = indexPath.row;
            [couponCell addSubview:useRuleLabel];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandle:)];
            tapGesture.delegate = self;
            couponCell.useRuleLabel.userInteractionEnabled = YES;
            [couponCell.useRuleLabel addGestureRecognizer:tapGesture];
            
        }
        
        //使用说明字体不同颜色
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", model.useRule]];
        text.yy_font = [UIFont systemFontOfSize:11];
        text.yy_color = [UIColor colorWithHexString:@"#b1b1b1"];
        text.yy_alignment = NSTextAlignmentCenter;
        
        //有空字段，赋值崩掉
        //    [text yy_setColor:[UIColor colorWithHexString:@"#fba5a5"] range:NSMakeRange(model.useRule.length, model.name.length+2)];
        
        couponCell.howToUseLabel.attributedText = text;
        
        return couponCell;
    }
    
}

#pragma mark --红包使用规则label点击
- (void)tapGestureHandle:(UITapGestureRecognizer *)tapGesture {
    
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    CouponModel *model = self.dataArr[tapGesture.view.tag];
    
    UIView *fullScreenView = [[UIView alloc] initWithFrame:self.view.window.frame];
    
    UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:fullScreenView.frame];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.alpha = 0.7;
    
    [fullScreenView addSubview:toolbar];
    [[UIApplication sharedApplication].keyWindow addSubview:fullScreenView];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.75, SCREEN_WIDTH)];
    webView.layer.cornerRadius = 5;
    webView.layer.masksToBounds = YES;
    webView.backgroundColor = [UIColor whiteColor];
    webView.center = self.view.center;
    [webView loadHTMLString:model.remark baseURL:nil];
    [fullScreenView addSubview:webView];
    
    UITapGestureRecognizer *tapGestureRecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGestureRecoginzer.delegate = self;
    [fullScreenView addGestureRecognizer:tapGestureRecoginzer];

    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 60;
    }else{
        
        return SCREEN_WIDTH*0.432;
    }
}


// tableView footer 添加去空白cell
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return nil;
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*0.82)];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setFrame:CGRectMake(0, 0, 93, 108)];
    
    imageView.center = CGPointMake(SCREEN_WIDTH/2.0, view.frame.size.height/2.0-50);
    
    imageView.image = [UIImage imageNamed:@"gouwudai_empty"];
    
    [view addSubview:imageView];
    
    UITapGestureRecognizer *tapGestureRecoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleKeyBoardTap:)];
    tapGestureRecoginzer.delegate = self;
    [self.tableView addGestureRecognizer:tapGestureRecoginzer];
    

    return view;
    
//    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0 && section == 0) {
        return SCREEN_HEIGHT*0.5;
    } else {
        return 0;
    }
//    return 0.1;
}

//空时的UIImageView
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*0.82)];
//    
//    UIImageView *imageView = [[UIImageView alloc] init];
//    [imageView setFrame:CGRectMake(0, 0, 93, 108)];
//    
//    imageView.center = CGPointMake(SCREEN_WIDTH/2.0, view.frame.size.height/2.0);
//    
//    imageView.image = [UIImage imageNamed:@"gouwudai_empty"];
//    
//    [view addSubview:imageView];
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.01;
}


#pragma mark -使用规则button点击事件
- (void)useRuleButtonClicked:(UIButton *)sender {
    

    [[UIApplication sharedApplication].keyWindow endEditing:YES];

    CouponModel *model = self.dataArr[sender.tag];
    
    UIView *fullScreenView = [[UIView alloc] initWithFrame:self.view.window.frame];
    
    UIToolbar * toolbar = [[UIToolbar alloc] initWithFrame:fullScreenView.frame];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    toolbar.alpha = 0.7;
    
    [fullScreenView addSubview:toolbar];
    [[UIApplication sharedApplication].keyWindow addSubview:fullScreenView];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*0.75, SCREEN_WIDTH)];
    webView.layer.cornerRadius = 5;
    webView.layer.masksToBounds = YES;
    webView.backgroundColor = [UIColor whiteColor];
    webView.center = self.view.center;
    [webView loadHTMLString:model.remark baseURL:nil];
    [fullScreenView addSubview:webView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [fullScreenView addGestureRecognizer:tapGesture];
}

- (void)handleKeyBoardTap:(UITapGestureRecognizer *)recognizer {
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

#pragma mark -使用规则button tap事件
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    
    [recognizer.view removeFromSuperview];
}


#pragma mark -topButton点击事件,用作键盘收回
- (void)topButtonClicked {
    
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:1000];
    
    [codeTextField resignFirstResponder];
}


#pragma mark -点击兑换
- (void)duihuan{
   
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/member/couponCode/check_coupon.jhtml";
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
    CouponCodeTableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (![cell.textField hasText]) {
        [HTUIHelper addHUDToView:self.view withString:@"请输入兑换码" hideDelay:2];
        return;
    }
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    UITextField *codeTextField = (UITextField *)[self.view viewWithTag:1000];
    NSString *code = codeTextField.text;
    [requestInfo.getParams addEntriesFromDictionary:@{@"code":code}];
    
    [HTUIHelper addHUDToWindowWithString:@"加载中..."];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
                
            NSNumber *state = [responseObject objectForKey:@"state"];
            //请求成功，后续模型赋值操作
            if (state.intValue == 0) {
                    
//                    //兑换后的优惠券
//                    NSDictionary *data = [responseObject objectForKey:@"data"];
//                    
//                    [weakSelf.dataArr removeAllObjects];
//                    
//                    NSMutableArray *arrayModels = [NSMutableArray array];
//                    CouponModel *model = [[CouponModel alloc] initWithDictionary:data error:nil];
//                    [arrayModels addObject:model];
//                
//                    weakSelf.dataArr = [arrayModels mutableCopy];
//                    [weakSelf.tableView reloadData];
                    
                [weakSelf.tableView.mj_header beginRefreshing];
                codeTextField.text = @"";
                [HTUIHelper removeHUDToWindowWithEndString:@"兑换成功" image:nil delyTime:1];
                    
            }else if (state.intValue == 1){
                
                [HTUIHelper removeHUDToWindowWithEndString:[responseObject objectForKey:@"msg"] image:nil delyTime:1];
            }
                
        }
        
        else {
            [HTUIHelper removeHUDToWindowWithEndString:[responseObject objectForKey:@"msg"] image:nil delyTime:1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper removeHUDToWindowWithEndString:[error localizedDescription] image:nil delyTime:1];
        
    }];
    
    
}



@end
