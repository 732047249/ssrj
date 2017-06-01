//
//  MFDWaitPayViewController.m
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDWaitPayViewController.h"
#import "MFDMineOrdersTableViewCell.h"
#import "myOrderCellModel.h"
#import "RJPayOrderDetailViewController.h"

@interface MFDWaitPayViewController()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,RJPayOrderDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *waitPayTableView;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (nonatomic,assign)int pageNumber;
//记录用户取消订单的原因（from actionSheet） add 11.18
@property (strong, nonatomic) NSString *cancelApplyReasonString;


@end

@implementation MFDWaitPayViewController

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的订单待付款页面"];
    [TalkingData trackPageBegin:@"我的订单待付款页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的订单待付款页面"];
    [TalkingData trackPageEnd:@"我的订单待付款页面"];

}

- (void)viewDidLoad{
    [super viewDidLoad];
    __weak __typeof(&*self)weakSelf = self;
    self.pageNumber = 1;
    self.waitPayTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    [self.waitPayTableView.mj_header beginRefreshing];
}

#pragma mark --订单详情代理方法
-(void)reloadOrderStateData {
    
    [self getNetData];
}

- (void)getNetData {
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    _pageNumber = 1;
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
   NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%d&status=pendingPayment&timeString=%@", self.pageNumber, timeString];
    
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
                        weakSelf.waitPayTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                            [weakSelf getNextPageData];
                        }];
                    }
                    _pageNumber += 1;
                    [weakSelf.dataArray removeAllObjects];
                    
                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                }
                else if(state.intValue == 1){
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                    
                }else if(state.intValue == 2){
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
                }
                [weakSelf.waitPayTableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        
        [weakSelf.waitPayTableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.waitPayTableView.mj_header endRefreshing];
        
    }];
    
}

//下拉底部加载更多数据
- (void)getNextPageData {
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];

    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%d&status=pendingPayment&timeString=%@", self.pageNumber, timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject objectForKey:@"state"]) {
            
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    
                    NSArray *arr = [responseObject objectForKey:@"data"];
                    
                    if (!arr.count) {

                        [weakSelf.waitPayTableView.mj_footer endRefreshingWithNoMoreData];
                        return ;
                    }
                    
                    _pageNumber += 1;
                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                } else if (state.intValue == 1) {
                    
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                }else if (state.intValue == 2) {
                 
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
                }
            
                [weakSelf.waitPayTableView reloadData];
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }

        [weakSelf.waitPayTableView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.waitPayTableView.mj_footer endRefreshing];
        
    }];
    
}




#pragma  -tableView dataSource
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
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 8+ 33+ 1+ (SCREEN_WIDTH-2*8-5*3)/4+16 +34 +38 +4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

//待付款
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MFDMineOrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WaitPayTableViewCell" forIndexPath:indexPath];
    
    cell.btnRight.tag = indexPath.row;
    cell.btnLeft.tag = indexPath.row;
    
    myOrderCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;

    if ([model.status isEqualToString:@"pendingPayment"]) {
        
        if (model.hasExpired.intValue == 1) {
            
        }
        else if (model.hasExpired.intValue == 0 && ![model.type isEqualToString:@"swap"]) {
            
            [cell.btnLeft setTitle:@"取消订单" forState:UIControlStateNormal];
            [cell.btnRight setTitle:@"去付款" forState:UIControlStateNormal];
            
            //取消订单
            [cell.btnLeft addTarget:self action:@selector(cancelOrderWithSender:) forControlEvents:UIControlEventTouchUpInside];
            //去付款
            [cell.btnRight addTarget:self action:@selector(goToPayWithSender:) forControlEvents:UIControlEventTouchUpInside];
       }
    }
        
    return cell;
}


#pragma mark --button点击事件方法
#pragma mark --取消订单buttonAction
- (void)cancelOrderWithSender:(UIButton *)sender{
    
    
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"取消订单" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"我不想买了",@"拍错尺码了",@"收货信息写错了",@"其他原因", nil];
    
    menu.delegate = self;
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
    menu.tag = sender.tag;
    
}



#pragma mark -- 取消订单原因选择 actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    _cancelApplyReasonString = [actionSheet buttonTitleAtIndex:buttonIndex];
    
    if (buttonIndex == 4) {
        
        return;
    }
    
    myOrderCellModel *model = self.dataArray[actionSheet.tag];
    NSString *orderSn = model.sn;
    
    
    NSString *urlStr = @"https://api.ssrj.com/api/v5/member/order/cancel.jhtml";
    
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
                [weakSelf.waitPayTableView reloadData];
                
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

#pragma mark --去付款buttonAction
- (void)goToPayWithSender:(UIButton *)sender{
    //调用已有
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RJPayOrderDetailViewController *orderDetailVC = [sb instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
    
    myOrderCellModel *model = self.dataArray[sender.tag];
    orderDetailVC.orderId = model.myOrderCellModelId;
    [self.navigationController pushViewController:orderDetailVC animated:YES];
}

@end
