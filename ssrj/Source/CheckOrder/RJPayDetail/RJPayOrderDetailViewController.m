
#import "RJPayOrderDetailViewController.h"
#import "RJPaySuccessViewController.h"
#import "RJPayFailureViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "RJAliPayManager.h"
#import "RJWXPayManager.h"
#import "GoodsDetailViewController.h"
#import "ServerAfterSaleViewController.h"
#import "myOrderCellModel.h"
#import "LocalDefine.h"
#import "EMIMHelper.h"
#import "ChatViewController.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "RJPayProcessViewController.h"

@interface RJPayOrderDetailViewController ()<UITableViewDataSource,UITableViewDelegate,RJWXApiManagerDelegate,RJAliApiManagerDelegate,ServerAfterSaleViewControllerDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UILabel *goodsTotalPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *activityLabel;
@property (weak, nonatomic) IBOutlet UILabel *usedCouponLabel;
//可用积分抵扣
@property (weak, nonatomic) IBOutlet UILabel *exchagePointLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyForSendLabel;
@property (strong, nonatomic) IBOutlet UILabel *allCountLabel;
@property (strong, nonatomic) RJPayOrderDetailModel * model;
/**
 *  支付编号
 */
@property (strong, nonatomic) NSNumber * paymentSn;

@end
@implementation RJPayOrderDetailViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"订单详情页面"];
    [TalkingData trackPageBegin:@"订单详情页面"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"订单详情页面"];
    [TalkingData trackPageEnd:@"订单详情页面"];
    
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    [self addBackButton];
    [self setTitle:@"订单详情" tappable:NO];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
    [_tableView setSeparatorInset:UIEdgeInsetsZero];
    
    self.dataArray = [NSMutableArray array];
    self.tableView.tableFooterView.hidden = YES;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
}


- (void)getNetData {
    
//    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中" xOffset:0 yOffset:0];
//    self.tableView.hidden = YES;
    ZHRequestInfo *requestInfo  = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/member/order/view.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"id":self.orderId}];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSDictionary *dic = responseObject[@"data"];
                RJPayOrderDetailModel *model = [[RJPayOrderDetailModel alloc]initWithDictionary:dic error:nil];
                if (model) {
                    weakSelf.model = model;
                    [weakSelf.dataArray removeAllObjects];
                    weakSelf.dataArray = [NSMutableArray arrayWithArray:[weakSelf.model.orderItemList copy]];
//                    weakSelf.tableView.hidden = NO;
                    
                    weakSelf.goodsTotalPriceLabel.text = [NSString stringWithFormat:@"¥%d",model.price.intValue];
                    weakSelf.usedCouponLabel.text = [NSString stringWithFormat:@"-¥%d", model.couponDiscount.intValue];
                    weakSelf.activityLabel.text = [NSString stringWithFormat:@"-¥%d", model.promotionDiscount.intValue];
                    
                    weakSelf.moneyForSendLabel.text = [NSString stringWithFormat:@"¥%d",model.freight.intValue];
                    weakSelf.exchagePointLabel.text = [NSString stringWithFormat:@"-¥%d",model.exchangePointAmount.intValue];
                    
                    weakSelf.allCountLabel.text = [NSString stringWithFormat:@"￥%d",model.amount.intValue];
                    self.tableView.tableFooterView.hidden = NO;

                    [weakSelf.tableView reloadData];

//                    [[HTUIHelper shareInstance]removeHUD];
                }else{
                    [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];

            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [self.tableView.mj_header endRefreshing];

    }];
    
}

#pragma mark --申请售后代理方法
- (void)reloadPayOrderDetailData {
    //刷新订单详情UI
    [self getNetData];
    
    //去刷新订单UI
    if ([self.delegate respondsToSelector:@selector(reloadOrderStateData)]) {
        
        [self.delegate reloadOrderStateData];
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.model) {
        return 2;
    }
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 4;
    }
    return self.dataArray.count;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectZero];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return [[UIView alloc]initWithFrame:CGRectZero];
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    view.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 0.5)];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    [view addSubview:lineLabel];
    return view;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0.1;
    }
    return 20;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if (section == 0) {
        return 0.1;
    }
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                RJPayOrderDetailAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailAddressCell"];
                RJAddressModel *model = self.model.address;
                cell.nameLabel.text = model.consignee;
                cell.phoneLabel.text = model.phone;
                cell.addressLabel.text = model.fullName;
                return cell;
            }
                
                break;
            case 1:{
                RJPayOrderDetailOrderIdCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailOrderIdCell"];
                cell.orderIdLabel.text = self.model.sn;
                return cell;
            }
                
                break;
            case 2:{
                RJPayOrderDetailOrderDateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailOrderDateCell"];
                cell.orderDateLabel.text = self.model.orderTime;
                return cell;
            }
            case 3:{
                if ([self.model.status isEqualToString:@"pendingPayment"]) {
                    if (self.model.hasExpired.boolValue == 0) {
                        
                        RJPayOrderDetailPayFailureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailPayFailureCell"];
                    
                        [cell.payButton addTarget:self action:@selector(payAgain) forControlEvents:UIControlEventTouchUpInside];
                        return cell;
                    }else{
                        RJPayOrderDetailOrderDateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailOrderDateCell"];
                        cell.orderDateLabel.text = @"已过期";
                        return cell;
                    }
                }
                RJPayOrderDetailPaySuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailPaySuccessCell"];
                if ([self.model.status isEqualToString:@"shipped"]) {
                    cell.orderStatusLabel.text = @"已发货";//原待收货
                }
                if ([self.model.status isEqualToString:@"received"]) {
                    cell.orderStatusLabel.text = @"已完成";
                }
                if ([self.model.status isEqualToString:@"paymentProcessing"]) {
                    cell.orderStatusLabel.text = @"订单支付处理中";
                }
                
                // 已付款
                if ([self.model.status isEqualToString:@"pendingReview"] || [self.model.status isEqualToString:@"pendingShipment"]) {
                    cell.orderStatusLabel.text = @"已付款";
                }
                // 已失败
                if ([self.model.status isEqualToString:@"failed"]) {
                    cell.orderStatusLabel.text = @"已失败";
                }
                // 已取消
                if ([self.model.status isEqualToString:@"canceled"]) {
                    cell.orderStatusLabel.text = @"已取消";
                }
                // 已拒绝
                if ([self.model.status isEqualToString:@"denied"]) {
                    cell.orderStatusLabel.text = @"已拒绝";
                }
                
                //新增订单状态
                 //add 11.30 v2.2.0新增状态
                 if ([self.model.status isEqualToString:@"refundsed"]) {
                 cell.orderStatusLabel.text = @"已退款";
                 }
                 if ([self.model.status isEqualToString:@"returnsed"]) {
                 cell.orderStatusLabel.text = @"已退换货";
                 }
                 if ([self.model.status isEqualToString:@"refundsing"]) {
                 cell.orderStatusLabel.text = @"退款中";
                 }
                 if ([self.model.status isEqualToString:@"returnsing"]) {
                 cell.orderStatusLabel.text = @"退换货中";
                 
                 }
                 
                 if ([self.model.status isEqualToString:@"cancelPendingReview"]) {
                 cell.orderStatusLabel.text = @"等待审核";
                 
                 }
                 //新增未出现过的字段，在返回数据中出现    add 11.30
                 if ([self.model.status isEqualToString:@"returnsReview"]) {
                 
                 cell.orderStatusLabel.text = @"退换货审核";
                 }
                
                
                return cell;
                
            }
                //                if ([self.model.status isEqualToString:@"pendingReview"]) {
                //                    RJPayOrderDetailPaySuccessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailPaySuccessCell"];
                //                    return cell;
                //                }
                //                RJPayOrderDetailPayFailureCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailPayFailureCell"];
                //                [cell.payButton addTarget:self action:@selector(payAgain) forControlEvents:UIControlEventTouchUpInside];
                //                return cell;
                //                }
                
                break;
            default:
                break;
        }
    }
    if (indexPath.section == 1) {
        RJPayOrderDetailGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJPayOrderDetailGoodCell"];
        PayOrderDeatailItemModel *model = self.dataArray[indexPath.row];//RJPayOrderDetailModel
        cell.model = model;
        
        //一下根据订单状态判断申请退换货按钮是否显示出来
        //已完成
        if (([self.model.status isEqualToString:@"received"]||[self.model.status isEqualToString:@"returnsing"]||[self.model.status isEqualToString:@"returnsReview"]) && model.canApply){
            
            cell.shouHouButton.hidden = NO;
        }
        else {
            
            cell.shouHouButton.hidden = YES;
        }
        
        cell.shouHouButton.tag = indexPath.row;
        [cell.shouHouButton addTarget:self action:@selector(askForReturnGoodsWithSender:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    return nil;
}

#pragma mark --售后申请事件
- (void)askForReturnGoodsWithSender:(UIButton *)sender{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    ServerAfterSaleViewController *serverVC = [story instantiateViewControllerWithIdentifier:@"ServerAfterSaleViewController"];
    serverVC.serverDelegate = self;
    PayOrderDeatailItemModel *model = self.dataArray[sender.tag];
    
    serverVC.orderSn = self.model.sn;
    serverVC.productid = model.product.productid;
    serverVC.toReturnQuantity = model.quantity;//model.quantity变自model.returnedQuantity;
    serverVC.addressModel = self.model.address;
    serverVC.orderItemId = model.id;
    
    [self.navigationController pushViewController:serverVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return 80;
                break;
            case 1:
                return 44;
                break;
            case 2:
                return 44;
                break;
            case 3:
                if ([self.model.status isEqualToString:@"pendingPayment"] && self.model.hasExpired.boolValue == 0) {
                    return 60;
                }
                return 44;
                break;
                
            default:
                break;
        }
    }
    if (indexPath.section == 1) {
        PayOrderDeatailItemModel *model = self.dataArray[indexPath.row];//RJPayOrderDetailModel
        CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJPayOrderDetailGoodCell" configuration:^(RJPayOrderDetailGoodCell * cell) {
            cell.preSaleDescLabel.text = model.preSaleDesc;
        }];
        return hei;

    }
    return 105;
}

#pragma mark -- 点击在线客服按钮
- (IBAction)serversOnLineButtonAction:(id)sender {
    
    [[EMIMHelper defaultHelper] loginEasemobSDK];
    NSString *cname = @"mfd2016ssrj";
    ChatViewController *chatVC = [[ChatViewController alloc] initWithChatter:cname type:eSaleTypeNone];
    if (self.model) {
        
        NSArray *items = self.model.orderItemList;
        if (items.count) {
            PayOrderDeatailItemModel *itemModel = [items firstObject];
            NSString *colseName =[NSString stringWithFormat:@"%@ 共%lu件商品",itemModel.name,(unsigned long)items.count]; ;
            NSString *price = [NSString stringWithFormat:@"¥%@",self.model.amount.stringValue];
            chatVC.commodityInfo = @{@"type":@"order", @"title":self.model.statusStr?:@"", @"order_title":[NSString stringWithFormat:@"订单号:%@",self.model.sn?:@"无"], @"imageName":@"mallImage1.png", @"desc":colseName, @"price":price, @"img_url":itemModel.product.image, @"item_url":@""};
        }
        
        
    }
    
    chatVC.title = @"时尚客服";
    [self.navigationController pushViewController:chatVC animated:YES];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        
        PayOrderDeatailItemModel *model = self.dataArray[indexPath.row];
        NSNumber *goodId = model.product.goodsId;
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
        NSNumber *goodId2 = goodId;
        goodsDetaiVC.goodsId = goodId2;
        
        [self.navigationController pushViewController:goodsDetaiVC animated:YES];
        
    }
}
- (void)payAgain{
    if ([self.model.paymentType isEqualToString:@"wxpayPubPaymentPlugin"]) {
        //微信支付
        [self weiCatPayWithOrderNumber:self.model.sn];
    }else if([self.model.paymentType isEqualToString:@"alipayDirectPaymentPlugin"]){
        //支付宝支付
        [self AliPayWithOrderNumber:self.model.sn];
    }
}



#pragma mark - 后台返回签名参数 调起支付宝支付
- (void)AliPayWithOrderNumber:(NSString *)number{
    
    [RJAliPayManager shareInstance].delegate = nil;
    [RJAliPayManager shareInstance].delegate = self;
    
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"请求支付中" xOffset:0 yOffset:0];
    ZHRequestInfo *requestInfo =[ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/payment.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"type":@"payment",
                                                                            @"paymentPluginId":@"alipayDirectPaymentPlugin",
                                                                            @"sn":number,
                                                                            @"amount":self.model.amount}];
    
    
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
- (void)weiCatPayWithOrderNumber:(NSString *)number{
    
    [RJWXPayManager sharedManager].delegate = nil;
    [RJWXPayManager sharedManager].delegate = self;
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"请求支付中" xOffset:0 yOffset:0];
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
//    if (resultStatus.intValue == 9000&& [result rangeOfString:@"&success=\"true\"" options:NSCaseInsensitiveSearch].length>0 ) {
//        //        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"支付完成" xOffset:0 yOffset:0];
//        [self checkOrderResult];
//    }else{
//        
//        [self showPayFailureViewWithOrderId:self.orderId];
//    }
    [self checkOrderResultWithResultCode:resultStatus];

}
#pragma mark - RJWXApiManagerDelegate
- (void)managerDidRecvPayResponse:(PayResp *)response{
    NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
    switch (response.errCode) {
        case WXSuccess:
            strMsg = @"支付结果：成功！";
            break;
        default:
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", response.errCode,response.errStr];
            break;
    }
    [self checkOrderResultWithResultCode:@(response.errCode)];
    
}
#pragma mark - 回调后台 检测是否支付成功
- (void)checkOrderResultWithResultCode:(NSNumber *)code{
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"正在验证是否支付成功" xOffset:0 yOffset:0];
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
        [viewControllers replaceObjectAtIndex:i-1 withObject:detailVc];
        [self.navigationController setViewControllers:viewControllers];
    }];
}
- (void)showPaySuccessViewWithOrderId:(NSNumber *)orderId{
    RJPaySuccessViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPaySuccessViewController"];
    [self presentViewController:vc animated:YES completion:^{
        NSMutableArray *viewControllers =[NSMutableArray arrayWithArray:[self.navigationController.viewControllers copy]];
        NSUInteger i = viewControllers.count;
        RJPayOrderDetailViewController *detailVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
        detailVc.orderId = orderId;
        [viewControllers replaceObjectAtIndex:i-1 withObject:detailVc];
        [self.navigationController setViewControllers:viewControllers];
    }];
}

- (void)showPayFailureViewWithOrderId:(NSNumber *)orderId{
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

@end

@implementation RJPayOrderDetailOrderIdCell



@end

#pragma OrderDate
@implementation RJPayOrderDetailOrderDateCell


@end

@implementation RJPayOrderDetailAddressCell



@end


@implementation RJPayOrderDetailPaySuccessCell



@end


@implementation RJPayOrderDetailPayFailureCell

-(void)awakeFromNib {
    
    self.payButton.layer.cornerRadius = 12.5;
    self.payButton.layer.masksToBounds = YES;
    
    [super awakeFromNib];
}

@end

@implementation RJPayOrderDetailGoodCell


- (void)awakeFromNib{
    self.shouHouButton.layer.cornerRadius = 3.0;
    self.shouHouButton.layer.borderWidth = 1;
    self.shouHouButton.layer.borderColor = [UIColor colorWithHexString:@"#898989"].CGColor;
    [self.shouHouButton setTitleColor:[UIColor colorWithHexString:@"#898989"] forState:0];
    self.colorImageView.layer.cornerRadius = self.colorImageView.width/2;
    self.colorImageView.clipsToBounds = YES;
    self.goodImageView.layer.borderWidth = 1;
    self.goodImageView.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
    if (DEVICE_IS_IPHONE4 ||DEVICE_IS_IPHONE5) {
        self.textViewLeftWithImageViewConstrant.constant = 10;
    }
    if (DEVICE_IS_IPHONE6) {
        self.textViewLeftWithImageViewConstrant.constant = 20;
    }
    if (DEVICE_IS_IPHONE6Plus) {
        self.textViewLeftWithImageViewConstrant.constant = 25;
    }
    [super awakeFromNib];
}
- (void)setModel:(PayOrderDeatailItemModel *)model{
//    if (_model != model) {
    _model = model;
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail] placeholderImage:GetImage(@"default_1x1")];
    [self.colorImageView sd_setImageWithURL:[NSURL URLWithString:model.product.colorPicture] placeholderImage:nil];
    self.nameLabel.text = model.product.name;
    self.brandNameLabel.text = model.product.brandName;
    self.sizeNameLabel.text = model.product.specification;
    self.countNumberLabel.text = [NSString stringWithFormat:@"x%d",model.quantity.intValue];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"￥%d",model.product.effectivePrice.intValue];
    self.markPriceLabel.attributedText = [NSString effectivePriceWithString:[NSString stringWithFormat:@"%d",model.product.marketPrice.intValue]];
    self.preSaleDescLabel.text = model.preSaleDesc;
//    }
}
@end
