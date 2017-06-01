//
//  OverdueHongBaoTableViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "OverdueHongBaoTableViewController.h"
#import "CouponCellTableViewCell.h"
#import "CouponModel.h"


static NSString *cellID = @"couponCell";

@interface OverdueHongBaoTableViewController ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) CouponModel *couponModel;

@property (strong, nonatomic) NSMutableArray *dataArr;

@end

@implementation OverdueHongBaoTableViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"已过期的红包"];
    [TalkingData trackPageBegin:@"已过期的红包"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"已过期的红包"];
    [TalkingData trackPageEnd:@"已过期的红包"];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArr = [NSMutableArray array];
 
    __weak typeof(&*self)weakSelf = self;
    self.tableView.tableHeaderView = nil;
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
        
    }];
   
    [self.tableView registerNib:[UINib nibWithNibName:@"CouponCellTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    
    [weakSelf.tableView.mj_header beginRefreshing];

}

- (void)getData {
    
    __weak typeof(&*self)weakSelf = self;
    
    //取用户ID
    NSNumber *userID = [[RJAccountManager sharedInstance] account].id;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //取token
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"/b82/api/v2/user/findcoupon?userId=%@",userID];

    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        if ([responseObject objectForKey:@"state"]) {
                
                NSNumber *state = [responseObject objectForKey:@"state"];
                //请求成功，后续模型赋值操作
                if (state.intValue == 0) {
                    
                //已用优惠券
                    NSDictionary *data = [responseObject objectForKey:@"data"];
                    
                    NSArray *expireCouponArr = [data objectForKey:@"expireCoupon"];
                    
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
                    
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
                }else if(state.intValue == 2){
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

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return SCREEN_WIDTH*0.432;
   
}

// tableView footer 添加去空白cell
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CouponCellTableViewCell *couponCell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    CouponModel *model = self.dataArr[indexPath.row];
    
    couponCell.couponImageView.image = [UIImage imageNamed:@"Coupon_Unable"];
    couponCell.couponStateImageView.image = [UIImage imageNamed:@"overdue_icon"];

    couponCell.moneyLabel.text = [model.price stringValue];
    couponCell.moneyLabel.textColor = [UIColor lightGrayColor];
    couponCell.deadLineLabel.text = model.memo;
    
    [couponCell.useRuleButton setHidden:YES];
    [couponCell.useRuleButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [couponCell.useRuleButton addTarget:self action:@selector(overDueUseRuleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [couponCell.topButton addTarget:self action:@selector(topButtonClickded) forControlEvents:UIControlEventTouchUpInside];
    

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

    
//    if (model.beginDate.length>0 && model.endDate.length>0) {
//        couponCell.deadLineLabel.text = [NSString stringWithFormat:@"有效期：%@至%@", model.beginDate, model.endDate];
//    }
//    
//    if (model.beginDate.length==0 && model.endDate.length>0) {
//        couponCell.deadLineLabel.text = [NSString stringWithFormat:@"有效期至%@",model.endDate];
//    }
//    
//    if (model.endDate.length==0) {
//        couponCell.deadLineLabel.text = @"已过有效期";
//    }
//    if (model.useRule.length == 0) {
//        model.useRule = @"已过有效期，不可使用";
//    }

    couponCell.howToUseLabel.text = model.useRule;
    

    return couponCell;

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


#pragma mark -使用规则button点击事件
- (void)overDueUseRuleButtonClicked:(UIButton *)sender {
    
    
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
#pragma mark -使用规则button tap事件
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    
    [recognizer.view removeFromSuperview];
}



//空时的UIImageView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*0.82)];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setFrame:CGRectMake(0, 0, 93, 108)];
    
    imageView.center = CGPointMake(SCREEN_WIDTH/2.0, view.frame.size.height/2.0);
    
    imageView.image = [UIImage imageNamed:@"gouwudai_empty"];
    
    [view addSubview:imageView];
    return view;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0) {
        
        return SCREEN_HEIGHT*0.82;
    } else {
        
        return 0;
    }
}

- (void)topButtonClickded {
    
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

@end
