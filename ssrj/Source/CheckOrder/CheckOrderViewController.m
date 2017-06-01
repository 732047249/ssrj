
#import "CheckOrderViewController.h"
#import "CheckOrderGoodsCell.h"
#import "AddressListViewController.h"
#import "WXApi.h"
#import "RJWXPayManager.h"
#import "RJPaySuccessViewController.h"
#import "RJPayFailureViewController.h"
#import "RJPayOrderDetailViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "RJAliPayManager.h"
//#import "DataSigner.h"
#import "ChoseCouponViewController.h"
#import "RJCouPonModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "RJPayProcessViewController.h"
typedef NS_ENUM(NSInteger ,PayType){
    RJWeiCat = 1,
    RJAliPay,
};
typedef NS_ENUM(NSInteger ,PaySectionName){
    RJPayProduceSection = 0,
    RJPayHongBaoSection,
    RJPayKuiDiSection,
    RJPayJiFenSection,
    RJPayYuErSection,
    RJPaySanFangSection
};
@interface CheckOrderViewController ()<UITableViewDataSource,UITableViewDelegate,AddressListDelegate,RJWXApiManagerDelegate,RJAliApiManagerDelegate,ChoseCouponDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet AddressView *addressView;
@property (weak, nonatomic) IBOutlet UILabel *addAddressLabel;

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UILabel *totalPriceLabel;

@property (assign, nonatomic) PayType  chosePay;
@property (strong, nonatomic) NSMutableArray * productArrray;
/**
 *  选择的Address
 */
@property (strong, nonatomic) RJAddressModel * selectAddressModel;
/**
 *  选择余额的话剩余需要支付的金额 选择积分也要改变这个值
 */
@property (assign, nonatomic)NSInteger  remainderPrice;

@property (strong, nonatomic) NSArray * shippingMethodArray;
/**
 *  选择的快递方式
 */
@property (strong, nonatomic) NSNumber * shippMethodSelectId;
/**
 *  创建的订单编号
 */
@property (strong, nonatomic) NSNumber * orderNumber;
/**
 *  支付编号
 */
@property (strong, nonatomic) NSNumber * paymentSn;
/**
 *  去订单详情的订单号
 */
@property (strong, nonatomic) NSNumber * orderId;
//是否选择余额支付
@property (assign, nonatomic) BOOL isChoseBalance;

@property (strong, nonatomic) RJCouPonModel * selectCouPon;
//显示在下方的需要支付的总价
@property (strong, nonatomic) NSNumber * shouldPayCount;
/**
 *  纯无门槛优惠券支付
 */
@property (assign, nonatomic) BOOL isAllCodePay;
/**
 *  纯积分支付   把积分抵现理解为另类的账户余额
 */
@property (nonatomic, assign) BOOL isAllJiFenPay;
/**
 *  纯余额支付
 */
@property (nonatomic, assign) BOOL isAllBalancePay;
/**
 *  余额支付和余额支付都选了
 */
@property (nonatomic, assign) BOOL balanceAndJiFenPay;

//当账户余额和积分抵现加一起大于订单金额 也就是使用积分+余额支付 需要记录各自金额
@property (nonatomic,assign) NSInteger payBalaceCount;
@property (nonatomic,assign) NSInteger payJiFenCount;

/**
 *  是否勾选了积分抵现
 */
@property (nonatomic, assign) BOOL isChooseJiFen;
/**
 *  支付方式的顺序由后台控制  可以随时隐藏某一个支付方式
 */
@property (nonatomic,strong) NSMutableArray * paymentPluginArray;

@end

@implementation CheckOrderViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"支付订单"];
    [TalkingData trackPageBegin:@"支付订单"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"支付订单"];
    [TalkingData trackPageEnd:@"支付订单"];

}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
//    /**
//     *  Debug
//     */
//#warning !!!!!!!!!!!!!!!!!!!!debug!!!!!!!!!!!!!!!!
//    self.model.balance = [NSNumber numberWithInt:2];
//    self.model.exchangePointAmount = [NSNumber numberWithInt:1];

//    self.chosePay = RJAliPay;
    [self setTitle:@"支付订单" tappable:NO];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.payButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addressViewTapGestureAction:)];
    [self.headerView addGestureRecognizer:tapGesture];
    
    
    self.productArrray = [NSMutableArray arrayWithArray:[self.model.itemList copy]];
    self.selectAddressModel = self.model.address;
    /**
     *  3.1.0 新增
     */
    self.selectCouPon = self.model.couponCode;
    /**
     *  3.1.0 三方支付顺序由后台返回 那个出问题也可以隐藏
     */
    self.paymentPluginArray = [NSMutableArray arrayWithArray:[self.model.paymentPluginData mutableCopy]];
 
//    self.paymentPluginArray = [NSMutableArray arrayWithArray:[[self.paymentPluginArray reverseObjectEnumerator]allObjects]];
    
    if (self.paymentPluginArray.count) {
        RJPayMethodModel *tempModel = self.paymentPluginArray[0];
        if ([tempModel.paymentPluginValue isEqualToString:@"alipayDirectPaymentPlugin"]) {
            self.chosePay = RJAliPay;
        }else if ([tempModel.paymentPluginValue isEqualToString:@"wxpayPubPaymentPlugin"]){
            self.chosePay = RJWeiCat;
        }
    }
    
    [self upDateAddressViewWithModel:self.selectAddressModel];
    
    [self.tableView reloadData];
    
  
    self.remainderPrice = self.model.amount.integerValue;
    self.shouldPayCount = self.model.amount;
    self.totalPriceLabel.text = [NSString stringWithFormat:@"¥%d",self.shouldPayCount.intValue];

    self.shippingMethodArray = [NSArray arrayWithArray:[self.model.shippingMethodData copy]];
    
    for (RJKuaiDiModel * model in self.shippingMethodArray) {
        if (model.isAvailable.boolValue) {
            self.shippMethodSelectId = model.id;
            break;
        }
    }
    //防止后台没有这个字段
    if (!self.model.exchangePointAmount) {
        self.model.exchangePointAmount = @0;
    }
    [self upLoadViewWithAllSelectStatus];
}
- (void)upDateAddressViewWithModel:(RJAddressModel *)model{
    if (!model) {
        self.addressView.hidden = YES;
        self.addAddressLabel.hidden = NO;
        return;
    }
    self.addressView.hidden = NO;
    self.addAddressLabel.hidden = YES;

    self.addressView.nameLabel.text = model.consignee;
    self.addressView.phoneLabel.text = model.phone;
    self.addressView.addressLabel.text = model.fullName;

}
#pragma mark -
#pragma mark ======更新整个订单状态的逻辑在这里==========
- (void)upLoadViewWithAllSelectStatus{
    self.remainderPrice = self.model.amount.integerValue;
    self.shouldPayCount = self.model.amount;
    self.totalPriceLabel.text = [NSString stringWithFormat:@"¥%d",self.shouldPayCount.intValue];
    self.isAllCodePay = NO;
    self.isAllJiFenPay = NO;
    self.isAllBalancePay = NO;
    self.payBalaceCount = 0;
    self.payJiFenCount = 0;
    self.balanceAndJiFenPay = NO;
    /**
     *  为0只有一种情况 使用无门槛优惠券
     */
    if (self.remainderPrice == 0) {
        self.isAllCodePay = YES;
    }
    /**
     *  判断账户余额什么的
     */
    self.totalPriceLabel.text = [NSString stringWithFormat:@"¥%d",self.shouldPayCount.intValue];
    
    NSInteger price = 0;
    //积分优先级最高
    if (self.isChooseJiFen) {
        
        price = (self.shouldPayCount.intValue - self.model.exchangePointAmount.intValue)<=0 ?0:(self.shouldPayCount.integerValue - self.model.exchangePointAmount.integerValue);
        //纯积分支付咯 把账户余额选择关掉
        if (price == 0) {
            self.isAllJiFenPay = YES;
            self.payJiFenCount = self.shouldPayCount.integerValue;
            //不管账户余额选择没 都关掉
            self.isChoseBalance = NO;
        }else{
            //选了积分抵现 也选了账户余额支付
            if (self.isChoseBalance) {
                NSInteger normalPrice = price;
                price = (price - self.model.balance.integerValue) <=0 ?0:(price - self.model.balance.integerValue);
                self.balanceAndJiFenPay = YES;
                self.payJiFenCount = self.model.exchangePointAmount.integerValue;
                //积分加余额联合纯支付
                if (price == 0) {
                    self.payBalaceCount = normalPrice;
                }else{
                    self.payBalaceCount = self.model.balance.integerValue;
                }
            }else{
                //noting
                
            }
        }
    }else{
        //没选积分 选择了账户余额支付
        if (self.isChoseBalance) {
            price = (self.shouldPayCount.integerValue - self.model.balance.integerValue)<=0 ? 0:(self.shouldPayCount.integerValue - self.model.balance.integerValue);
            if (price == 0) {
                self.isAllBalancePay = YES;
                self.payBalaceCount = self.shouldPayCount.integerValue;
            }

        }else{
            price = self.shouldPayCount.integerValue;
        }
    }
    self.remainderPrice = price;

//    if (self.isChoseBalance) {
//        price = (self.shouldPayCount.integerValue - self.model.balance.integerValue)<=0 ? 0:(self.shouldPayCount.integerValue - self.model.balance.integerValue);
//        
//    }else{
//        
//        price = self.shouldPayCount.integerValue;
//    }
//    
//    self.remainderPrice = price;

    [self.tableView reloadData];
}
#pragma mark - AddressListDelegate
- (void)choseAddressWithModel:(RJAddressModel *)model{
    /**
     *  每次选完地址和后台进行交互 判断是否是香港地址  运费
     */
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"api/v5/member/order/settlement.jhtml";
    [requestInfo.getParams addEntriesFromDictionary:@{@"ids":self.model.cartItemIds}];
        if (self.selectCouPon) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
        }
        if (model) {
            [requestInfo.getParams addEntriesFromDictionary:@{@"receiverId":model.id}];
        }

    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state.boolValue == 0) {
            NSDictionary *dic = responseObject[@"data"];
            NSNumber *amount = dic[@"amount"];
            NSNumber *freight = dic[@"freight"];
            NSNumber *isHongKong = dic[@"isHongkong"];
            NSString *freightDesc = dic[@"freightDesc"];
            
            NSArray *shippingMethodData = dic[@"shippingMethodData"];
            NSMutableArray *kuaiDiArr = [NSMutableArray array];
            if ([shippingMethodData count]) {
                for (NSDictionary * itemDic in shippingMethodData) {
                    RJKuaiDiModel *kuaiDiModel = [[RJKuaiDiModel alloc]initWithDictionary:itemDic error:nil];
                    if (kuaiDiModel) {
                        [kuaiDiArr addObject:kuaiDiModel];
                    }
                }
                if ([kuaiDiArr count]) {
                    self.shippingMethodArray = [NSArray arrayWithArray:[kuaiDiArr copy]];
                    for (RJKuaiDiModel * model in self.shippingMethodArray) {
                        if (model.isAvailable.boolValue) {
                            self.shippMethodSelectId = model.id;
                            break;
                        }
                    }
                }
            }
            if (amount) {
                self.model.amount = amount;
                self.model.freight = freight;
                self.model.isHongkong = isHongKong;
                self.model.freightDesc = freightDesc;
                self.selectAddressModel = model;
                [self upDateAddressViewWithModel:self.selectAddressModel];
                
                [self upLoadViewWithAllSelectStatus];
                
                [[HTUIHelper shareInstance]removeHUD];
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil];
            }
            
            
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error);

        [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil];
        
    }];


    
}
- (void)addressViewTapGestureAction:(UITapGestureRecognizer *)sender{
    
    [self performSegueWithIdentifier:@"addressSegue" sender:self.selectAddressModel];
}
#pragma mark - UITableViewDelegate && UITabelViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   //显示的单品
    if (section == RJPayProduceSection) {
        return self.productArrray.count;
    }
    //使用现金券什么的
    if (section ==RJPayHongBaoSection) {
        return 3;
    }
    //快递种类
    if (section == RJPayKuiDiSection) {
        return self.shippingMethodArray.count +1;
    }
    //3.3.0 新增积分抵现
    if (section == RJPayJiFenSection) {
        if (self.isAllCodePay) {
            return 0;
        }
        return 1;
    }
    //账户余额
    if (section ==RJPayYuErSection) {
        if (self.isAllCodePay) {
            return 0;
        }
        return 1;
    }
    //第三方支付
    if (section ==RJPaySanFangSection) {
        if (self.remainderPrice == 0) {
            return 0;
        }
        if (self.isAllCodePay) {
            return 0;
        }
        return 1 + self.paymentPluginArray.count;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (section == RJPayProduceSection || section == RJPaySanFangSection ||(section == RJPayYuErSection && self.remainderPrice == 0)|| (section == RJPayJiFenSection && self.remainderPrice == 0)) {
        return [[UIView alloc]initWithFrame:CGRectZero];
    }
    
    static NSString *identifer = @"headerView";
    
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifer];
    if (!headerView) {
        headerView = [[UITableViewHeaderFooterView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
        headerView.contentView.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, 1/[UIScreen mainScreen].scale)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"#dcdcdc"];
        [headerView addSubview:lineLabel];
    }
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 0 || section ==RJPaySanFangSection) {
        return 0.1;
    }
    if (section == RJPayYuErSection && self.remainderPrice == 0 ) {
        return 0.1;
    }
    return 15;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //商品
    if (indexPath.section == RJPayProduceSection) {
        CheckOrderGoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodCell" forIndexPath:indexPath];
        CartItemModel *model = self.productArrray[indexPath.row];
        cell.model = model;
        return cell;
    }
    //使用红包啥的
    if (indexPath.section == RJPayHongBaoSection) {
        if (indexPath.row == 0) {
            CheckOrderHBTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderHBTableViewCell"];
            if (self.selectCouPon) {
                cell.subPriceLabel.hidden = NO;
                cell.subPriceLabel.text = [NSString stringWithFormat:@"已减免:¥%d",self.selectCouPon.price.intValue];
            }else{
           
                cell.subPriceLabel.hidden = YES;

            }
            return cell;
        }
        /**
         *  运费显示 主要针对香港地址 收取邮费
         */
        if (indexPath.row == 1) {
            CheckOrderYouFeiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderYouFeiCell"];
            cell.ruleDescriptionLabel.hidden = NO;
            cell.ruleDescriptionLabel.text = self.model.freightDesc;
            cell.priceLabel.text = [NSString stringWithFormat:@"¥%d",self.model.freight.intValue];
            return cell;
        }
        if (indexPath.row == 2) {
            CheckOrderTotalPriceCell
            *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderTotalPriceCell"];
            cell.totalPriceLabel.text = [NSString stringWithFormat:@"¥%d",self.shouldPayCount.intValue];
            return cell;
        }
 
    }
    //快递种类
    if (indexPath.section == RJPayKuiDiSection) {
    
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"kuaidiCell"];
            return cell;
        }
        
        CheckOrderKuaiDiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderKuaiDiCell"];
        cell.choseIamge.highlighted  = NO;
        cell.nameLabel.textColor = [UIColor blackColor];
        RJKuaiDiModel *model = self.shippingMethodArray[indexPath.row-1];
        cell.nameLabel.text = model.name;
        if (!model.isAvailable.boolValue) {
            cell.nameLabel.textColor = [UIColor grayColor];
        }
        if (model.id.intValue == self.shippMethodSelectId.intValue) {
            cell.choseIamge.highlighted = YES;
        }
        return cell;
    }
    //积分抵现
    if (indexPath.section == RJPayJiFenSection) {
        CheckOrderJiFenCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderJiFenCell"];
        cell.jiFenLabel.text =  [NSString stringWithFormat:@"¥%@",self.model.exchangePointAmount.stringValue];
        cell.choseImage.highlighted = self.isChooseJiFen;
        return cell;
    }
    //账户余额
    if (indexPath.section == RJPayYuErSection) {
        CheckOrderBalanceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderBalanceCell"];
        cell.blacePriceLabel.text = [NSString stringWithFormat:@"¥%d",self.model.balance.intValue];
        cell.totoalPriceLabel.text = [NSString stringWithFormat:@"¥%d",self.shouldPayCount.intValue];
        cell.choseImage.highlighted = NO;
        
        if (self.isChoseBalance) {
            cell.choseImage.highlighted = YES;
        }
        
        return cell;
    }
    if (indexPath.section == RJPaySanFangSection) {
        if (indexPath.row == 0) {
            CheckOrderPayTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderPayTitleCell"];
            cell.moneyLabel.text = [NSString stringWithFormat:@"¥%ld",(long)self.remainderPrice];
            return cell;
        }
        
        RJPayMethodModel *itemModel = self.paymentPluginArray[indexPath.row -1];
        CheckOrderPayCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CheckOrderPayCell"];
        cell.payTitleLabel.text = itemModel.paymentPluginName;
        cell.chooseImage.highlighted = NO;
        //支付宝
        if ([itemModel.paymentPluginValue  isEqualToString:@"alipayDirectPaymentPlugin"]) {
            cell.payImageView.image = GetImage(@"ali");
            if (self.chosePay == RJAliPay) {
                cell.chooseImage.highlighted = YES;
            }
        }
        //微信
        else if([itemModel.paymentPluginValue isEqualToString:@"wxpayPubPaymentPlugin"]){
            cell.payImageView.image = GetImage(@"wechat");
            if (self.chosePay == RJWeiCat) {
                cell.chooseImage.highlighted = YES;
            }
        }
        return cell;
    }
    return nil;
  
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == RJPayProduceSection) {
        CartItemModel *model = self.productArrray[indexPath.row];

        CGFloat hei =[tableView fd_heightForCellWithIdentifier:@"GoodCell" configuration:^(CheckOrderGoodsCell * cell) {
            cell.preSaleDescLabel.text = model.preSaleDesc;
            
        }];
        return hei;
    }
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    if (indexPath.section == RJPayHongBaoSection && indexPath.row == 0) {
        
        [self performSegueWithIdentifier:@"ToCouponSegue" sender:nil];
    }
    //快递选择
    if (indexPath.section == RJPayKuiDiSection) {
        if (indexPath.row != 0) {
            
            RJKuaiDiModel *model = self.shippingMethodArray[indexPath.row -1];
            if (!model.isAvailable.boolValue) {
                return;
            }
            self.shippMethodSelectId = model.id;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    }
    //是否选择积分抵现
    if (indexPath.section == RJPayJiFenSection) {
        if (self.model.exchangePointAmount.intValue == 0) {
            return;
        }
        self.isChooseJiFen = !self.isChooseJiFen;
        //所有逻辑都放这里处理
        [self upLoadViewWithAllSelectStatus];
//        [self.tableView reloadData];
    }
    //选择是否余额付款
    if (indexPath.section == RJPayYuErSection) {
        if (self.model.balance.intValue == 0) {
            return;
        }
        self.isChoseBalance = !self.isChoseBalance;
        //所有逻辑都放这里处理
        [self upLoadViewWithAllSelectStatus];
   
        
//        [self.tableView reloadData];
    }
    if (indexPath.section == RJPaySanFangSection) {
        if (indexPath.row == 0) {
            return;
        }
        RJPayMethodModel *itemModel = self.paymentPluginArray[indexPath.row -1];
        if ([itemModel.paymentPluginValue  isEqualToString:@"alipayDirectPaymentPlugin"]) {
            self.chosePay = RJAliPay;
        }else if([itemModel.paymentPluginValue  isEqualToString:@"wxpayPubPaymentPlugin"]){
            self.chosePay = RJWeiCat;
        }
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:5] withRowAnimation:UITableViewRowAnimationNone];
    }
}
#pragma mark - Segue跳转
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"addressSegue"]) {
            //已经有默认地址
        AddressListViewController *vc = segue.destinationViewController;
        vc.deleagte = self;
        vc.model = sender;

    }
    if ([segue.identifier isEqualToString:@"ToCouponSegue"]) {
        ChoseCouponViewController *vc = segue.destinationViewController;
        if (self.selectCouPon) {
            vc.choseId = self.selectCouPon.id;
        }else{
            vc.choseId = [NSNumber numberWithInt:-1];
        }
        vc.delegate = self;
    }
}
#pragma mark - 使用优惠券回调
- (void)updateOrderWithModel:(RJCouPonModel *)model{
    /**
     *  2.1.5 UpDate 优惠券选择后要和后台回调   逻辑放在后台来执行
     */
    self.isAllCodePay = NO;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"api/v5/member/order/settlement.jhtml";
    [requestInfo.getParams addEntriesFromDictionary:@{@"ids":self.model.cartItemIds}];
    if (model) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"code":model.code}];
    }
    if (self.selectAddressModel) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"receiverId":self.selectAddressModel.id}];
    }
    
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state.boolValue == 0) {
            NSDictionary *dic = responseObject[@"data"];
            NSNumber *amount = dic[@"amount"];
            NSNumber *freight = dic[@"freight"];
            NSNumber *isHongKong = dic[@"isHongkong"];
            NSString *freightDesc = dic[@"freightDesc"];
            
            NSArray *shippingMethodData = dic[@"shippingMethodData"];
            NSMutableArray *kuaiDiArr = [NSMutableArray array];
            self.selectCouPon = model;

            if ([shippingMethodData count]) {
                for (NSDictionary * itemDic in shippingMethodData) {
                    RJKuaiDiModel *kuaiDiModel = [[RJKuaiDiModel alloc]initWithDictionary:itemDic error:nil];
                    if (kuaiDiModel) {
                        [kuaiDiArr addObject:kuaiDiModel];
                    }
                }
                if ([kuaiDiArr count]) {
                    self.shippingMethodArray = [NSArray arrayWithArray:[kuaiDiArr copy]];
                    for (RJKuaiDiModel * model in self.shippingMethodArray) {
                        if (model.isAvailable.boolValue) {
                            self.shippMethodSelectId = model.id;
                            break;
                        }
                    }
                }
            }
            if (amount) {
                
                self.model.amount = amount;
                self.model.freight = freight;
                self.model.isHongkong = isHongKong;
                self.model.freightDesc = freightDesc;
                [self upLoadViewWithAllSelectStatus];
                [[HTUIHelper shareInstance]removeHUD];
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil];
            }
            
            
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error);
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil];
        
    }];

}
#pragma mark - 支付按钮事件
- (IBAction)payButtonAction:(id)sender {
//     //debug
//    [self showPayFailureViewWithOrderId:[NSNumber numberWithInt:3574]];
//    return;
    if (!self.selectAddressModel) {
        [HTUIHelper alertMessage:@"请填写收货地址"];
        return;
    }
    /**
     *  纯无门槛现金券支付
     */
    if (self.isAllCodePay) {
        [self payAllWithCoupon];
        return;
    }
    

    /**
     *  全部使用积分支付！
     */
    if (self.isAllJiFenPay) {
        [self submitOrderWithJiFen];
        return;
    }
    /**
     *  全部使用预存款
     */
    if (self.isAllBalancePay) {
        [self submitOrderWithBalance];
        return;
    }
    /**
     *  积分和余额联合付款
     */
    if (self.balanceAndJiFenPay) {
        [self submitOrderWithJiFenAndYuEr];
        return;
    }
    
    /**
     *  未安装微信 并且不是全部使用余额支付 弹出提示信息
     */
    if (![WXApi isWXAppInstalled]&&self.chosePay == RJWeiCat&&self.remainderPrice!=0) {
        [HTUIHelper alertMessage:@"未安装微信,请选择其他支付方式"];
        return;
    }

    
    /**
     *  积分和三方联合支付
     */
    if (self.isChooseJiFen && self.remainderPrice!= 0) {
        if (![WXApi isWXAppInstalled]&&self.chosePay == RJWeiCat) {
            [HTUIHelper alertMessage:@"未安装微信,请选择其他支付方式"];
            return;
        }
        [self payWithJiFenAndThirdPay];
        return;
    }
    /**
     *  使用余额和三方支付联合付款
     */
    if (self.isChoseBalance && self.remainderPrice!=0) {
        if (![WXApi isWXAppInstalled]&&self.chosePay == RJWeiCat) {
            [HTUIHelper alertMessage:@"未安装微信,请选择其他支付方式"];
            return;
        }
        
        [self payWithBlanceAndThirdPay];
        return;
        
        
    }
    /**
     *  全部使用微信支付或者支付宝支付
     */
    if (!self.isChoseBalance && !self.isChooseJiFen) {
        [self payAllAmountWithWeiCatOrAliPay];
        return;
    }

    
    //确定支付发送购物车数量变动通知
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
    
}
#pragma mark - 无门槛优惠券支付
- (void)payAllWithCoupon{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];
    requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{@"cartItemIds":self.model.cartItemIds,
                                                                            @"cartToken":self.model.cartToken,
                                                                            @"receiverId":self.selectAddressModel.id,
                                                                            @"shippingMethodId":self.shippMethodSelectId,
                                                                            }];
    if (self.selectCouPon) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
    }
    //新增平台信息参数
    [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
    requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                /**
                 *  纯余额支付的话 返回订单号就证明支付成功 失败的话订单不会创建
                 data:{"orderId:"xxx,"orderSn":xxxx}
                 */
                [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                NSDictionary *dic = responseObject[@"data"];
                weakSelf.orderNumber = dic[@"orderSn"];
                NSNumber *orderId = dic[@"orderId"];
                //                NSLog(@"余额支付，订单号:%@",weakSelf.orderNumber);
                [[HTUIHelper shareInstance]removeHUD];
                
                [weakSelf showPaySuccessViewWithOrderId:orderId];
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        
    }];

}
#pragma mark - 积分和三方支付合并付款
- (void)payWithJiFenAndThirdPay{
    
//    NSLog(@"积分和三方付款 积分付款%ld 三方支付%ld",(long)self.payJiFenCount,self.remainderPrice);
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];
    requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"cartItemIds":self.model.cartItemIds,
                                                                            @"cartToken":self.model.cartToken,
                                                                            @"receiverId":self.selectAddressModel.id,
                                                                            @"paymentMethodId":@"2",
                                                                            @"shippingMethodId":self.shippMethodSelectId,
                                                                            @"exchangePointAmount":self.model.exchangePointAmount
                                                                            }];
    if (self.selectCouPon) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
    }
    //新增平台信息参数
    [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
    requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                /**
                 *   data =     {
                 orderId = 3507;
                 orderSn = 2016062430808;
                 };
                 */
                NSDictionary *dic = responseObject[@"data"];
                [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                _orderNumber = dic[@"orderSn"];
                weakSelf.orderId = dic[@"orderId"];
                //                NSLog(@"%@",weakSelf.orderNumber);
                if (self.chosePay == RJWeiCat) {
                    [weakSelf weiCatPayWithOrderNumber:weakSelf.orderNumber];
                }else{
                    [weakSelf AliPayWithOrderNumber:weakSelf.orderNumber];
                }
            }else{
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        
    }];

}
#pragma mark - 余额和三方支付合并付款
- (void)payWithBlanceAndThirdPay{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];
    requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"cartItemIds":self.model.cartItemIds,
                                                                            @"cartToken":self.model.cartToken,
                                                                            @"receiverId":self.selectAddressModel.id,
                                                                            @"paymentMethodId":@"2",
                                                                            @"shippingMethodId":self.shippMethodSelectId,
                                                                            @"balance":self.model.balance
                                                                            }];
    if (self.selectCouPon) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
    }
    //新增平台信息参数
    [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
    requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
    
    __weak __typeof(&*self)weakSelf = self;

    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                /**
                 *   data =     {
                 orderId = 3507;
                 orderSn = 2016062430808;
                 };
                 */
                NSDictionary *dic = responseObject[@"data"];
                [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                _orderNumber = dic[@"orderSn"];
                weakSelf.orderId = dic[@"orderId"];
                //                NSLog(@"%@",weakSelf.orderNumber);
                if (self.chosePay == RJWeiCat) {
                    [weakSelf weiCatPayWithOrderNumber:weakSelf.orderNumber];
                }else{
                    [weakSelf AliPayWithOrderNumber:weakSelf.orderNumber];
                }
            }else{
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        
    }];
    

}
#pragma mark - 全部使用微信支付或者支付宝支付去创建订单号
- (void)payAllAmountWithWeiCatOrAliPay{

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];
    requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"cartItemIds":self.model.cartItemIds,
                                                                            @"cartToken":self.model.cartToken,
                                                                            @"receiverId":self.selectAddressModel.id,
                                                                            @"paymentMethodId":@"2",
                                                                            @"shippingMethodId":self.shippMethodSelectId,
                                                                            }];
    if (self.selectCouPon) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
    }
    //新增平台信息参数
    [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
    requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                /**
                 *   data =     {
                    orderId = 3507;
                    orderSn = 2016062430808;
                 };
                 */
                NSDictionary *dic = responseObject[@"data"];
                [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                _orderNumber = dic[@"orderSn"];
                weakSelf.orderId = dic[@"orderId"];
//                NSLog(@"%@",weakSelf.orderNumber);
                if (self.chosePay == RJWeiCat) {
                    [weakSelf weiCatPayWithOrderNumber:weakSelf.orderNumber];
                }else{
                    [weakSelf AliPayWithOrderNumber:weakSelf.orderNumber];
                }
            }else{
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
        
    }];
}
#pragma mark - 后台返回签名参数 调起支付宝支付
- (void)AliPayWithOrderNumber:(NSNumber *)number{
    
    [RJAliPayManager shareInstance].delegate = nil;
    [RJAliPayManager shareInstance].delegate = self;
    
    [[HTUIHelper shareInstance]editWithString:@"请求支付中..."];
    ZHRequestInfo *requestInfo =[ZHRequestInfo new];
    /**
     *  如果改为V5  下方支付宝回调                  
     order.notifyURL =  @"https://ssrj.com/api/v5/payment/notify.jhtml"
     */
    
    requestInfo.URLString = @"/api/v5/payment.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"type":@"payment",
                                                                            @"paymentPluginId":@"alipayDirectPaymentPlugin",
                                                                            @"sn":number}];
    
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                /**
                 *  {
                 data =     {
                 body = "mfd \U6d4b\U8bd5\U5546\U54c1test12";
                 "input_charset" = "utf-8";
                 "notify_url" = "http://www.ssrj.com/api/v2payment/nofity.jhtml";
                 "out_trade_no" = 2016062438483;
                 partner = 2088021342943578;
                 paymentSn = 2016062438483;
                 "payment_type" = 1;
                 "seller_id" = "mfd@mfdapparel.com";
                 service = "mobile.securitypay.pay";
                 sign = "KDYJ6QCngivH5JPSRiwta6Sis8s/kF9o0LryHfTkKv3chR203FzO9/FzvQ7fZpxL9lYIXhZZiwvBTp3lNolI8U81RUjybgN8j6BDHmPEXbM7w5WrVc/95wHQFvbt6g+b6rg23oinrlG/v5uD0mxMFZKlhgJbbpJs9ZPx2C2KeYc=";
                 subject = 2016062430810;
                 "total_fee" = 1;
                 };
                 msg = "\U8bf7\U6c42\U6210\U529f";
                 state = 0;
                 }
                 */
                NSDictionary *dic = responseObject[@"data"];
                
                NSString *out_trade_no = [dic objectForKey:@"out_trade_no"];
                NSString *subject = [dic objectForKey:@"subject"];
                NSString *body = dic[@"body"];
                NSString *totalFee = dic[@"total_fee"];
               //开始拼装支付Order
                
                Order *order = [[Order alloc]init];
                order.partner = @"2088021342943578";
                order.sellerID = @"mfd@mfdapparel.com";
                order.notifyURL =  @"https://ssrj.com/api/v5/payment/notify.jhtml"; //回调URL
                order.service = @"mobile.securitypay.pay";
                order.paymentType = @"1";
                order.inputCharset = @"utf-8";
                order.itBPay = @"120m";
                order.showURL = @"m.alipay.com";
                
//                order.outTradeNO = @"2016062438988"; //订单ID（由商家自行制定）
//                order.subject = @"test111111"; //商品标题
//                order.body = @"hahahahhaha"; //商品描述
//                order.totalFee = @"1.00"; //商品价格
                
                order.outTradeNO = out_trade_no; //订单ID（由商家自行制定）
                order.subject = subject; //商品标题
                order.body = body; //商品描述
                order.totalFee = totalFee; //商品价格
                
                _paymentSn = dic[@"paymentSn"];
                
                //应用标示符号
                NSString *appScheme = @"MFDSsrj";
                //将商品信息拼接成字符串
                NSString *orderSpec = [order description];
//                NSLog(@"orderSpec = %@",orderSpec);
                
                NSString *signedString = dic[@"sign"];
                
//                NSString *privateKey = @"xxx";
//                
//                //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
//                id<DataSigner> signer = CreateRSADataSigner(privateKey);
//                NSString *signedString = [signer signString:orderSpec];
                
                
                //将签名成功字符串格式化为订单字符串,请严格按照该格式
                
                NSString *orderString = nil;
                if (signedString != nil) {
                    orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                   orderSpec, signedString, @"RSA"];
                    
                    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//                        NSLog(@"reslut = %@",resultDic);
//                        NSLog(@"网页支付宝回调");
                        if ([RJAliPayManager shareInstance].delegate && [[RJAliPayManager shareInstance].delegate respondsToSelector:@selector(managerDidRecvAliPayResponse:)]) {
                            NSDictionary *dic = resultDic;
                            [[RJAliPayManager shareInstance].delegate managerDidRecvAliPayResponse:dic];
                        }
                    }];
                }
                [[HTUIHelper shareInstance]removeHUD];
                
            }else{
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        
    }];
    

}
#pragma mark - 后台返回签名参数 调起微信支付
- (void)weiCatPayWithOrderNumber:(NSNumber *)number{
    
    [RJWXPayManager sharedManager].delegate = nil;
    [RJWXPayManager sharedManager].delegate = self;
    
    [[HTUIHelper shareInstance]editWithString:@"请求支付中..."];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/payment/weixinPayment.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"sn":number}];
    /**
     data =     {
     appid = wx71d644fc50bc3765;
     noncestr = pze0NG46xD8DwGGAEhC72COyvZIAVkqX;
     package = "Sign=WXPay";
     partnerid = 1269025801;
     prepayid = wx201606221621204484adffed0521573847;
     sign = 6B7D88320DDC2156FC2FB7C3DF522CAC;
     timestamp = 2016161940;
     };
     msg = "\U8bf7\U6c42\U6210\U529f";
     state = 0;
     */

    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSDictionary *dict = responseObject[@"data"];
                if (![dict allKeys].count) {
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
                    return ;
                }
                 NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
                //调起微信支付
                PayReq* req             = [[PayReq alloc] init];
                req.partnerId           = [dict objectForKey:@"partnerid"];
                req.prepayId            = [dict objectForKey:@"prepayid"];
                req.nonceStr            = [dict objectForKey:@"noncestr"];
                req.timeStamp           = stamp.intValue;
                req.package             = [dict objectForKey:@"package"];
                req.sign                = [dict objectForKey:@"sign"];
                //paymentSn=支付订单号 用于校验是否支付成功
                _paymentSn = [dict objectForKey:@"paymentSn"];
                
                [WXApi sendReq:req];
                
                [[HTUIHelper shareInstance]removeHUD];
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];

    }];

}
#pragma mark - RJAliApiManagerDelegate
- (void)managerDidRecvAliPayResponse:(NSDictionary *)response{
    NSDictionary *dic = response;
    NSNumber *resultStatus = dic[@"resultStatus"];
//    NSString *result = dic[@"result"];
    [self checkOrderResultWithResultCode:resultStatus];

//    if (resultStatus.intValue == 9000&& [result rangeOfString:@"&success=\"true\"" options:NSCaseInsensitiveSearch].length>0 ) {
////        NSLog(@"success");
////        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"支付完成" xOffset:0 yOffset:0];
//        [self checkOrderResult];
//    }else{
//        [self checkOrderResult];
////        [self showPayFailureViewWithOrderId:self.orderId];
//    }
}
#pragma mark - RJWXApiManagerDelegate
- (void)managerDidRecvPayResponse:(PayResp *)response{
    NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
    switch (response.errCode) {
        case WXSuccess:
            strMsg = @"支付结果：成功！";
//            NSLog(@"支付成功－PaySuccess，retcode = %d", response.errCode);
            break;
        default:
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", response.errCode,response.errStr];
//            NSLog(@"错误，retcode = %d, retstr = %@", response.errCode,response.errStr);
            break;
    }
    [self checkOrderResultWithResultCode:@(response.errCode)];
   
}
#pragma mark - 回调后台 检测是否支付成功
- (void)checkOrderResultWithResultCode:(NSNumber *)code{
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"正在验证支付结果" xOffset:0 yOffset:0];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString =[NSString stringWithFormat:@"api/v5/payment/payment_result.jhtml?paymentSn=%@&trade_status_code=%d",self.paymentSn,code.intValue];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSDictionary *dic = responseObject[@"data"];
                NSString *paymentLogStatus = dic[@"paymentLogStatus"];
                NSNumber *orderId = dic[@"orderId"];
                //wait success failure
                [[HTUIHelper shareInstance]removeHUD];
                if ([paymentLogStatus isEqualToString:@"wait"]||[paymentLogStatus isEqualToString:@"failure"]) {
                    //支付失败
                    [self showPayFailureViewWithOrderId:orderId];
                }else if([paymentLogStatus isEqualToString:@"success"]){
                    //支付成功
                    [self showPaySuccessViewWithOrderId:orderId];
                }else if([paymentLogStatus isEqualToString:@"processing"]){
                    
                    [self showPayProcessViewWithOrderId:orderId];
                }
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:YES];
                });
            }
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error,请到我的订单中查看支付结果" image:nil];
            [self.navigationController popViewControllerAnimated:YES];
            
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error,请到我的订单中查看支付结果" image:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
#pragma mark - 显示支付成功或失败的提示界面
- (void)showPayProcessViewWithOrderId:(NSNumber *)orderId{
    [[RJAccountManager sharedInstance]reloadCartNumber];
    RJPayProcessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPayProcessViewController"];
    [self presentViewController:vc animated:YES completion:^{
        NSMutableArray *viewControllers =[NSMutableArray arrayWithArray:[self.navigationController.viewControllers copy]];
        NSUInteger i = viewControllers.count;
        RJPayOrderDetailViewController *detailVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
        detailVc.orderId = orderId;
        if (i>=1) {
            [viewControllers replaceObjectAtIndex:i-1 withObject:detailVc];
            [self.navigationController setViewControllers:viewControllers];
        }
       
    }];
}

- (void)showPaySuccessViewWithOrderId:(NSNumber *)orderId{
    /**
     *  请求最新购物车信息
     */
    [[RJAccountManager sharedInstance]reloadCartNumber];
    
    
    RJPaySuccessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPaySuccessViewController"];
    [self presentViewController:vc animated:YES completion:^{
        NSMutableArray *viewControllers =[NSMutableArray arrayWithArray:[self.navigationController.viewControllers copy]];
        NSUInteger i = viewControllers.count;
        RJPayOrderDetailViewController *detailVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
        detailVc.orderId = orderId;
        if (i>=1) {
            [viewControllers replaceObjectAtIndex:i-1 withObject:detailVc];
            [self.navigationController setViewControllers:viewControllers];
        }
    }];
}

- (void)showPayFailureViewWithOrderId:(NSNumber *)orderId{
    /**
     *  请求最新购物车信息
     */
    [[RJAccountManager sharedInstance]reloadCartNumber];
    
    RJPayFailureViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPayFailureViewController"];
    [self presentViewController:vc animated:YES completion:^{
        NSMutableArray *viewControllers =[NSMutableArray arrayWithArray:[self.navigationController.viewControllers copy]];
        NSUInteger i = viewControllers.count;
        RJPayOrderDetailViewController *detailVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
        detailVc.orderId = orderId;
        [viewControllers replaceObjectAtIndex:i-1 withObject:detailVc];
        [self.navigationController setViewControllers:viewControllers];
    }];
}
#pragma mark - 纯积分支付
- (void)submitOrderWithJiFen{
//    NSLog(@"纯积分支付 支付积分%ld",(long)self.payJiFenCount);
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];

    requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"cartItemIds":self.model.cartItemIds,
                                                                            @"cartToken":self.model.cartToken,
                                                                            @"receiverId":self.selectAddressModel.id,
                                                                            @"shippingMethodId":self.shippMethodSelectId,
                                                                            @"exchangePointAmount":self.shouldPayCount
                                                                            }];
    if (self.selectCouPon) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
    }
    //新增平台信息参数
    [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
    requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                /**
                 *  纯余额支付的话 返回订单号就证明支付成功 失败的话订单不会创建
                 data:{"orderId:"xxx,"orderSn":xxxx}
                 */
                [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                NSDictionary *dic = responseObject[@"data"];
                weakSelf.orderNumber = dic[@"orderSn"];
                NSNumber *orderId = dic[@"orderId"];
                //                NSLog(@"余额支付，订单号:%@",weakSelf.orderNumber);
                [[HTUIHelper shareInstance]removeHUD];
                
                [weakSelf showPaySuccessViewWithOrderId:orderId];
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        
    }];

}
#pragma mark - 积分+余额+三方支付合并付款
- (void)submitOrderWithJiFenAndYuEr{
    
//    NSLog(@"积分加余额支付 积分支付%ld 余额支付 %ld 三方支付%ld",(long)self.payJiFenCount,(long)self.payBalaceCount,(long)self.remainderPrice);
    /**
     *  纯积分加纯余额支付
     */
    if (self.remainderPrice == 0) {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];
        
        requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"cartItemIds":self.model.cartItemIds,
                                                                                @"cartToken":self.model.cartToken,
                                                                                @"receiverId":self.selectAddressModel.id,
                                                                                @"shippingMethodId":self.shippMethodSelectId,
                                                                                @"exchangePointAmount":@(self.payJiFenCount),
                                                                                @"balance":@(self.payBalaceCount)
                                                                                }];
        if (self.selectCouPon) {
            [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
        }
        //新增平台信息参数
        [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
        requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
        __weak __typeof(&*self)weakSelf = self;
        [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *number = [responseObject objectForKey:@"state"];
                if (number.boolValue == 0) {
                    /**
                     *  纯余额支付的话 返回订单号就证明支付成功 失败的话订单不会创建
                     data:{"orderId:"xxx,"orderSn":xxxx}
                     */
                    [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                    NSDictionary *dic = responseObject[@"data"];
                    weakSelf.orderNumber = dic[@"orderSn"];
                    NSNumber *orderId = dic[@"orderId"];
                    //                NSLog(@"余额支付，订单号:%@",weakSelf.orderNumber);
                    [[HTUIHelper shareInstance]removeHUD];
                    
                    [weakSelf showPaySuccessViewWithOrderId:orderId];
                    
                }else{
                    [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                }
            }else{
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            
        }];

    }
    /**
     *  纯积分 + 纯余额 + 第三方支付
     */
    else{
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];
        requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"cartItemIds":self.model.cartItemIds,
                                                                                @"cartToken":self.model.cartToken,
                                                                                @"receiverId":self.selectAddressModel.id,
                                                                                @"paymentMethodId":@"2",
                                                                                @"shippingMethodId":self.shippMethodSelectId,
                                                                                @"balance":self.model.balance,
                                                                                @"exchangePointAmount":self.model.exchangePointAmount
                                                                                }];
        if (self.selectCouPon) {
            [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
        }
        //新增平台信息参数
        [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
        requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
        
        __weak __typeof(&*self)weakSelf = self;
       
        [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *number = [responseObject objectForKey:@"state"];
                if (number.boolValue == 0) {
                    /**
                     *   data =     {
                     orderId = 3507;
                     orderSn = 2016062430808;
                     };
                     */
                    NSDictionary *dic = responseObject[@"data"];
                    [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                    _orderNumber = dic[@"orderSn"];
                    weakSelf.orderId = dic[@"orderId"];
                    //                NSLog(@"%@",weakSelf.orderNumber);
                    if (self.chosePay == RJWeiCat) {
                        [weakSelf weiCatPayWithOrderNumber:weakSelf.orderNumber];
                    }else{
                        [weakSelf AliPayWithOrderNumber:weakSelf.orderNumber];
                    }
                }else{
                    
                    [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                }
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            
        }];

    }
}

#pragma mark - 纯余额支付

- (void)submitOrderWithBalance{
//    NSLog(@"纯余额支付");
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"创建订单中..." xOffset:0 yOffset:0];
    requestInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"cartItemIds":self.model.cartItemIds,
                                                                            @"cartToken":self.model.cartToken,
                                                                            @"receiverId":self.selectAddressModel.id,
                                                                            @"shippingMethodId":self.shippMethodSelectId,
                                                                            @"balance":self.shouldPayCount
                                                                            }];
    if (self.selectCouPon) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"code":self.selectCouPon.code}];
    }
    //新增平台信息参数
    [requestInfo.postParams addEntriesFromDictionary:@{@"clientType":@"ios"}];
    /**
     *  3.1.0 包含预售商品 改为post请求
     */
    requestInfo.URLString = @"/api/v5/member/order/create_orders.jhtml";
    

    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                /**
                 *  纯余额支付的话 返回订单号就证明支付成功 失败的话订单不会创建
                 data:{"orderId:"xxx,"orderSn":xxxx}
                 */
                [[HTUIHelper shareInstance]editWithString:@"创建订单成功..."];
                NSDictionary *dic = responseObject[@"data"];
                weakSelf.orderNumber = dic[@"orderSn"];
                NSNumber *orderId = dic[@"orderId"];
//                NSLog(@"余额支付，订单号:%@",weakSelf.orderNumber);
                [[HTUIHelper shareInstance]removeHUD];
                
                [weakSelf showPaySuccessViewWithOrderId:orderId];
        
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
        
    }];
}
@end



@implementation AddressView

@end


@implementation CheckOrderHBTableViewCell


@end


@implementation CheckOrderTotalPriceCell

@end

@implementation CheckOrderKuaiDiCell



@end


@implementation CheckOrderBalanceCell


@end

@implementation CheckOrderPayTitleCell

@end

@implementation CheckOrderPayCell



@end



@implementation CheckOrderYouFeiCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.ruleDescriptionLabel.hidden = YES;
    self.priceLabel.text = @"¥0";
}

@end



@implementation CheckOrderJiFenCell
- (void)awakeFromNib{
    [super awakeFromNib];
}


@end
