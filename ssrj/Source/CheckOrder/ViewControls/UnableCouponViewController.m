
#import "UnableCouponViewController.h"
#import "RJCouPonModel.h"
#import "NSAttributedString+YYText.h"
@interface UnableCouponViewController ()<UITableViewDataSource,UITabBarDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@end

@implementation UnableCouponViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"结算时不可使用现金券页面"];
    [TalkingData trackPageBegin:@"结算时不可使用现金券页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"结算时不可使用现金券页面"];
    [TalkingData trackPageEnd:@"结算时不可使用现金券页面"];

}


- (void)viewDidLoad{
    [super viewDidLoad];
    __weak __typeof(&*self)weakSelf = self;
    self.dataArray = [NSMutableArray array];
    self.tableView.tableHeaderView = self.emptyView;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];

    [self.tableView.mj_header beginRefreshing];
    
}
- (void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    /**
     *  2.1.4 使用V5版本
     */
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/couponCode/listUnValid.jhtml"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.cartItemIds.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"cartItemIds":self.cartItemIds}];
    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.intValue == 0) {
                NSArray *arr = [responseObject[@"data"] copy];
                [weakSelf.dataArray removeAllObjects];
                if (!arr.count) {
                    //无可用
                    weakSelf.tableView.tableHeaderView = self.emptyView;
                    [weakSelf.tableView.mj_header endRefreshing];
                    return ;
                }
                for (NSDictionary *dic in arr) {
                    RJCouPonModel *model = [[RJCouPonModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                weakSelf.tableView.tableHeaderView = nil;
                [weakSelf.tableView reloadData];
                
            }else if(number.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }else if(number.intValue == 2){
//                if ([RJAccountManager sharedInstance].token) {
//                    [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                }
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat width = SCREEN_WIDTH - 40;
    CGFloat height = width *23 /55;
    return height +15;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UnableCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UnableCouponTableViewCell" forIndexPath:indexPath];
    
    RJCouPonModel *model =  self.dataArray[indexPath.row];
    cell.moneyLabel.text = [NSString stringWithFormat:@"%d",model.price.intValue];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.expire]];
    
    text.yy_font = [UIFont systemFontOfSize:11];
    text.yy_color = [UIColor colorWithHexString:@"#ababab"];
    text.yy_alignment =  NSTextAlignmentCenter;
    
    if (model.remark.length) {
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(%@)",model.minimumPriceMsg,model.remark]];
        text.yy_font = [UIFont systemFontOfSize:11];
        text.yy_color = [UIColor colorWithHexString:@"#ababab"];
        text.yy_alignment =  NSTextAlignmentCenter;
        [text yy_setColor:[UIColor colorWithHexString:@"#d2d2d2"] range:NSMakeRange(model.minimumPriceMsg.length, model.remark.length+2)];
    }
    cell.dateLabel.text = model.minimumPriceMsg;//minimumPriceMsg
    cell.descriptionLabel.attributedText = text;
    cell.useRuleButton.tag = indexPath.row;
    [cell.useRuleButton addTarget:self action:@selector(useRuleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (model.introduction.length) {
        
        cell.useRuleButton.hidden = NO;
        
    } else {
        
        cell.useRuleButton.hidden = YES;
    }

    return cell;

}


#pragma mark -使用规则button点击事件
- (void)useRuleButtonAction:(UIButton *)sender {
    
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    RJCouPonModel *model = self.dataArray[sender.tag];
    
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
    [webView loadHTMLString:model.introduction baseURL:nil];
    [fullScreenView addSubview:webView];
    
    
//    UIView *useRuleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH *0.75, SCREEN_WIDTH*0.75)];
//    useRuleView.center = self.view.center;
//    useRuleView.layer.cornerRadius = 5;
//    useRuleView.layer.masksToBounds = YES;
//    
//    useRuleView.backgroundColor = [UIColor whiteColor];
//    [fullScreenView addSubview:useRuleView];
//    
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH *0.75-20, 21)];
//    titleLabel.text = @"使用规则";
//    titleLabel.font = [UIFont systemFontOfSize:10];
//    [useRuleView addSubview:titleLabel];
//    
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 30, SCREEN_WIDTH*0.75-10, SCREEN_HEIGHT*0.7)];
//    textView.userInteractionEnabled = NO;
//    textView.text = model.remark;
//    textView.font = [UIFont systemFontOfSize:15];
//    [useRuleView addSubview:textView];

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.delegate = self;
    [fullScreenView addGestureRecognizer:tapGesture];
}
#pragma mark -使用规则button tap事件
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    
    [recognizer.view removeFromSuperview];
}



@end



@implementation UnableCouponTableViewCell
-(void)awakeFromNib{
    [super awakeFromNib];
    if (DEVICE_IS_IPHONE6) {
        self.desLabelYConstriant.constant = 43;
        
    }
    if (DEVICE_IS_IPHONE6Plus) {
        self.desLabelYConstriant.constant = 48;
    }
    
}


@end
