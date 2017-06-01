//
//  MFDWaitReceiveViewController.m
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDWaitReceiveViewController.h"
#import "MFDMineOrdersTableViewCell.h"
#import "WuliuWebViewController.h"
#import "RJPayOrderDetailViewController.h"

@interface MFDWaitReceiveViewController()<UITableViewDelegate,UITableViewDataSource,RJPayOrderDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *waitReceiveTableView;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (nonatomic,assign)int pageNumber;
//用以保存物流 web url
@property (strong, nonatomic) NSString *wuliuUrlString;

@end


@implementation MFDWaitReceiveViewController

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的订单待收货页面"];
    [TalkingData trackPageBegin:@"我的订单待收货页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的订单待收货页面"];
    [TalkingData trackPageEnd:@"我的订单待收货页面"];

}

- (void)viewDidLoad{
    [super viewDidLoad];
    __weak __typeof(&*self)weakSelf = self;
    self.pageNumber = 1;


    self.waitReceiveTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];

    [self.waitReceiveTableView.mj_header beginRefreshing];
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
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%d&status=shipped&timeString=%@",self.pageNumber, timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;

    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    NSArray *arr = [responseObject objectForKey:@"data"];
                    
                    if (arr.count) {
                        //添加上拉刷新底部加载更多
                     
                        weakSelf.waitReceiveTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                            [weakSelf getNextPageData];
                        }];
                    }
                    
                    _pageNumber += 1;
                    [weakSelf.dataArray  removeAllObjects];
                    
                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                }else if(state.intValue == 1){
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                    
                }else if(state.intValue == 2){
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
                }
                [weakSelf.waitReceiveTableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
            
        [weakSelf.waitReceiveTableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.waitReceiveTableView.mj_header endRefreshing];
        
    }];
}

#pragma mark --上拉刷新底部加载更多
- (void)getNextPageData {
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];

    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%d&status=shipped&timeString=%@",self.pageNumber, timeString];
    
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
                        
                        [weakSelf.waitReceiveTableView.mj_footer endRefreshingWithNoMoreData];
                        return ;
                    }
                    
                    self.pageNumber += 1;
                    
                    for (NSDictionary *temp in arr) {
                        myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                        [weakSelf.dataArray addObject:model];
                    }
                } else if (state.intValue == 1) {
                    
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];

                } else if (state.intValue == 2) {
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }

                }
            
                [weakSelf.waitReceiveTableView reloadData];
            
        }else{
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
        [weakSelf.waitReceiveTableView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.waitReceiveTableView.mj_footer endRefreshing];
        
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MFDMineOrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WaitReceiveTableViewCell" forIndexPath:indexPath];
    
    cell.btnRight.tag = indexPath.row;
    cell.btnLeft.tag = indexPath.row;
    
    myOrderCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;

    if ([model.status isEqualToString:@"shipped"]) {
        
        [cell.btnLeft setHidden:NO];
        [cell.btnRight setHidden:NO];
        
        [cell.btnLeft setTitle:@"确认收货" forState:UIControlStateNormal];
        [cell.btnRight setTitle:@"查看物流" forState:UIControlStateNormal];
        
        #pragma mark --button Action
        //确认收货
        [cell.btnLeft addTarget:self action:@selector(getGoodsWithSender:) forControlEvents:UIControlEventTouchUpInside];
        //查看物流
        [cell.btnRight addTarget:self action:@selector(checkWhereIsTheGoodsWithSender:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

#pragma mark --确认收货buttonAction
- (void)getGoodsWithSender:(UIButton *)sender{
    
    myOrderCellModel *model = self.dataArray[sender.tag];
    NSString *orderSn = model.sn;
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/receive.jhtml?orderSn=%@", orderSn];
    [self sendOrderRequestWithURL:urlStr];
    
}

#pragma mark --查看物流
//https://www.ssrj.com/api/v2/member/order/logistics.jhtml?token=xxx&shippingSn=发货单号&trackingNo=运单号
- (void)checkWhereIsTheGoodsWithSender:(UIButton *)sender {
    
    myOrderCellModel *model = self.dataArray[sender.tag];
    
    
    //网络请求获取订单物流信息
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/logistics.jhtml?&shippingSn=%@&trackingNo=%@&timeString=%@", model.shippingSn,model.trackingNo, timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            
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
                }
                
            } else{
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        }else{
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

    }];
    
}

#pragma mark --确认收货网络请求
-(void)sendOrderRequestWithURL:(NSString *)urlString{
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970]*1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@&timeString=%@", urlString, timeString];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            
            if ([responseObject objectForKey:@"state"]) {
                
                NSNumber *state = [responseObject objectForKey:@"state"];
                if ([state intValue] == 0) {
                   
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                    
                    //取消及确认收货操作完成后刷新tableView
                    [weakSelf getNetData];

//                    [weakSelf.waitReceiveTableView reloadData];
                    
                } else {
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                }
                
            } else {
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
    }];
}





@end
