
#import "EnableCouponViewController.h"
#import "RJCouPonModel.h"
#import "NSAttributedString+YYText.h"

@interface EnableCouponViewController ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (strong, nonatomic) RJCouPonModel * selectModel;

@property (weak, nonatomic) IBOutlet UIView *tableHeaderView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@end

@implementation EnableCouponViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"结算时候可用现金券页面"];
    [TalkingData trackPageBegin:@"结算时候可用现金券页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"结算时候可用现金券页面"];
    [TalkingData trackPageEnd:@"结算时候可用现金券页面"];

}

- (void)viewDidLoad{
    [super viewDidLoad];
    __weak __typeof(&*self)weakSelf = self;
    self.dataArray = [NSMutableArray array];

    self.tableView.tableFooterView = self.emptyView;
    
    
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
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/couponCode/listValid.jhtml"];
    
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
                    weakSelf.tableView.tableFooterView = self.emptyView;
                    [weakSelf.tableView.mj_header endRefreshing];
                    return ;
                }else{
                    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
                }
                
                for (NSDictionary *dic in arr) {
                    NSError __autoreleasing *e = nil;

                    RJCouPonModel *model = [[RJCouPonModel alloc]initWithDictionary:dic error:&e];
                    
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
                
            }else if(number.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
//            else if(number.intValue == 2){
//                if ([RJAccountManager sharedInstance].token) {
//                    [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                }
//            }
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
    EnableCouponTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EnableCouponTableViewCell" forIndexPath:indexPath];
    RJCouPonModel *model =  self.dataArray[indexPath.row];
    cell.moneyLabel.text = [NSString stringWithFormat:@"%d",model.price.intValue];
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",model.expire]];

    text.yy_font = [UIFont systemFontOfSize:11];
    text.yy_color = [UIColor colorWithHexString:@"#b1b1b1"];
    text.yy_alignment =  NSTextAlignmentCenter;
    
    if (model.remark.length) {
        text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@(%@)",model.minimumPriceMsg,model.remark]];
        text.yy_font = [UIFont systemFontOfSize:11];
        text.yy_color = [UIColor colorWithHexString:@"#b1b1b1"];
        text.yy_alignment =  NSTextAlignmentCenter;
        [text yy_setColor:[UIColor colorWithHexString:@"#fba5a5"] range:NSMakeRange(model.minimumPriceMsg.length, model.remark.length+2)];
    }
    cell.dateLabel.text = model.minimumPriceMsg; //minimumPriceMsg
    cell.iconImage.highlighted  = NO;
    cell.descriptionLabel.attributedText = text;
    if (self.selectId.intValue == model.id.intValue) {
        cell.iconImage.highlighted = YES;
    }
    
    cell.useRuleButton.tag = indexPath.row;
    [cell.useRuleButton addTarget:self action:@selector(useRuleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if (model.introduction.length) {
        
        cell.useRuleButton.hidden = NO;
    
    } else {
        
        cell.useRuleButton.hidden = YES;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RJCouPonModel *model = self.dataArray[indexPath.row];
    if (self.selectId.intValue == model.id.intValue) {
        self.selectId = [NSNumber numberWithInt:-1];
        self.selectModel = nil;
    }else{
        self.selectId = model.id;
        self.selectModel = model;

    }
    
    if ([_textField isFirstResponder]) {
        
        [_textField resignFirstResponder];
    }
    
    [self.delegate choseCouponWithModel:self.selectModel];
    
    [self.tableView reloadData];
}

- (IBAction)submitButtonAction:(id)sender {
    if (!self.textField.text.length) {
        [HTUIHelper addHUDToView:self.view withString:@"请输入优惠码" hideDelay:1.5];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/member/couponCode/check_coupon.jhtml";
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    NSString *code = self.textField.text;
    [requestInfo.getParams addEntriesFromDictionary:@{@"code":code}];
    
    [HTUIHelper addHUDToWindowWithString:@"加载中..."];
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
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
                    weakSelf.textField.text = @"";
                    [HTUIHelper removeHUDToWindowWithEndString:@"兑换成功" image:nil delyTime:1];
                    [weakSelf.tableView.mj_header beginRefreshing];
                    
                }else{
                    [HTUIHelper removeHUDToWindowWithEndString:[responseObject objectForKey:@"msg"] image:nil delyTime:1];
                }
                
            } else {
                [HTUIHelper removeHUDToWindowWithEndString:[responseObject objectForKey:@"msg"] image:nil delyTime:1];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper removeHUDToWindowWithEndString:@"兑换失败" image:nil delyTime:1];
        
    }];

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


@implementation EnableCouponTableViewCell

-(void)awakeFromNib{
    [super awakeFromNib];
    if (DEVICE_IS_IPHONE6) {
        self.imageLeftConstriant.constant = 35;
        self.desLabelYConstriant.constant = 43;

    }
    if (DEVICE_IS_IPHONE6Plus) {
        self.imageLeftConstriant.constant = 45;
        self.desLabelYConstriant.constant = 48;
    }
    
}

@end
