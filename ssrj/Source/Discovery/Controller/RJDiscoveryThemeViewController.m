
#import "RJDiscoveryThemeViewController.h"
#import "RJHomeItemTypeFourModel.h"

#import "CollectionsViewController.h"
#import "ThemeDetailVC.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ZanModel.h"
#import "CCMatchOrderView.h"
#import "RJHomeNewSubjectAndCollectionCell.h"
@interface RJDiscoveryThemeViewController ()<UITableViewDataSource,UITableViewDelegate,RJHomeNewSubjectAndCollectionCellDelegate, ThemeDetailVCDelegate,CCMatchOrderViewDelegate,RJTapedUserViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (assign, nonatomic) NSInteger pageNumber;

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) IBOutlet CCMatchOrderView *headerView;
@property (assign, nonatomic) NSInteger  orderType;
@property (strong, nonatomic) NSString *currentUrl;


@end
//NSString *const currentUrl = @"/b82/api/v5/goods/findGoodsThemeItem";
@implementation RJDiscoveryThemeViewController

//该方法为合辑详情VC的代理方法，应只考虑了首页的刷新，故方法名称只与首页相关，不影响代理方法实现
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    
    RJHomeItemTypeFourModel *model = self.dataArray[_indexPath.row];
    model.isThumbsup = [NSNumber numberWithBool:btnSelected];
    
    if (btnSelected) {
        
        model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
    }
    else {
        
        if (model.thumbsupCount.intValue <= 0) {
            
            model.thumbsupCount = [NSNumber numberWithInt:0];
        }
        else {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
        }
    }
    
    //局部刷新
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    [self setTitleImage:GetImage(@"collcctionshewhite")];
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    self.pageNumber = 1;
    self.orderType = 3;
    _currentUrl = @"/b180/api/v1/content/publish/theme_item/list/order-chosen/";
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    self.tableView.tableHeaderView = nil;
    self.headerView.delegate = self;
    [self.tableView.mj_header beginRefreshing];

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MobClick beginLogPageView:@"主题列表页"];
    [TalkingData trackPageBegin:@"主题列表页"];


}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"主题列表页"];
    [TalkingData trackPageEnd:@"主题列表页"];


    
}
- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    /**
     *  重置页码
     */
    self.pageNumber = 1;
    requestInfo.URLString = _currentUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"page_index":[NSNumber numberWithInteger:self.pageNumber], @"page_size":@"10", @"appVersion":VERSION}];

    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
//    [requestInfo.getParams addEntriesFromDictionary:@{@"type":@(self.orderType)}];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *itemList = responseObject[@"data"];
                
                if (itemList.count) {
                    //添加上拉加载更多
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextPageData];
                    }];
                }
                
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
              

                weakSelf.pageNumber += 1;
                [weakSelf.tableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
}
- (void)getNextPageData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    requestInfo.URLString = _currentUrl;

    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"page_index":[NSNumber numberWithInteger:self.pageNumber], @"page_size":@"10", @"appVersion":VERSION}];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
//    [requestInfo.getParams addEntriesFromDictionary:@{@"type":@(self.orderType)}];

    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *itemList = responseObject[@"data"];
                if (![itemList isKindOfClass:[NSArray class]]) {
                    [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:1];
                    [weakSelf.tableView.mj_footer endRefreshing];
                    return ;
                }
                //没有数据了 关闭上拉加载更多
                if (![itemList count]) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                self.pageNumber += 1;
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            
        }
        [weakSelf.tableView.mj_footer endRefreshing];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.tableView.mj_footer endRefreshing];

    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    HomeSubjectAndCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeSubjectAndCollectionCell2"];
//    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
//    cell.model = model;
//    cell.delegate = self;
//    return cell;
    
    RJHomeNewSubjectAndCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell"];
    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    //        cell.delagate = self;
    cell.buttonViewHieghtConstraint.constant = 35;
    cell.buttonView.hidden = NO;
    //        cell.userDelegate = self;
    cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
    cell.likeButton.selected = model.isThumbsup.boolValue;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [cell.bigButton addTarget:self action:@selector(goSubjectListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    cell.trackingId = [NSString stringWithFormat:@"%@RJHomeNewSubjectAndCollectionCell&id=%@",NSStringFromClass(self.class),model.themeItemId];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat topViewHei = SCREEN_WIDTH/2;
//    CGFloat view2Hei = 45;
//    CGFloat collectionViewHei = SCREEN_WIDTH/2 + 50;
//    return topViewHei + view2Hei + collectionViewHei + 6 +1;
    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
    
    CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell" configuration:^(RJHomeNewSubjectAndCollectionCell * cell) {
        cell.subjectDescLabel.text = model.memo;
        cell.buttonViewHieghtConstraint.constant = 35;
    }];
    return hei;
}
#pragma mark - RJHomeNewSubjectAndCollectionCellDelegate
- (void)collectionSelectWithId:(NSNumber *)number{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = number;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1010];
//    statisticalDataModel.entranceTypeId = number;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    
    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
    vc.delegate = self;
    vc.themeItemId = model.id;//须加上此值
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1010];
//    statisticalDataModel.entranceTypeId = model.id;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:vc animated:YES];

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
- (void)likeButtonAction:(CCButton *)sender{
//    NSLog(@"点赞");
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=theme_item"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }

    RJHomeItemTypeFourModel *model = self.dataArray[sender.tag];
    
    if (model.id) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.id}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                RJHomeItemTypeFourModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
                
            }
            
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:2];
        
    }];
    
    
}
#pragma mark -
#pragma mark CCMatchOrderViewDelgate
- (void)didSelectButtonIndex:(NSInteger)index{
    
    if (index == 3) {
        
        _currentUrl = @"/b180/api/v1/content/publish/theme_item/list/order-chosen/";
    }
    else if (index == 1) {
        
        _currentUrl = @"/b180/api/v1/content/publish/theme_item/list/order-new/";
    }
    else if (index == 2) {
        
        _currentUrl = @"/b180/api/v1/content/publish/theme_item/list/order-like/";
    }
    
    
    self.orderType = index;
    [self.tableView.mj_header beginRefreshing];
}
#pragma mark -
#pragma mark RJTapedUserViewDelegate
- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString*)userName{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!userId) {
        return;
    }
    rootVc.userId = userId;
    rootVc.userName = userName;
    
    [self.navigationController pushViewController:rootVc animated:YES];
}
@end
