//
//  YuEViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "YuEViewController.h"
#import "YuEMingXiModel.h"

//#import "CreatMatchViewController.h"


static NSString *mingXiCellID = @"MingXiTableViewCell";
static NSString *dingDanCellID = @"DingDanPayedTableViewCell";
static NSString *commentCellID = @"commentCell";

#define yuEBaseUrlString @""

@interface YuEViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *transToCashButton;

@property (weak, nonatomic) IBOutlet UIView *headView;

@property (weak, nonatomic) IBOutlet UILabel *totalMoneyLabel;

//明细tableView
@property (weak, nonatomic) IBOutlet UITableView *mingXiTableView;

//总余额数
@property (strong, nonatomic) NSString *totalMoney;

@property (strong, nonatomic) YuEMingXiModel *YuEMingXiModel;

@property (strong, nonatomic) NSMutableArray *dataArr;

@property (assign, nonatomic) int pageNumber;

@end


@implementation YuEViewController

//- (IBAction)createMatch:(id)sender {
//    
//    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
//    
//    CreatMatchViewController *createMatchVC = [story instantiateViewControllerWithIdentifier:@"CreatMatchViewController"];
//    
//    [self.navigationController pushViewController:createMatchVC animated:YES];
//}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    //显示用户总余额
    RJAccountModel *account = [RJAccountManager sharedInstance].account;
    
    _totalMoneyLabel.text = [account.balance stringValue];

    [MobClick beginLogPageView:@"余额页面"];
    [TalkingData trackPageBegin:@"余额页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"余额页面"];
    [TalkingData trackPageEnd:@"余额页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    _transToCashButton.layer.cornerRadius = 10;
    _transToCashButton.layer.masksToBounds = YES;
    __weak __typeof(&*self)weakSelf = self;
    self.mingXiTableView.tableHeaderView = _headView;
    self.pageNumber = 0;
    self.mingXiTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        //获取用户余额明细数据
        [weakSelf getData];
        [weakSelf getUserBalanceData];
        
    }];
    
    [self.mingXiTableView.mj_header beginRefreshing];
}



//取用户余额请求
- (void)getUserBalanceData {
    
    __weak typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    //token=227a1368bd09faa8f94d9181710ba533
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/index.jhtml?timeString=%@", timeString];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        if ([responseObject objectForKey:@"state"]) {
            //请求成功，后续模型赋值操作
            NSDictionary *dic = [responseObject objectForKey:@"data"];
            RJAccountModel *accountModel = [[RJAccountModel alloc] initWithDictionary:dic error:nil];
            [[RJAccountManager sharedInstance]registerAccount:accountModel];
                
            _totalMoneyLabel.text = [accountModel.balance stringValue];

                
        } else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
        [weakSelf.mingXiTableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.mingXiTableView.mj_header endRefreshing];
        
    }];
    
}


-(void)getData{
    
    __weak typeof(&*self)weakSelf = self;
    _pageNumber = 1;
    //取用户ID
    NSNumber *ID = [[RJAccountManager sharedInstance] account].id;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b82/api/v2/user/finddeposit?userId=%@&pageIndex=%d&pageSize=20",ID,_pageNumber];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
                
            NSNumber *state = [responseObject objectForKey:@"state"];
                
            if (state.intValue == 0) {
                    
                //请求成功，后续模型赋值操作
                NSArray *mingXiArr = [responseObject objectForKey:@"data"];
                
                
                if (mingXiArr.count) {
                    
                    weakSelf.mingXiTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                       
                        [weakSelf getNextPageData];
                        
                    }];
                }
                
                _pageNumber++;
                    
                [weakSelf.dataArr removeAllObjects];
                    
                NSMutableArray *arrayModels = [NSMutableArray array];
                    
                for (NSDictionary *tempDic in mingXiArr) {
                    YuEMingXiModel *model = [[YuEMingXiModel alloc] initWithDictionary:tempDic error:nil];
                        
                    [arrayModels addObject:model];
                }

                weakSelf.dataArr = [arrayModels mutableCopy];
                [weakSelf.mingXiTableView reloadData];
                    
            }else if(state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];

            }else if(state.intValue == 2){
                
//                if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                }
            }
                
        }
        
        else {
                
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.mingXiTableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.mingXiTableView.mj_header endRefreshing];
        
    }];
}


-(void)getNextPageData{
    
    __weak typeof(&*self)weakSelf = self;
    
    //取用户ID
    NSNumber *ID = [[RJAccountManager sharedInstance] account].id;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b82/api/v2/user/finddeposit?userId=%@&pageIndex=%d&pageSize=20",ID, _pageNumber];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                //请求成功，后续模型赋值操作
                NSArray *mingXiArr = [responseObject objectForKey:@"data"];
                
                if (!mingXiArr.count) {
                    
                    [weakSelf.mingXiTableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                
                _pageNumber++;
                
                NSMutableArray *arrayModels = [NSMutableArray array];
                
                for (NSDictionary *tempDic in mingXiArr) {
                    YuEMingXiModel *model = [[YuEMingXiModel alloc] initWithDictionary:tempDic error:nil];
                    
                    [arrayModels addObject:model];
                }
                
                [weakSelf.dataArr addObjectsFromArray:arrayModels];
                [weakSelf.mingXiTableView reloadData];
                
            }else if(state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
                
            }else if(state.intValue == 2){
                
                //                if ([RJAccountManager sharedInstance].token) {
                //                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
                //                }
            }
            
        }
        
        else {
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.mingXiTableView.mj_footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.mingXiTableView.mj_footer endRefreshing];
        
    }];
}



#pragma mark --UITableViewDelegate,DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //明细cell
    if (indexPath.row == 0) {
        MingXiTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mingXiCellID];

        return cell;

    }
    
    //订单支付cell
    else {
        DingDanPayedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:dingDanCellID];
        
        //明细cell占据了一个cell,故需－1
        YuEMingXiModel *model = self.dataArr[indexPath.row-1];
        
        cell.dingDanLabel.text = model.typeName;
        cell.dingDanTimeLabel.text = model.createPDate;
        cell.moneyLeftLabel.text = [model.balance stringValue];
        
        //符号标记
        NSString *symbol = [NSString string];
        if ([model.depositType isEqualToString:@"-1"]) {
            symbol = @"-";
        }
        if ([model.depositType isEqualToString:@"1"]) {
            symbol = @"";
        }
        
        cell.moneyUsedLabel.text = [NSString stringWithFormat:@"%@%@", symbol,model.amount];
        
        return cell;

    }

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArr.count+1;//明细占去了一个cell
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end



//明细cell
@implementation MingXiTableViewCell

//-(void)awakeFromNib{
//    [super awakeFromNib];
//    _mingXinImageView.image = [UIImage imageNamed:@"mingxi_icon"];
//    _indexImageview.image = [UIImage imageNamed:@"sort_section_down"];
//}


@end


//订单支付cell
@implementation DingDanPayedTableViewCell

//-(void)awakeFromNib{
//    [self awakeFromNib];
//    
//    
//}

@end


