
#import "RJDiscoveryMatchViewController.h"
#import "RJHomeItemTypeTwoModel.h"

#import "UITableView+FDTemplateLayoutCell.h"
#import "HomePageFourCell.h"
#import "GoodsDetailViewController.h"
#import "CollectionsViewController.h"
#import "RJHomeCollectionAndGoodCell.h"
#import "ZanModel.h"
#import "GetToThemeViewController.h"

#import "CCMatchOrderView.h"
#import "ThemeDetailVC.h"
#import "GuideView.h"


@interface RJDiscoveryMatchViewController ()<UITableViewDataSource,UITableViewDelegate,RJHomeCollectionAndGoodCellDelegate, CollectionsViewControllerDelegate,
    CCMatchOrderViewDelegate,RJTapedUserViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (assign, nonatomic) NSInteger pageNumber;

//记录点击的cell的indexPath,用于下级UI返回本UI时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) IBOutlet CCMatchOrderView *headerView;
@property (assign, nonatomic) NSInteger orderType;

@property (strong, nonatomic) NSString *currentUrlSting;

@end

@implementation RJDiscoveryMatchViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    [self setTitleImage:GetImage(@"lookswhite")];
    self.tableView.tableHeaderView = nil;
    self.headerView.delegate = self;
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    self.pageNumber = 1;
    self.orderType = 3;
    _currentUrlSting = @"/b180/api/v2/content/publish/collocation/list/order-chosen/";

    [_tableView registerNib:[UINib nibWithNibName:@"RJHomeCollectionAndGoodCell" bundle:nil] forCellReuseIdentifier:@"RJHomeCollectionAndGoodCell"];

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
//    [self addGuideView];

}
- (void)addGuideView{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:RJFirstInDaPei]) {
        GuideView *guidView = [[GuideView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        guidView.identifier = RJFirstInDaPei;
        if (DEVICE_IS_IPHONE4) {
            guidView.localImage = @"dapei_4";
        }
        if (DEVICE_IS_IPHONE5) {
            guidView.localImage = @"dapei_5";
        }
        if (DEVICE_IS_IPHONE6) {
            guidView.localImage = @"dapei_6";
        }
        if (DEVICE_IS_IPHONE6Plus) {
            guidView.localImage = @"dapei_6p";
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:guidView];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RJFirstInDaPei];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MobClick beginLogPageView:@"搭配列表页"];
    [TalkingData trackPageBegin:@"搭配列表页"];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搭配列表页"];
    [TalkingData trackPageEnd:@"搭配列表页"];
    
}
- (void)getNetData{
    self.pageNumber =1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = _currentUrlSting;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"page_index":[NSNumber numberWithInteger:self.pageNumber], @"page_size":@"10", @"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    /**
     *  新版本增加排序功能
     */
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
                _pageNumber += 1;
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
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
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];

    }];
}
- (void)getNextPageData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = _currentUrlSting;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"page_index":[NSNumber numberWithInteger:self.pageNumber], @"page_size":@"10", @"appVersion":VERSION}];

    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    /**
     *  新版本增加排序功能
     */
//    [requestInfo.getParams addEntriesFromDictionary:@{@"type":@(self.orderType)}];
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *itemList = responseObject[@"data"];
                if (!itemList.count) {
                    
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                self.pageNumber += 1;
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
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
//    HomeCollectionAndGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCollectionAndGoodCell2"];
//    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
//    cell.model = model;
//    cell.delegate = self;
//    return cell;
    
    
    RJHomeCollectionAndGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeCollectionAndGoodCell"];
    cell.topViewHieghtConstraint.constant = 0;
    cell.topView.hidden = YES;
    [cell layoutSubviews];
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.delegate = self;
    cell.likeButton.tag = indexPath.row;
    cell.likeButton.selected = model.isThumbsup.boolValue;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.titleLabel.text = model.thumbsupCount.stringValue;
    cell.userDelegate = self;
    cell.putIntoThemeButton.tag = indexPath.row;
    [cell.putIntoThemeButton addTarget:self action:@selector(putIntoThemeButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    //加入合辑button，tag值取indexPath.row
    cell.putIntoThemeButton.tag = indexPath.row;
    
    cell.trackingId = [NSString stringWithFormat:@"%@&RJHomeCollectionAndGoodCell&id=%@",NSStringFromClass(self.class),model.id];
    
    return cell;
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    self.headerView.height = 44;
    return self.headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
//    CGFloat collectionImageWid = (SCREEN_WIDTH)/2 -10 -10;
//
//    CGFloat collectionViewHei = collectionImageWid + 10 +10 + 69;
//    CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"HomeCollectionAndGoodCell2" configuration:^(HomeCollectionAndGoodCell * cell) {
//        cell.model = model;
//    }];
//    return hei + collectionViewHei;
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
//    CGFloat collectionImageWid = (SCREEN_WIDTH)/4 * 3;
//    CGFloat collectionViewHei = collectionImageWid + 10 +10 + 69;
    CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeCollectionAndGoodCell" configuration:^(RJHomeCollectionAndGoodCell * cell) {
        cell.topViewHieghtConstraint.constant = 0;
        cell.collectionDesLabel.text = model.memo;
        cell.tagHeightConstraint.constant = 0;
        
        if (model.themeTagList.count) {
            cell.tagHeightConstraint.constant = 38;
            
        }
    }];
    return hei;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    
    //去搭配详情界面
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.delegate = self;
    collectionViewController.collectionId = model.id;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1009];
//    statisticalDataModel.entranceTypeId = model.id;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:collectionViewController animated:YES];

}

- (void)likeButtonAction:(CCButton *)sender{
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=collocation";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    
    
    RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];
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
                
                RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@", thumbCount];
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Net Error" hideDelay:2];
        //        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
    
}


/**
 *  点击单品 去单品详情界面
 */
#pragma mark - RJHomeCollectionAndGoodCellDelegate
- (void)collectionTapedWithGoodId:(NSString *)goodId fromCollectionId:(NSNumber *)collectionId{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    NSNumber *goodId2 = (NSNumber *)goodId;
    goodsDetaiVC.goodsId = goodId2;
    goodsDetaiVC.fomeCollectionId = collectionId;

//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = collectionId;
//    statisticalDataModel.entranceTypeId = goodId2;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
- (void)collectionTapedWithTagId:(NSString *)tagId{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
//    vc.parameterDictionary = @{@"thememItemId":tagId};
    vc.themeItemId = [NSNumber numberWithInt:[tagId intValue]];
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1009];
//    statisticalDataModel.entranceTypeId = (NSNumber *)tagId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -- 点击加入合辑button
- (void)putIntoThemeButtonAction:(UIButton *)sender {
    
    //添加主题之前用户必须已经登录，需要取用户对应token
    //去登录界面
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [mainStory instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        
        return;
    }
    
    //    ThemeCollocationList *collectionList = self.data.collocationList[button.tag];
    
    RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];
    
    //TODO:添加cell内主题是否已被点赞字段&是否已被添加至个人收藏字段
    //TODO:请求网络数据
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    getToThemeVC.HomeItemTypeTwoModel = model;
    getToThemeVC.collectionID = model.id;
    getToThemeVC.parameterDictionary = @{@"colloctionId":model.id};
    
//    [self presentViewController:getToThemeVC animated:YES completion:^{
//        
//    }];

    [self.navigationController pushViewController:getToThemeVC animated:YES];
}





#pragma mark -
#pragma mark CCMatchOrderViewDelegate
- (void)didSelectButtonIndex:(NSInteger)index{
    
    if (index == 3) {
        
        _currentUrlSting = @"/b180/api/v2/content/publish/collocation/list/order-chosen/";
    }
    else if (index == 1) {
        
        _currentUrlSting = @"/b180/api/v2/content/publish/collocation/list/order-new/";
    }
    else if (index == 2) {
        
        _currentUrlSting = @"/b180/api/v2/content/publish/collocation/list/order-like/";
    }
    
    
    self.orderType = index;
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
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
//搭配给搭配列表的代理方法
- (void)reloadZanMessageNetDataWithBtnstate:(BOOL)btnSelected {
    
    RJHomeItemTypeTwoModel *model = self.dataArray[_indexPath.row];
    model.isThumbsup = [NSNumber numberWithBool:btnSelected];
    
    if (btnSelected) {
        model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
        
    } else {
        
        if (model.thumbsupCount.intValue <= 0) {
            
            model.thumbsupCount = [NSNumber numberWithInt:0];
        } else {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
        }
        
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
    
}


@end
