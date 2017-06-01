//
//  MFDWaitSendViewController.m
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//



//换成已完成的订单界面
// ** 已完成 ** ** 已完成 ** ** 已完成 ** ** 已完成 ** ** 已完成 ** /

#import "MFDWaitSendViewController.h"
#import "MFDMineOrdersTableViewCell.h"
#import "ServerAfterSaleViewController.h"
#import "RJPayOrderDetailViewController.h"
#import "WuliuWebViewController.h"



@interface MFDWaitSendViewController()<UITableViewDelegate,UITableViewDataSource,RJPayOrderDetailViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *waitSendTableView;
@property (strong, nonatomic)NSMutableArray *dataArray;
@property (nonatomic,assign)int pageNumber;
//用以保存物流 web url
@property (strong, nonatomic) NSString *wuliuUrlString;


@end

@implementation MFDWaitSendViewController

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的订单已完成页面"];
    [TalkingData trackPageBegin:@"我的订单已完成页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的订单已完成页面"];
    [TalkingData trackPageEnd:@"我的订单已完成页面"];

}

- (void)viewDidLoad{
    [super viewDidLoad];
    __weak __typeof(&*self)weakSelf = self;
    self.pageNumber = 1;
    
    self.waitSendTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];

    }];
    
  
    [self.waitSendTableView.mj_header beginRefreshing];
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
//    NSLog(@"timeString=%@", timeString);
    
    _pageNumber = 1;

    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%d&status=received&timeString=%@",self.pageNumber, timeString];
    
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
                        weakSelf.waitSendTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
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
                    
                }else if(state.intValue == 2){
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
                }
                [weakSelf.waitSendTableView reloadData];
            }else{
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        [weakSelf.waitSendTableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.waitSendTableView.mj_header endRefreshing];
        
    }];
    
}


#pragma mark --加载底部刷新数据
- (void)getNextPageData {
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
//    NSLog(@"timeString=%@", timeString);
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/order/list.jhtml?pageNumber=%zd&status=received&timeString=%@",self.pageNumber, timeString];
    
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

                    [weakSelf.waitSendTableView.mj_footer endRefreshingWithNoMoreData];
                        
                    return ;
                }
                _pageNumber += 1;
                    
                for (NSDictionary *temp in arr) {
                    myOrderCellModel *model = [[myOrderCellModel alloc]initWithDictionary:temp error:nil];
                    [weakSelf.dataArray addObject:model];
                }
            } else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];

            }
                        
            [weakSelf.waitSendTableView reloadData];
        }else{
                
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
            
   
        
        [weakSelf.waitSendTableView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.waitSendTableView.mj_footer endRefreshing];
        
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

//已完成
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MFDMineOrdersTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WaitSendTableViewCell" forIndexPath:indexPath];
    
    cell.btnRight.tag = indexPath.row;
    cell.btnLeft.tag = indexPath.row;

    myOrderCellModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.btnRight.tag = indexPath.row;
    [cell.btnRight setHidden:NO];
    [cell.btnRight setTitle:@"查看物流" forState:UIControlStateNormal];
    [cell.btnRight addTarget:self action:@selector(checkYuanTongMessage:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


#pragma mark --查看物流
- (void)checkYuanTongMessage:(UIButton *)sender {
    
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
                
                [self.waitSendTableView.mj_header beginRefreshing];
                
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



@end
