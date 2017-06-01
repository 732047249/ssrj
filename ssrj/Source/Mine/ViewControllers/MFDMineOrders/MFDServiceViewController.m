//
//  MFDServiceViewController.m
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDServiceViewController.h"
#import "MFDMineOrdersTableViewCell.h"
#import "RJPayOrderDetailViewController.h"
#import "WuliuWebViewController.h"
#import "MFDWriteLogisticsViewController.h"

#import "MFDAfterSalesOrderDetailViewController.h"
#import "MFDAfterSalesReturnGoodsViewController.h"


@interface MFDServiceViewController()<UITableViewDelegate,UITableViewDataSource,MFDWriteLogisticsViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *serviceTableVIew;

@property (strong, nonatomic)NSMutableArray *dataArray;

@property (nonatomic,assign)int pageNumber;

@end


@implementation MFDServiceViewController


- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的订单售后页面"];
    [TalkingData trackPageBegin:@"我的订单售后页面"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的订单售后页面"];
    [TalkingData trackPageEnd:@"我的订单售后页面"];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    __weak __typeof(&*self)weakSelf = self;
    self.pageNumber = 1;
    
    self.serviceTableVIew.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    
    [self.serviceTableVIew.mj_header beginRefreshing];
}

#pragma mark --填写物流信息代理方法
-(void)reloadServiceOrderData {
    
    [self getNetData];
}

- (void)getNetData {
    
    //www.ssrj.com/api/v5/member/customerService/list.jhtml?appVersion=2.2.0&token=da83e19a50a084522343d96746f0d889&pageNumber=1
    
    _pageNumber = 1;
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/customerService/list.jhtml?pageNumber=%d",_pageNumber];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                //售后订单列表数据
                NSArray *arr = [responseObject objectForKey:@"data"];
                
                if (arr.count) {
                
                    //添加上拉刷新底部加载更多
                    weakSelf.serviceTableVIew.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextPageData];
                    }];
                }
                
                [weakSelf.dataArray removeAllObjects];
                
                if (arr.count) {
                    
                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                    
                    [weakSelf.serviceTableVIew reloadData];
                }
            }
            else if(state.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                
            }else if(state.intValue == 2){

                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];

            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        [weakSelf.serviceTableVIew.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.serviceTableVIew.mj_header endRefreshing];
    }];
}


#pragma mark --底部上拉刷新数据
- (void)getNextPageData {

    __weak __typeof(&*self)weakSelf = self;

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/customerService/list.jhtml?pageNumber=%d",_pageNumber];

    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    requestInfo.URLString = urlStr;

    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];

    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    NSArray *arr = [responseObject objectForKey:@"data"];

                    if (!arr.count) {

                        [weakSelf.serviceTableVIew.mj_footer endRefreshingWithNoMoreData];
                    }

                    self.pageNumber += 1;

                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.serviceTableVIew reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            }

        } else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        }

        [weakSelf.serviceTableVIew.mj_footer endRefreshing];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.serviceTableVIew.mj_footer endRefreshing];
    }];
}

#pragma tableView
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 8+ 33+ 1+ (SCREEN_WIDTH-2*8-5*3)/4+16 +34 +38 +4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

#pragma mark -- cell for tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MFDMineOrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ServiceTableViewCell" forIndexPath:indexPath];
    
    myOrderCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    cell.btnLeft.tag = indexPath.row;
    cell.btnRight.tag = indexPath.row;
    
    if ([model.returnsStatusValue isEqualToString:@"0"] &&( [model.returnsTypeValue isEqualToString:@"2"] || [model.returnsTypeValue isEqualToString:@"0"])) {
        
        //cell.stateLabel.text = @"等待审核";
        cell.stateLabel.text = model.returnsStatus;
        //TODO:撤销申请& 查看订单
        
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:NO];
        
        cell.btnRight.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
        cell.btnRight.layer.borderWidth = 0.35;
        cell.btnRight.layer.cornerRadius = 3.0;
        cell.btnRight.layer.masksToBounds = YES;
        
        [cell.btnRight setTitle:@"撤销申请" forState:UIControlStateNormal];
        [cell.btnRight setTitle:@"撤销申请" forState:UIControlStateSelected];
        
        [cell.btnRight addTarget:self action:@selector(serverUndoApplyWithSender:) forControlEvents:UIControlEventTouchUpInside];
        
        //        v2.2.0版需要加上查看订单功能
        //        [cell.btnRight setTitle:@"查看订单" forState:UIControlStateNormal];
        //        [cell.btnRight setTitle:@"查看订单" forState:UIControlStateSelected];
        //
        //        [cell.btnRight addTarget:self action:@selector(serverCheckOrderWithSender:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"1"]) {
        
        //cell.stateLabel.text = @"用户取消";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"2"]) {
        
        //cell.stateLabel.text = @"退款中";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"3"]) {
        
        //cell.stateLabel.text = @"退款失败";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"4"]) {
        
        //cell.stateLabel.text = @"退款成功";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"5"]) {
        
        //cell.stateLabel.text = @"等待退款";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"6"] && ([model.orderStatus isEqualToString:@"9"] || [model.statusValue isEqualToString:@"2"])) {
        
        //cell.stateLabel.text = @"等待买家发货";
        cell.stateLabel.text = model.returnsStatus;
        
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
        /**
         *  3.0.0 暂未用
         */
        
//        cell.btnRight.layer.borderColor = [UIColor colorWithHexString:@"#898e90"].CGColor;
//        cell.btnRight.layer.borderWidth = 0.35;
//        cell.btnRight.layer.cornerRadius = 3.0;
//        cell.btnRight.layer.masksToBounds = YES;
//        
//        [cell.btnRight setTitle:@"填写物流" forState:UIControlStateNormal];
//        
//        [cell.btnRight addTarget:self action:@selector(writeLogisticsInfoWithSender:) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    if ([model.returnsStatusValue isEqualToString:@"7"]) {
        
        //cell.stateLabel.text = @"等待商家收货";
        cell.stateLabel.text = model.returnsStatus;
        //TODO:查看物流（H5的，iOS不做）
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"8"]) {
        
        //cell.stateLabel.text = @"审核拒绝";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"9"]) {
        
        //cell.stateLabel.text = @"已退货";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"10"]) {
        
        //cell.stateLabel.text = @"已换货";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    if ([model.returnsStatusValue isEqualToString:@"11"]) {
        
        //cell.stateLabel.text = @"商家已收获";
        cell.stateLabel.text = model.returnsStatus;
        [cell.btnLeft setHidden:YES];
        [cell.btnRight setHidden:YES];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    myOrderCellModel *model = self.dataArray[indexPath.row];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];

    //退货
    if ([model.returnsTypeValue isEqualToString:@"0"]) {
        
        MFDAfterSalesReturnGoodsViewController *afterReturnVC = [story instantiateViewControllerWithIdentifier:@"MFDAfterSalesReturnGoodsViewController"];
        afterReturnVC.afterSalesId = model.myOrderCellModelId;
        
        [self.navigationController pushViewController:afterReturnVC animated:YES];
        
    }
    //退款
    else if ([model.returnsTypeValue isEqualToString:@"1"]) {
        
        //不跳转
    }
    //换货
    else if ([model.returnsTypeValue isEqualToString:@"2"]) {
        
        MFDAfterSalesOrderDetailViewController *afterSalesVC = [story instantiateViewControllerWithIdentifier:@"MFDAfterSalesOrderDetailViewController"];
        afterSalesVC.afterSalesId = model.myOrderCellModelId;
        
        [self.navigationController pushViewController:afterSalesVC animated:YES];

    }
    //其他状态
    else {
        
        MFDAfterSalesOrderDetailViewController *afterSalesVC = [story instantiateViewControllerWithIdentifier:@"MFDAfterSalesOrderDetailViewController"];
        afterSalesVC.afterSalesId = model.myOrderCellModelId;
        
        [self.navigationController pushViewController:afterSalesVC animated:YES];
        
    }
    
    
    
}



#pragma mark --填写物流信息
- (void)writeLogisticsInfoWithSender:(UIButton *)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    MFDWriteLogisticsViewController *writeLogisticsVC = [story instantiateViewControllerWithIdentifier:@"MFDWriteLogisticsViewController"];
    writeLogisticsVC.delegate = self;
    myOrderCellModel *model = self.dataArray[sender.tag];
    writeLogisticsVC.goodsId = model.myOrderCellModelId;
    [self.navigationController pushViewController:writeLogisticsVC animated:YES];
    
}

//#pragma mark --查看订单
//- (void)serverCheckOrderWithSender:(UIButton *)sender {
//
//    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    RJPayOrderDetailViewController *orderDetailVC = [sb instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
//    myOrderCellModel *model = self.dataArray[sender.tag];
//    orderDetailVC.orderId = model.myOrderCellModelId;
//    [self.navigationController pushViewController:orderDetailVC animated:YES];
//
//}




#pragma mark --申请撤回
- (void)serverUndoApplyWithSender:(UIButton *)sender {
    
    //撤回退换货申请接口：https://api.ssrj.com/api/v4/member/returns/cancel/{id}.jhtml?id=退换货单ID&token=xxx    POST请求
    
    myOrderCellModel *model = self.dataArray[sender.tag];
    
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/returns/cancel/%@.jhtml",model.myOrderCellModelId];
    
    requestInfo.URLString = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"id":model.myOrderCellModelId}];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
                [weakSelf getNetData];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];
    
    
}

@end
