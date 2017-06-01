//
//  MFDAllOrdersViewController.m
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDAllOrdersViewController.h"
#import "MFDMineOrdersTableViewCell.h"
#import "myOrderCellModel.h"

#import "WuliuWebViewController.h"
#import "ServerAfterSaleViewController.h"
#import "RJPayOrderDetailViewController.h"
#import "ServerAfterSaleViewController.h"


@interface MFDAllOrdersViewController()<UITableViewDelegate,UITableViewDataSource, UIActionSheetDelegate, RJPayOrderDetailViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *allOrderTableView;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (nonatomic,assign)int pageNumber;

@property (strong,nonatomic) NSNumber *tempOrderID;
//用以保存物流 web url
@property (strong, nonatomic) NSString *wuliuUrlString;


//记录用户取消订单的原因（from actionSheet） add 11.18
@property (strong, nonatomic) NSString *cancelApplyReasonString;
////用于取消订单时判断订单是已支付还是待付款   add 11.18
//@property (assign, nonatomic) BOOL isOrderPayed;

@end


@implementation MFDAllOrdersViewController

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"全部订单页面"];
    [TalkingData trackPageBegin:@"全部订单页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"全部订单页面"];
    [TalkingData trackPageEnd:@"全部订单页面"];

}


- (void)viewDidLoad{
    [super viewDidLoad];
    __weak __typeof(&*self)weakSelf = self;
    
    self.pageNumber = 1;
    self.allOrderTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];

    [self.allOrderTableView.mj_header beginRefreshing];
}


#pragma mark -- 订单详情代理刷新
-(void)reloadOrderStateData {
    
    [self getNetData];
}


- (void)getNetData {
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    _pageNumber = 1;


    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%d&status=&timeString=%@",self.pageNumber,timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    requestInfo.modelClass = [MFDMineOrderModel class];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

            if ([responseObject objectForKey:@"state"]) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    
                    NSArray *arr = [responseObject objectForKey:@"data"];

                    if (arr.count) {
                        //添加上拉刷新底部加载更多
                        weakSelf.allOrderTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                            [weakSelf getNextPageData];
                        }];
                    }
                    _pageNumber += 1;
                    [weakSelf.dataArray removeAllObjects];
                    
                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                }else if(state.intValue == 1){
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                    
                }
//                else if(state.intValue == 2){
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
//                }

                [weakSelf.allOrderTableView reloadData];
            }else{
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }

        [weakSelf.allOrderTableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.allOrderTableView.mj_header endRefreshing];
        
    }];
    
}

- (void)getNextPageData{
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];

    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%d&status=&timeString=%@",self.pageNumber,timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    //    requestInfo.modelClass = [MFDMineOrderModel class];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject objectForKey:@"state"]) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    
                    NSArray *arr = [responseObject objectForKey:@"data"];
                    
                    if (!arr.count) {
                        
                        [weakSelf.allOrderTableView.mj_footer endRefreshingWithNoMoreData];
                        return ;
                    }
                    self.pageNumber += 1;

                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                }else if (state.intValue == 1) {
                    
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];

                }
//                else if (state.intValue == 2) {
//                    
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
//                }

                [weakSelf.allOrderTableView reloadData];
            }
        
        else{
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
     
     [weakSelf.allOrderTableView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.allOrderTableView.mj_footer endRefreshing];
        
    }];
    
}


#pragma mark --取消待付款订单buttonAction
- (void)AllCancelUnpayedOrderWithSender:(UIButton *)sender{
    
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"取消订单" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我不想买了",@"拍错尺码了",@"收货信息写错了",@"其他原因", nil];
    
    menu.delegate = self;
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
    menu.tag = sender.tag;
}

#pragma mark --去付款buttonAction
- (void)AllGoToPayWithSender:(UIButton *)sender{
    //调用已有
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RJPayOrderDetailViewController *orderDetailVC = [sb instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
    
    myOrderCellModel *model = self.dataArray[sender.tag];
    orderDetailVC.orderId = model.myOrderCellModelId;
    [self.navigationController pushViewController:orderDetailVC animated:YES];
    
}

#pragma mark --确认收货buttonAction
- (void)AllGetGoodsWithSender:(UIButton *)sender{
    
    myOrderCellModel *model = self.dataArray[sender.tag];
    NSString *orderSn = model.sn;
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/receive.jhtml?orderSn=%@", orderSn];
    [self sendOrderRequestWithURL:urlStr];
}


//#pragma mark --点击申请售后button方法   未用
//- (void)AllApplyServerWithSender:(UIButton *)sender {
//    
//    [HTUIHelper addHUDToView:self.view withString:@"点击申请售后了" hideDelay:2];
//    
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    RJPayOrderDetailViewController *orderDetailVC = [sb instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
//    myOrderCellModel *model = self.dataArray[sender.tag];
//    orderDetailVC.orderId = model.myOrderCellModelId;
//    self.tempOrderID = model.myOrderCellModelId;
//    
//    [self.navigationController pushViewController:orderDetailVC animated:YES];
//    
//}

#pragma mark --取消已支付订单buttonAction
- (void)AllCancelPayedOrderWithSender:(UIButton *)sender{
    
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"取消订单" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我不想买了",@"拍错尺码了",@"收货信息写错了",@"其他原因", nil];
    
    menu.delegate = self;
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
    menu.tag = sender.tag;
}

#pragma mark --查看物流
- (void)AllCheckWhereIsTheGoodsWithSender:(UIButton *)sender {
    
    myOrderCellModel *model = self.dataArray[sender.tag];
    
    //网络请求获取订单物流信息
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/logistics.jhtml?&shippingSn=%@&timeString=%@", model.shippingSn, timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    //    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                NSDictionary *dataDic = [responseObject objectForKey:@"data"];
                
                _wuliuUrlString = [dataDic objectForKey:@"url"];
                
                
                //顺丰快递
                //圆通快递
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                
                WuliuWebViewController *wuliuWebVC = [story instantiateViewControllerWithIdentifier:@"WuliuWebViewController"];
                wuliuWebVC.wuliuUrlString = _wuliuUrlString;
                
                [weakSelf.navigationController pushViewController:wuliuWebVC animated:YES];
                
                [self.allOrderTableView.mj_header beginRefreshing];
                
            }
            else {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        }
        else{
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:2];

    }];
    
}




-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.dataArray.count == 0) {
        return SCREEN_HEIGHT*0.82;
    } else {
        return 0;
    }
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




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RJPayOrderDetailViewController *orderDetailVC = [sb instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
    myOrderCellModel *model = self.dataArray[indexPath.row];
    orderDetailVC.orderId = model.myOrderCellModelId;
    orderDetailVC.delegate = self;
    self.tempOrderID = model.myOrderCellModelId;
    
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 8+ 33+ 1+ (SCREEN_WIDTH-2*8-5*3)/4+16 +34 +38 +4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MFDMineOrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AllOrdersTableViewCell" forIndexPath:indexPath];
    
    cell.btnRight.tag = indexPath.row;
    cell.btnLeft.tag = indexPath.row;
    
    myOrderCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    //待付款
    if ([model.status isEqualToString:@"pendingPayment"]) {
        
        if (model.hasExpired.intValue == 0 && ![model.type isEqualToString:@"swap"]) {
            
            [cell.btnLeft setTitle:@"取消订单" forState:UIControlStateNormal];
            [cell.btnRight setTitle:@"去付款" forState:UIControlStateNormal];
            
            #pragma mark --button Action
            //取消订单
            [cell.btnLeft addTarget:self action:@selector(AllCancelUnpayedOrderWithSender:) forControlEvents:UIControlEventTouchUpInside];
            //去付款
            [cell.btnRight addTarget:self action:@selector(AllGoToPayWithSender:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    //pendingShipment
    //已发货  －－（原待收货）
    else if ([model.status isEqualToString:@"shipped"]) {
        
        [cell.btnLeft setTitle:@"确认收货" forState:UIControlStateNormal];
        [cell.btnRight setTitle:@"查看物流" forState:UIControlStateNormal];
        //确认收货
        [cell.btnLeft addTarget:self action:@selector(AllGetGoodsWithSender:) forControlEvents:UIControlEventTouchUpInside];
        //查看物流
        [cell.btnRight addTarget:self action:@selector(AllCheckWhereIsTheGoodsWithSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // 已付款 (等待发货--后台)  pendingReview等待审核  pendingShipment等待发货
    else if (([model.status isEqualToString:@"pendingReview"] || [model.status isEqualToString:@"pendingShipment"]) && ![model.type isEqualToString:@"swap"]) {

        [cell.btnRight setTitle:@"取消订单" forState:UIControlStateNormal];
        //取消订单
        [cell.btnRight addTarget:self action:@selector(AllCancelPayedOrderWithSender:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    //撤回申请
    else if ([model.status isEqualToString:@"cancelPendingReview"]) {
        
        [cell.btnRight setTitle:@"撤回申请" forState:UIControlStateNormal];
        [cell.btnRight addTarget:self action:@selector(undoApplyWithSender:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    // v3.1.0
    //已完成
    else if ([model.status isEqualToString:@"received"] || [model.status isEqualToString:@"completed"]) {
        
        [cell.btnRight setTitle:@"查看物流" forState:UIControlStateNormal];
        //查看物流
        [cell.btnRight addTarget:self action:@selector(AllCheckWhereIsTheGoodsWithSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    else {
        
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        [cell.btnLeft removeTarget:nil action:nil forControlEvents:UIControlEventTouchUpInside];
    }
    
//    if (cell != nil) {
//        [cell removeFromSuperview];
//    }
    
    
    return cell;
}

#pragma mark --撤销申请售后button点击事件防范
- (void)undoApplyWithSender:(UIButton *)sender {
        
    myOrderCellModel *model = self.dataArray[sender.tag];
    
    //撤回订单取消申请接口：
    //https://api.ssrj.com/api/v4/member/order/cancel/apply/refund.jhtml?token=xxx&orderSn=订单编号   POST请求
    
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin])  {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }

    [requestInfo.postParams addEntriesFromDictionary:@{@"orderSn":model.sn}];

    NSString *urlStr = @"/api/v5/member/order/cancel/apply/refund.jhtml";
    
    requestInfo.URLString = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //[HTUIHelper addHUDToView:self.view withString:@"正在取消中..." xOffset:0 yOffset:50];
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
                [weakSelf getNetData];
                
                //取消及确认收货操作完成后刷新tableView
                [weakSelf.allOrderTableView reloadData];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
            [[HTUIHelper shareInstance] removeHUD];
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
        //        [[HTUIHelper shareInstance] removeHUD];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //        [[HTUIHelper shareInstance] removeHUD];
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];

    
    
}





#pragma mark --取消订单原因选择
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    _cancelApplyReasonString = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (buttonIndex == 4) {
        
        return;
    }
    
    myOrderCellModel *model = self.dataArray[actionSheet.tag];
    NSString *orderSn = model.sn;
    
    NSString *urlStr = @"";
    
    //待付款
    if ([model.status isEqualToString:@"pendingPayment"]) {
        
        if (model.hasExpired.intValue == 0 && ![model.type isEqualToString:@"swap"]) {
            
            urlStr = @"/api/v5/member/order/cancel.jhtml";
        }
        
    }
    //已付款
    else if (([model.status isEqualToString:@"pendingReview"] || [model.status isEqualToString:@"pendingShipment"]) && ![model.type isEqualToString:@"swap"]) {
        
        urlStr = @"/api/v5/member/order/apply/refund.jhtml";
    }
    
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin])  {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    requestInfo.URLString = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"orderSn":orderSn,@"reason":_cancelApplyReasonString}];
    
//    [HTUIHelper addHUDToView:self.view withString:@"正在取消中..." xOffset:0 yOffset:50];
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
                [weakSelf getNetData];
                
                //取消及确认收货操作完成后刷新tableView
                [weakSelf.allOrderTableView reloadData];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
            [[HTUIHelper shareInstance] removeHUD];
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
//        [[HTUIHelper shareInstance] removeHUD];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
//        [[HTUIHelper shareInstance] removeHUD];
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];
    
}

#pragma mark --确认收货网络请求
-(void)sendOrderRequestWithURL:(NSString *)urlString{
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@&timeString=%@", urlString, timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
                
                NSNumber *state = [responseObject objectForKey:@"state"];
                if ([state intValue] == 0) {
                    [HTUIHelper addHUDToView:self.view withString:@"操作成功" hideDelay:2];
                    
                    [weakSelf getNetData];

                    //取消及确认收货操作完成后刷新tableView
                    [weakSelf.allOrderTableView reloadData];
                    
                } else if(state.intValue == 1){
                    [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
                }
//                else if(state.intValue == 2){
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
//                }
            
        }
            
        else {
            [HTUIHelper addHUDToView:self.view withString:@"操作失败" hideDelay:2];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
    }];
}





@end
