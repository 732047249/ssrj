
#import "RJTopicListViewController.h"
#import "RJHomeTopicModel.h"
#import "HomeTopicTableViewCell.h"
#import "ZanModel.h"
#import "RJTopicListGroupView.h"
#import "RJTopicCategoryModel.h"

#import "HHTopicDetailViewController.h"
@interface RJTopicListViewController ()<UITableViewDelegate,UITableViewDataSource,RJTapedUserViewDelegate,RJTopicListGroupViewDelegate>{
   NSUInteger pageIndex;
}
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) RJTopicListGroupView * groupView;
@property (strong, nonatomic) UIView *bgMaskView;
@property (nonatomic, assign) CGFloat groupViewHei;
@property (nonatomic,strong) NSMutableArray * categoryArray;
@end

@implementation RJTopicListViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
//    [self setTitleImage:GetImage(@"topicswhite")];
    if (self.selectCategoryTitle.length) {
        [self setTitle:self.selectCategoryTitle tappable:YES];
    }else{
        [self setTitle:@"全部专题" tappable:YES];
    }
    self.dataArray = [NSMutableArray array];
    self.categoryArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    
    [_tableView registerNib:[UINib nibWithNibName:@"HomeTopicTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeTopicTableViewCell2"];

    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.groupViewHei = 220;
    if (DEVICE_IS_IPHONE4 || DEVICE_IS_IPHONE5) {
        self.groupViewHei = 220;
    }else if(DEVICE_IS_IPHONE6){
        self.groupViewHei = 270;
    }else if(DEVICE_IS_IPHONE6Plus){
        self.groupViewHei = 305;
    }
    
    self.groupView = [[RJTopicListGroupView alloc]initWithFrame:CGRectMake(0, -self.groupViewHei, SCREEN_WIDTH, self.groupViewHei) collectionViewLayout:flowLayout];
    self.groupView.hidden = YES;
    [self.groupView initCommon];
    self.groupView.groupDelegate = self;
    if (!self.selectCategoryId) {
        self.selectCategoryId = [NSNumber numberWithInt:0];
    }
    self.groupView.selectId = self.selectCategoryId;
    [self.view addSubview:_groupView];
}

- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/index/infromlist";
    pageIndex = 1;
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.selectCategoryId.intValue != 0) {
//        NSLog(@"分类ID=%d",self.selectCategoryId.intValue);
        [requestInfo.getParams addEntriesFromDictionary:@{@"informCategoryId":self.selectCategoryId}];
    }
    [requestInfo.getParams addEntriesFromDictionary:@{@"pageIndex":[NSNumber numberWithInteger:pageIndex],@"pageSize":@"10"}];
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *dataArr= responseObject[@"data"];
                if (dataArr.count) {
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextPageData];
                    }];
                    pageIndex ++;

                }
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in dataArr) {
                    RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [self.tableView reloadData];

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
    requestInfo.URLString = @"/b82/api/v5/index/infromlist";

    [requestInfo.getParams addEntriesFromDictionary:@{@"pageIndex":[NSNumber numberWithInteger:pageIndex],@"pageSize":@"10"}];
    __weak __typeof(&*self)weakSelf = self;
    
    if (self.selectCategoryId.intValue != 0) {
//        NSLog(@"分类ID=%d",self.selectCategoryId.intValue);
        [requestInfo.getParams addEntriesFromDictionary:@{@"informCategoryId":self.selectCategoryId}];
    }
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *dataArr= responseObject[@"data"];
                if (dataArr.count == 0) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                //丢弃则重复加载
                pageIndex++;
                for (NSDictionary *dic in dataArr) {
                    RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [self.tableView reloadData];
                
            }else{
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
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
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MobClick beginLogPageView:@"资讯列表页面"];
    [TalkingData trackPageBegin:@"资讯列表页面"];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"资讯列表页面"];
    [TalkingData trackPageEnd:@"资讯列表页面"];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTopicTableViewCell2" forIndexPath:indexPath];
//    cell.topView.hidden = YES;
//    cell.topViewHeightConstraint.constant = 0;
    cell.topView.userInteractionEnabled = NO;
    RJHomeTopicModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.delegate = self;
    [cell.likeButton addTarget:self action:@selector(topicLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.tag = indexPath.row;
    cell.likeButton.titleLabel.text =[NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
    cell.likeButton.selected = model.isThumbsup.boolValue;
    cell.categoryView.hidden = YES;
    if (model.categoryId) {
        cell.categoryView.hidden = NO;
        cell.categoryNameLabel.text = model.categoryName;
    }
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageHei = SCREEN_WIDTH/16*9;
    return imageHei + 6 + 35;
}
- (void)topicLikeButtonAction:(CCButton *)sender{
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=inform";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    __block RJHomeTopicModel *model = self.dataArray[sender.tag];
    if (model.id) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.informId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [ZanModel class];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                RJHomeTopicModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
                
            }
            
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Error"  hideDelay:1];
        
    }];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    {
        HHTopicDetailViewController *hh_VC = [[HHTopicDetailViewController alloc]init];
        RJHomeTopicModel *model = self.dataArray[indexPath.row];
        hh_VC.shareModel = model.inform;
        hh_VC.informId = model.informId;
        hh_VC.isThumbUp = model.isThumbsup;
        
        hh_VC.zanBlock = ^(NSInteger state){
            model.isThumbsup = [NSNumber numberWithInteger:state];
            
            
            if (model.isThumbsup.boolValue) {
                
                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue+1];
            } else {
                
                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue-1];
                if (model.thumbsupCount.intValue<0) {
                    
                    model.thumbsupCount = [NSNumber numberWithInt:0];
                }
            }
            
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        [self.navigationController pushViewController:hh_VC animated:YES];
    }
//    RJTopicDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJTopicDetailViewController"];
//    RJHomeTopicModel *model = self.dataArray[indexPath.row];
//    vc.shareModel = model.inform;
//    vc.informId = model.informId;
//    vc.isThumbUp = model.isThumbsup;
//    
//    vc.zanBlock = ^(NSInteger state){
//        model.isThumbsup = [NSNumber numberWithInteger:state];
//        
//        
//        if (model.isThumbsup.boolValue) {
//            
//            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue+1];
//        } else {
//            
//            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue-1];
//            if (model.thumbsupCount.intValue<0) {
//                
//                model.thumbsupCount = [NSNumber numberWithInt:0];
//            }
//        }
//        
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    };
//    
//    
////    /**
////     *  add 12.20 统计上报
////     */
////    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
////    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
////    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
////    statisticalDataModel.entranceType = [NSNumber numberWithInt:1007];
////    statisticalDataModel.entranceTypeId = model.informId;
////    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
//
//    
//    
//    [self.navigationController pushViewController:vc animated:YES];
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
    
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(rootVc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1019];
//    statisticalDataModel.entranceTypeId = userId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:rootVc animated:YES];
}
#pragma mark -
- (void)didTapTitle:(UIButton *)sender {
//    NSLog(@"头部标题被点击了");
    if (self.groupView.hidden) {
        [self bgMaskView];
        self.bgMaskView.hidden = NO;
        self.groupView.hidden = NO;
        [UIView animateWithDuration:.3 animations:^{
            self.groupView.transform = CGAffineTransformMakeTranslation(0, self.groupViewHei);
            self.triangleImg.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }else{
        [self hidenGroupView];
    }
}
- (void)hidenGroupView{
//    [self.bgMaskView removeFromSuperview];
    self.bgMaskView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.groupView.transform = CGAffineTransformIdentity;
        self.triangleImg.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        self.groupView.hidden = YES;
    }];
}
#pragma mark - 遮罩背景
- (UIView *)bgMaskView {
    if (_bgMaskView == nil) {
        UIView *bgMaskView = [[UIView alloc] init];
        bgMaskView.alpha = 0.4;
        bgMaskView.translatesAutoresizingMaskIntoConstraints = NO;
        bgMaskView.backgroundColor = [UIColor blackColor];
        [self.view insertSubview:bgMaskView aboveSubview:self.tableView];
        bgMaskView.userInteractionEnabled = YES;
        [bgMaskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBgMaskView:)]];
        _bgMaskView = bgMaskView;
        NSArray *cons1 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bgMaskView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgMaskView)];
        NSArray *cons2 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bgMaskView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(bgMaskView)];
        [self.view addConstraints:cons1];
        [self.view addConstraints:cons2];
    }
    return _bgMaskView;
}

- (void)tapBgMaskView:(UITapGestureRecognizer *)sender {
    if (!self.groupView.hidden) {
        [self hidenGroupView];
    }
}

#pragma mark- RJTopicListGroupViewDelegate
- (void)didSelectItemWithCatagoryId:(NSNumber *)selectId name:(NSString *)name{
    if (self.selectCategoryId.intValue != selectId.intValue) {
        self.selectCategoryId = selectId;
        [self.tableView.mj_header beginRefreshing];
    }
    [self setTitle:name tappable:YES];
    [self hidenGroupView];
}
@end
