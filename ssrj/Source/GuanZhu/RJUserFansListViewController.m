
#import "RJUserFansListViewController.h"
#import "RJUserFollowListTableViewCell.h"
#import "RJFansListItemModel.h"
#import "RJUserCenteRootViewController.h"

#import "RJBrandDetailRootViewController.h"
@interface RJUserFansListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) NSInteger  pageNumber;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (weak, nonatomic) IBOutlet UIView *emptyFooterView;

@end

@implementation RJUserFansListViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    self.dataArray = [NSMutableArray array];
    [self setTitle:@"粉丝" tappable:NO];
    __weak __typeof(&*self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];

}
- (void)getNetData{
    self.pageNumber = 1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    if (self.type == RJFansListBrand) {
        requestInfo.URLString = @"api/v5/brand/listBrandFans.jhtml";

    }else{
        requestInfo.URLString = @"api/v5/user/listUserFans.jhtml?";
    }
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (!self.userId) {
        [self.tableView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        return;
    }
    [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.userId,@"pageNumber":[NSNumber numberWithInteger:self.pageNumber]}];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state.boolValue == 0) {
            [weakSelf.dataArray removeAllObjects];
            NSArray *data = responseObject[@"data"];
            weakSelf.pageNumber += 1;
            [weakSelf.tableView.mj_header endRefreshing];
            if (data.count) {
                weakSelf.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
                weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                    [weakSelf getNextPageData];
                }];
            }
            
            for (NSDictionary *dic in data) {
                RJFansListItemModel *model = [[RJFansListItemModel alloc]initWithDictionary:dic error:nil];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [self.tableView reloadData];
        }else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.tableView.mj_header endRefreshing];

        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"请求失败，请稍后再试" hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];

}
- (void)getNextPageData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    if (self.type == RJFansListBrand) {
        requestInfo.URLString = @"api/v5/brand/listBrandFans.jhtml";
        
    }else{
        requestInfo.URLString = @"api/v5/user/listUserFans.jhtml?";
    }
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.userId,@"pageNumber":[NSNumber numberWithInteger:self.pageNumber]}];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state.boolValue == 0) {
            NSArray *data = responseObject[@"data"];
            [weakSelf.tableView.mj_footer endRefreshing];
            if (!data.count) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
            weakSelf.pageNumber += 1;
            for (NSDictionary *dic in data) {
                RJFansListItemModel *model = [[RJFansListItemModel alloc]initWithDictionary:dic error:nil];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [self.tableView reloadData];

        }else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.tableView.mj_footer endRefreshing];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"请求失败，请稍后再试" hideDelay:1];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RJUserFollowListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJUserFollowListTableViewCell2"];
    cell.followButton.tag = indexPath.row;
    [cell.followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    RJFansListItemModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.followButton.selected = NO;
    if (model.isSubscribe.boolValue) {
        cell.followButton.selected = YES;
    }
    cell.followButton.hidden = NO;
    if (model.isSelf.boolValue) {
        cell.followButton.hidden = YES;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    RJFansListItemModel *model = self.dataArray[indexPath.row];
    if (model.type.intValue == 2) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
        
        RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
        
        rootVc.userId = model.id;
        rootVc.userName = model.username;
        
        [self.navigationController pushViewController:rootVc animated:YES];
    }
    if (model.type.intValue == 1) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
        RJBrandDetailRootViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
        vc.brandId = model.id;
        vc.parameterDictionary = @{@"brands":model.id};

        [self.navigationController pushViewController:vc animated:YES];
    }

}
- (void)followButtonAction:(UIButton *)sender{
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UINavigationController * nav =[[RJAccountManager sharedInstance]getLoginVc];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
        return;
    }
    /**
     *  关注 品牌 或者用户
     */
    RJFansListItemModel *model = self.dataArray[sender.tag];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    if (model.type.intValue == 1) {
        requestInfo.URLString = @"/api/v5/member/subscribe/subscribeBrand.jhtml?";

    }else if(model.type.intValue == 2){
        requestInfo.URLString = @"/api/v5/member/subscribe/subscribeUser.jhtml?";

    }else{
        return;
    }
        //品牌
        [requestInfo.postParams addEntriesFromDictionary:@{@"id":model.id}];
        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
        [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSNumber *state  = responseObject[@"state"];
            if (state.boolValue == 0) {
                NSNumber *data = responseObject[@"data"];
                NSNumber *fansCount = responseObject[@"fansCount"];
                model.fansCount = fansCount;
                model.isSubscribe = data;
                if (data.boolValue == 1) {
                    //关注了
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"关注成功" image:nil delyTime:2];
                    
                }else{
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"取消关注成功" image:nil delyTime:1.5];
                }
                [self.tableView reloadData];
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil delyTime:1.5];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil];
        }];
    
}
@end
