//
//  JiFenViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "JiFenViewController.h"
#import "JiFenMingXiModel.h"
#import "AskForTransPayWayViewController.h"


static NSString *cellID = @"JiFenTableVeiwCell";

@interface JiFenViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headView;
//暂未用到
@property (weak, nonatomic) IBOutlet UIView *bottomColorView;
//总积分label
@property (weak,nonatomic) IBOutlet UILabel *jiFenLabel;

@property (weak, nonatomic) IBOutlet UILabel *memberLevelLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) JiFenMingXiModel *JiFenModel;

@property (strong, nonatomic) NSMutableArray *dataArr;

//以下是准备传值给积分申请提现的字段
//最高能提现金额(提示语)
@property (strong, nonatomic) NSString *topAmount;
//能提现金额
@property (strong, nonatomic) NSNumber *maxAmount;
//总积分
@property (strong, nonatomic) NSNumber *totalPoints;
@property (nonatomic,strong) UIBarButtonItem  *rightBarItem;

@property (nonatomic,strong) NSNumber * cashStatus;
@property (nonatomic,strong) NSNumber * remarkStatus;

@end

@implementation JiFenViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"时尚币";
    
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"时尚币说明" forState:0];
    button.titleLabel.font = GetFont(15);
    
    [button addTarget:self action:@selector(detailButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, 80, 40);
    self.rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.trackingId = [NSString stringWithFormat:@"%@&detailButton",NSStringFromClass(self.class)];
//    self.navigationItem.rightBarButtonItem = self.rightBarItem;
    
    _tixianButton.layer.cornerRadius = 12.5;
    _tixianButton.layer.masksToBounds = YES;
    _tixianButton.hidden = YES;
    
    self.tableView.tableHeaderView = _headView;
    self.dataArr = [NSMutableArray array];
    
    __weak typeof(&*self)weakSelf = self;
    
    self.tixianButton.trackingId = [NSString stringWithFormat:@"%@",NSStringFromClass(self.class)];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        //获取用户所有的积分
        [weakSelf getData];
        
    }];

    
    [self.tableView.mj_header beginRefreshing];
}
- (void)detailButtonAction:(id)sender{
    [self performSegueWithIdentifier:@"tixianDetailSegue" sender:nil];
}
#pragma mark --UITableViewDelegate,DataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    JiFenTableVeiwCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    JiFenMingXiModel *model = self.dataArr[indexPath.row];
    
    cell.titleLabel.text = model.typeName;
    cell.timeLabel.text = model.createPDate;
    cell.jiFenLabel.text = model.score;
  
    
    return cell;

    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.dataArr.count;
}



- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [_tixianButton setHidden:YES];
    [MobClick beginLogPageView:@"时尚币页面"];
    [TalkingData trackPageBegin:@"时尚币页面"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
        
    [MobClick endLogPageView:@"时尚币页面"];
    [TalkingData trackPageEnd:@"时尚币页面"];

}

- (void)rewriteMemberPointDataWithPoint:(NSNumber *)point memberRank:(NSNumber *)memberRank {
    
        _jiFenLabel.text = point.stringValue;
    
        //设置会员等级
        if (memberRank.intValue == 1) {
            _memberLevelLabel.text = @"铜牌会员";
        }
        if (memberRank.intValue == 2) {
            _memberLevelLabel.text = @"银牌会员";
        }
        if (memberRank.intValue == 3) {
            _memberLevelLabel.text = @"金牌会员";
        }

}


- (void)getData {
    
    __weak typeof(&*self)weakSelf = self;

    //取用户ID
    NSString *userID = [[[RJAccountManager sharedInstance] account].id stringValue];
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b82/api/v5/user/findponit?userId=%@", userID];
    
    requestInfo.URLString = urlStr;
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
                
            NSNumber *state = [responseObject objectForKey:@"state"];
                
            if (state.intValue == 0) {
                
                NSNumber *memberRank = [responseObject objectForKey:@"memberRank"];
                
                NSNumber *point = [responseObject objectForKey:@"point"];
                
                [weakSelf rewriteMemberPointDataWithPoint:point memberRank:memberRank];
                
                weakSelf.topAmount = responseObject[@"topAmount"];
                weakSelf.totalPoints = responseObject[@"totalPoints"];
                weakSelf.maxAmount = responseObject[@"maxAmount"];
                /**
                 *  新增开关
                 */
                if ([responseObject objectForKey:@"cashStatus"]) {
                    self.cashStatus = [responseObject objectForKey:@"cashStatus"];
                    if (self.cashStatus.boolValue) {
//                        self.navigationItem.rightBarButtonItem = self.rightBarItem;
                        self.tixianButton.hidden = NO;
                    }else{
//                        self.navigationItem.rightBarButtonItem = nil;
                        self.tixianButton.hidden = YES;
                    }
                }
                if ([responseObject objectForKey:@"remarkStatus"]) {
                    self.remarkStatus = [responseObject objectForKey:@"remarkStatus"];
                    if (self.remarkStatus.boolValue) {
                        self.navigationItem.rightBarButtonItem = self.rightBarItem;
                    }else{
                        self.navigationItem.rightBarButtonItem = nil;
                    }
                }
                //请求成功，后续模型赋值操作
                NSArray *mingXiArr = [responseObject objectForKey:@"data"];
                    
                [weakSelf.dataArr removeAllObjects];
                    
                NSMutableArray *arrayModels = [NSMutableArray array];
                    
                for (NSDictionary *tempDic in mingXiArr) {
                    JiFenMingXiModel *model = [[JiFenMingXiModel alloc] initWithDictionary:tempDic error:nil];
                        
                    [arrayModels addObject:model];
                }
                    
                weakSelf.dataArr = arrayModels;
                [weakSelf.tableView reloadData];

            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];

            }
            [weakSelf.tableView.mj_header endRefreshing];
                
        }
        
        else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];

    }];
}


- (IBAction)transToCashAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    AskForTransPayWayViewController *askTVC = [story instantiateViewControllerWithIdentifier:@"AskForTransPayWayViewController"];
    askTVC.totalPoints = _totalPoints.stringValue;
    askTVC.topAmount = _topAmount;
    askTVC.maxAmount = _maxAmount.stringValue;
    
    [self.navigationController pushViewController:askTVC animated:YES];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end


//积分tableViewCell
@implementation JiFenTableVeiwCell

- (void)awakeFromNib{
    
    [super awakeFromNib];
}


@end



