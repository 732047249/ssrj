#import "HomeViewController.h"
#import "UIImageView+WebCache.h"
#import "CCScrollBannerView.h"
#import "RJScannerView.h"
#import "HomePageFourCell.h"
#import "SubLBXScanViewController.h"
#import "HomeGoodListViewController.h"
#import "CCButton.h"
#import "RJHomeActivityTableViewCell.h"
#import "RJHomeBannerModel.h"
#import "RJHomeItemTypeZeroModel.h"
#import "RJHomeItemTypeFourModel.h"
#import "RJHomeItemTypeTwoModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "GoodsDetailViewController.h"
#import "CollectionsViewController.h"
#import "ThemeDetailVC.h"
#import "RJWebViewController.h"
#import "RJHomeTopicModel.h"
#import "HomeTopicTableViewCell.h"
#import "HHTopicDetailViewController.h"
#import "RJHomeCollectionAndGoodCell.h"

#import "RJDiscoveryMatchViewController.h"
#import "RJDiscoveryThemeViewController.h"
#import "RJTopicListViewController.h"
#import "ZanModel.h"

#import "Masonry.h"
#import "ActivityView.h"
#import "ActivityModel.h"
#import "ActivityViewController.h"
#import "CollectionsHeaderTableViewCell.h"
#import "RJHomeWebActivityModel.h"
#import "GetToThemeViewController.h"
#import "RJBrandDetailRootViewController.h"

#import "SearchGoodsViewController.h"

#import "RJUserCenteRootViewController.h"
#import "RJHomeSpecialWebModel.h"

#import "RJBaseTabBarTableViewController.h"
#import "UIImage+New.h"
#import "RJHomeHotGoodCell.h"
#import "RJHomeHotGoodModel.h"

#import "RJHomeNewSubjectAndCollectionCell.h"
#import "RJNativeAndWebViewController.h"
#import "RJHomeTypeTenModel.h"
#import "CYLTabBar.h"
#import "GuideView.h"
#import "RJHomeGoodActiveListViewController.h"

NSString *const currentUrlString = @"/b82/api/v5/index/homeindex";
//NSString *const currentUrlString = @"http://192.168.1.29:8080/api/v5/index/homeindex";
@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate,CCScrollBannerViewDelegate,HomePageFourCellDelegate,RJHomeNewSubjectAndCollectionCellDelegate,RJHomeCollectionAndGoodCellDelegate,ThemeDetailVCDelegate,CollectionsViewControllerDelegate,RJTapedUserViewDelegate, GetToThemeViewControllerDelegate,RJHomeHotGoodCellDelegate>

@property (strong, nonatomic) NSMutableArray * dataSource;
@property (weak, nonatomic) IBOutlet UIView *customTableHeaderView;

@property (weak, nonatomic) IBOutlet CCScrollBannerView *scrollBannerView;
@property (weak, nonatomic) IBOutlet CCButton *cartButton;
@property (strong, nonatomic) NSMutableArray * bannerDataArray;
@property (weak, nonatomic) IBOutlet CCButton *xinPinButton;
@property (weak, nonatomic) IBOutlet CCButton *zheKouButton;
@property (weak, nonatomic) IBOutlet CCButton *zhuCeButton;
@property (weak, nonatomic) IBOutlet CCButton *brandButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (assign, nonatomic) NSInteger  pageIndex;


/**
 *  活动页
 */
@property (nonatomic, strong)ActivityDataModel *activityDataModel;
@property (nonatomic, strong)ActivityView *activityView;
@property (nonatomic, strong)UIImageView *imageView;


//记录点击的cell的indexPath,用于下级UI返回本UI时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (strong, nonatomic) UIButton * topButton;

@property (nonatomic, assign) BOOL isCanSideBack;

@end

@implementation HomeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    _pageIndex = 1;
    
    //重新获取购物车数量
    [self getCartNumberData];
    //注册购物袋数量改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setHomeCartButtonNumber) name:kNotificationCartNumberChanged object:nil];
    
    //注册成功登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setHomeCartButtonNumber) name:kNotificationLoginSuccess object:nil];
    
    //注册退出登录通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setHomeCartButtonNumber) name:kNotificationLogoutSuccess object:nil];
    
    
    self.dataSource = [NSMutableArray array];
    self.bannerDataArray = [NSMutableArray array];
    self.customNavBarView.backgroundColor = APP_BASIC_COLOR;
    self.scrollBannerView.delegate = self;
    __weak __typeof(&*self)weakSelf = self;
    self.customTableHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/16.0*9.0+80 +6);
    
    self.tableView.tableHeaderView = self.customTableHeaderView;
    self.tableView.scrollsToTop = YES;
    /**
     *  注册Xib
     */
    
    [_tableView registerNib:[UINib nibWithNibName:@"HomeTopicTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeTopicTableViewCell"];
    
    [_tableView registerNib:[UINib nibWithNibName:@"RJHomeCollectionAndGoodCell" bundle:nil] forCellReuseIdentifier:@"RJHomeCollectionAndGoodCell"];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
    
    _activityView = [[ActivityView alloc] initWithView:self.view];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    UIView *viewToAdd = [[UIView alloc] init];
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchActivityImag)];
    _imageView.userInteractionEnabled = YES;
    [_imageView addGestureRecognizer:tap];
    [viewToAdd addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(viewToAdd.mas_left);
        make.right.equalTo(viewToAdd.mas_right);
        make.top.equalTo(viewToAdd.mas_top);
        make.bottom.equalTo(viewToAdd.mas_bottom);
    }];
    [array addObject:viewToAdd];
    
    _activityView.containerSubviews = array;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getActivityNetData];
    });
    
    
    /**
     *  返回顶部button
     */
    self.topButton = [UIButton buttonWithType:0];
    self.topButton.frame = CGRectMake(SCREEN_WIDTH - 60, SCREEN_HEIGHT - 100, 40, 40);
    [self.topButton setImage:GetImage(@"goTop") forState:0];
    [self.topButton addTarget:self action:@selector(goTopButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topButton];
    
    /**
     *  统计ID
     */
    self.xinPinButton.agentButton.trackingId = [NSString stringWithFormat:@"%@&XinPinButton",NSStringFromClass(self.class)];
    self.zheKouButton.agentButton.trackingId = [NSString stringWithFormat:@"%@&ZheKouButton",NSStringFromClass(self.class)];
    self.brandButton.agentButton.trackingId = [NSString stringWithFormat:@"%@&BrnadButton",NSStringFromClass(self.class)];
    //3.1.0 改为当季流行
    self.zhuCeButton.agentButton.trackingId = [NSString stringWithFormat:@"%@&DangJiLiuXing",NSStringFromClass(self.class)];
    self.cartButton.agentButton.trackingId = [NSString stringWithFormat:@"%@&cartButton",NSStringFromClass(self.class)];
    self.searchButton.trackingId = [NSString stringWithFormat:@"%@&searchButton",NSStringFromClass(self.class)];
    CYLTabBar *tabBar = (CYLTabBar *)self.cyl_tabBarController.tabBar;
    for (int i =0; i<tabBar.tabBarButtonArray.count; i++) {
        UIView *view = tabBar.tabBarButtonArray[i];
        if (!view.trackingId) {
            view.trackingId = [NSString stringWithFormat:@"CYLTabBarItem%d",i];
        }
    }

//    [self addGuideView];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ([RJAccountManager sharedInstance].hasAccountLogin) {
        self.zhuCeButton.icon.image = GetImage(@"fenxiangyouli_icon");
        self.zhuCeButton.titleLabel.text = @"当季流行";
    }else{
        self.zhuCeButton.icon.image = GetImage(@"zhuceyouli_icon");
        self.zhuCeButton.titleLabel.text = @"注册有礼";
    }
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(statusBarTappedAction:)
    //                                                 name:kStatusBarTappedNotification
    //                                               object:nil];
    
    [MobClick beginLogPageView:@"首页页面"];
    [TalkingData trackPageBegin:@"首页界面"];
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.scrollBannerView.timer) {
        [self.scrollBannerView startTimer];
    }
    [self forbiddenSideBack];
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_activityView removeFromSuperview];

    if (self.scrollBannerView.timer) {
        [self.scrollBannerView stopTimer];
    }
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
    [self resetSideBack];
    [MobClick endLogPageView:@"首页页面"];
    [TalkingData trackPageEnd:@"首页界面"];
    
//    NSLog(@"statisticalModelArr=%@",[RJAppManager sharedInstance].statisticalModelArr);
    
    
}
- (void)getCartNumberData{
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        
        requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/cart/getCartQuantity.jhtml"];
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
        
        [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    NSNumber *titleNumber = [responseObject objectForKey:@"data"];
                    if (titleNumber) {
                        [RJAccountManager sharedInstance].account.cartProductQuantity = titleNumber;
                        [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
                    }
                }
//                else  if(state.intValue == 2){
//                    if ([RJAccountManager sharedInstance].token) {
//                        [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                    }
//                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }

}
- (void)goTopButtonAction:(UIButton *)sender{
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];

}

#pragma mark - RJTapedUserViewDelegate
- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString *)userName{

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!userId) {
        return;
    }
    rootVc.userId = userId;
    rootVc.userName = userName;
    [self.navigationController pushViewController:rootVc animated:YES];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentOffset.y >= self.view.height) {
        self.topButton.hidden = NO;
    }
    else{
        self.topButton.hidden = YES;
    }
}
#pragma mark -活动弹窗
- (void)touchActivityImag{
    [_activityView hide];
    
    ActivityViewController *activityViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityViewController"];
    activityViewController.activityId = self.activityDataModel.id;
    activityViewController.show_url = self.activityDataModel.show_url;
    activityViewController.share_url = self.activityDataModel.share_url;
    activityViewController.isLogin = self.activityDataModel.isLogin;
    activityViewController.shareType = self.activityDataModel.shareType;
    [self.navigationController pushViewController:activityViewController animated:YES];
    
}

- (void)getActivityNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"api/v5/activity/homePopActivty.jhtml?activityVersion=1.0";
//    requestInfo.URLString = @"http://192.168.1.42/api/v5/activity/homePopActivty.jhtml?activityVersion=1.0";

    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [ActivityModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
      
                ActivityModel *model = responseObject;
                ActivityDataModel *dataModel = [model.data lastObject];
                _activityDataModel = dataModel;
                if (model.data.count) {
                    if (dataModel.image) {
                        [weakSelf.imageView sd_setImageWithURL:[NSURL URLWithString:dataModel.image]placeholderImage:nil];
                        [[UIApplication sharedApplication].keyWindow addSubview:_activityView];
                        [_activityView show];
                    }
                }
            }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

    }];
}



#pragma mark - 新品
- (IBAction)xinPinButtonAction:(id)sender {
    NSDictionary *dic = @{@"upTime":@"new"};
    [self pushToGoodListWithDictionary:dic title:@"新品"];

}

- (IBAction)zhekouButtonAction:(id)sender {
//    NSDictionary *dic = @{@"status":@"1"};
    NSDictionary *dic = @{@"isPromotion":[NSNumber numberWithBool:YES]};
    [self pushToGoodListWithDictionary:dic title:@"折扣"];
}
/**
 *  2.2.0 更改为跳转到品牌的TabBar
 */
- (IBAction)hotButtonAction:(id)sender {
//    HomeGoodListViewController *goodListVc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
//    goodListVc.isHot = YES;
//    [self.navigationController pushViewController:goodListVc animated:YES];

    RJBaseTabBarTableViewController *rootVc = (RJBaseTabBarTableViewController *) [AppDelegate shareInstance].window.rootViewController;
    [RJAppManager sharedInstance].didClickHomeBrand = YES;
    [rootVc setSelectedIndex:1];
    
}

- (IBAction)shareOrZhuceButtonAction:(id)sender {
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        //分享
        /**
         *  3.1.9 不再是分享有礼 是去商品活动页面
         */
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Can" bundle:nil];
        RJHomeGoodActiveListViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJHomeGoodActiveListViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
//        [self performSegueWithIdentifier:@"shareSegue" sender:nil];
    }else{
        //注册
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"RegisterViewController"];
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
}

#pragma mark - 下拉刷新
- (void)getNetData{
    __weak __typeof(&*self)weakSelf = self;
    _pageIndex = 1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = currentUrlString;
//#warning debug
//    requestInfo.URLString = @"http://192.168.1.29:8080/api/v5/index/homeindex";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"useFor":@"app",@"pageIndex":[NSNumber numberWithInteger:_pageIndex],@"pageSize":@"10",@"appVersion":VERSION}];

    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];

    }
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];

            if (number.intValue == 0) {
                NSDictionary *data = responseObject[@"data"];
                NSArray *bannerArr = data[@"balance"];
                weakSelf.bannerDataArray = [NSMutableArray array];
                /**
                 *  解析BannerModel
                 */
                for (NSDictionary *dic in bannerArr) {
                    RJHomeBannerModel *itemModel = [[RJHomeBannerModel alloc]initWithDictionary:dic error:nil];
                    if (itemModel) {
                        if (itemModel.type.intValue == 0 ||itemModel.type.intValue == 1 || itemModel.type.intValue == 2 ||itemModel.type.intValue == 3) {
                            [weakSelf.bannerDataArray addObject:itemModel];
                        }
                    }
                }
                [weakSelf updateHeaderScrollView];
                NSArray *homeList = data[@"homeList"];
                if (homeList.count) {
                    //添加上拉加载更多
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextPageData];
                    }];
                }
                _pageIndex += 1;
                [weakSelf.dataSource removeAllObjects];
                for (NSDictionary * dic in homeList) {
                    NSNumber *type = [dic objectForKey:@"type"];
                    if (![type isKindOfClass:[NSNumber class]]) {
                        continue;
                    }
                    switch (type.intValue) {
                        case 0:{
                            RJHomeItemTypeZeroModel *model = [[RJHomeItemTypeZeroModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                            /**
                             *  资讯文章
                             */
                        case 1:{
                            
                            RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                            
                        case 2:{
                            RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [
                                 weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 4:{
                            RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 6:{
                            /**
                             *  首页Cell展示H5活动 分享链接固定
                             */
                            RJHomeWebActivityModel *model = [[RJHomeWebActivityModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 7:{
                            /**
                             *  首页展示类似闺蜜节活动 分享链接私有 需要用户登录去调用接口获取分享链接
                             */
                            RJHomeSpecialWebModel *model = [[RJHomeSpecialWebModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                            
                        }
                        case 9:{
                            /**
                             *  2.2.0 热卖单品
                             */
                            RJHomeHotGoodModel *model = [[RJHomeHotGoodModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 10:{
                            /**
                             *  上方H5 下方原生的网页
                             */
                            RJHomeTypeTenModel *model = [[RJHomeTypeTenModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }


                [weakSelf.tableView reloadData];
            
                
            }else if(number.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
            }
//            else if(number.intValue == 2){
//                /**
//                 *  后台只在带有memo的接口校验token  加不加无所谓
//                 */
//                if ([RJAccountManager sharedInstance].token) {
//                    [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                }
//            }
        }else{
            [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:1];
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
//        NSLog(@"%ld",(long)operation.response.statusCode);
    }];

}
#pragma mark - 上拉加载更多
- (void)getNextPageData{
    
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = currentUrlString;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"useFor":@"app",@"pageIndex":[NSNumber numberWithInteger:_pageIndex],@"pageSize":@"10",@"appVersion":VERSION}];
    
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSDictionary *data = responseObject[@"data"];
                NSArray *homeList = data[@"homeList"];
                /**
                 *  没有更多数据了 关闭上拉加载更多
                 */
                if (!homeList.count) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return;
                }
                _pageIndex += 1;
                for (NSDictionary * dic in homeList) {
                    NSNumber *type = [dic objectForKey:@"type"];
                    if (![type isKindOfClass:[NSNumber class]]) {
                        continue;
                    }
                    switch (type.intValue) {
                        case 0:{
                            RJHomeItemTypeZeroModel *model = [[RJHomeItemTypeZeroModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                            
                        case 1:{
                            
                            RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 2:{
                            RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 4:{
                            RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 6:{
                            /**
                             *  首页Cell展示H5活动 分享链接固定
                             */
                            RJHomeWebActivityModel *model = [[RJHomeWebActivityModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 7:{
                            /**
                             *  首页展示类似闺蜜节活动 分享链接私有 需要用户登录去调用接口获取分享链接
                             */
                            RJHomeSpecialWebModel *model = [[RJHomeSpecialWebModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                            
                        }
                        case 9:{
                            /**
                             *  2.2.0 热卖单品
                             */
                            RJHomeHotGoodModel *model = [[RJHomeHotGoodModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                            break;
                        case 10:{
                            /**
                             *  上方H5 下方原生的网页
                             */
                            RJHomeTypeTenModel *model = [[RJHomeTypeTenModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataSource addObject:model];
                            }
                        }
                        default:
                            break;
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

#pragma mark - Banner 轮播图
- (void)updateHeaderScrollView{
    if (self.bannerDataArray.count) {
        [self.scrollBannerView uploadScrollBannerViewWithImageDataArray:[self.bannerDataArray copy]];
    }
}

#pragma mark - Banner 搜索🔍
- (IBAction)searchButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    SearchGoodsViewController *searchVC = [story instantiateViewControllerWithIdentifier:@"SearchGoodsViewController"];
    
    [self.navigationController pushViewController:searchVC animated:YES];
}

#pragma mark - Banner 扫一扫

- (IBAction)scannerButtonAction:(id)sender {
    //没有授权情况
    if (![RJScannerView cameraAuthStatus]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有摄像机权限,请到\"设置->时尚日记->相机\"中允许应用访问相机" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        
        [alert show];
        
        return;
    }
    
    //授权情况
    SubLBXScanViewController *scanVc = [RJScannerView openScannerWithParam:[RJScannerView paramSet]];
    
    [scanVc setHidesBottomBarWhenPushed:YES];

    [self.navigationController pushViewController:scanVc animated:YES];

}

#pragma mark - 加入合辑编辑完成代理刷新
- (void)reloadHomeViewCollocationCellDataWithModel:(RJHomeItemTypeTwoModel *)homeItemModel {
    
    if (homeItemModel) {
        
        [self.dataSource replaceObjectAtIndex:_indexPath.row withObject:homeItemModel];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - 为了刷新首页搭配cell点击进入搭配详情后再点击加入合辑按钮，编辑完成后的首页搭配cell数据
- (void)reloadHomeCollocationCellDataWithHomeModel:(RJHomeItemTypeTwoModel *)homeItemModel {

    if (homeItemModel) {
        
        [self.dataSource replaceObjectAtIndex:_indexPath.row withObject:homeItemModel];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];

}




#pragma mark - CCScrollBannerViewDelegate 首页Banner点击
- (void)didSelectImageWithTag:(NSInteger)tag{

    RJHomeBannerModel *model = self.bannerDataArray[tag];
    
    //跳转原生
    if (model.type.intValue == 0) {
       
        NSString *paramValue = model.data.paramValue;
        if (!paramValue.length) {
            return;
        }

        NSArray *arr1 = [paramValue componentsSeparatedByString:@"&"];
        //    NSString *str =[arr1 componentsJoinedByString:@"&"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        BOOL isBrand = NO;
        NSNumber *brandId;
        for (NSString *str in arr1) {
            NSArray *arr = [str componentsSeparatedByString:@"="];
            if (arr.count ==2) {
                [dic addEntriesFromDictionary:@{arr[0]:arr[1]}];
                NSString *str = arr[0];
                if ([str isEqualToString:@"brands"]) {
                    isBrand = YES;
                    brandId = arr[1];
                }
            }
        }
        if (isBrand) {
            [self pushToNewBrandDetailWithDictionary:dic brandId:brandId];
        }else{
            
            [self pushToGoodListWithDictionary:dic];
        }
    }else if (model.type.intValue == 1){
        //跳转网页
        RJWebViewController *webView = [self.storyboard instantiateViewControllerWithIdentifier:@"RJWebViewController"];
        NSString *url = model.data.url;
        if (!url.length) {
            return;
        }
        if (model.data.inform) {
            webView.shareModel = model.data.inform;
        }
        webView.urlStr = url;
        webView.webId = model.data.id;
//        /**
//         *  add 12.16 统计上报
//         */
//        ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//        statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//        statisticalDataModel.NextVCName = NSStringFromClass(webView.class);
//        statisticalDataModel.entranceType = [NSNumber numberWithInt:1001];
//        statisticalDataModel.entranceTypeId = model.data.id;
//        [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
        
        [self.navigationController pushViewController:webView animated:YES];
    }else if(model.type.intValue == 2){
        //闺蜜节活动之类的活动  分享信息需要单独调用接口
        ActivityViewController *activityViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityViewController"];
        activityViewController.activityId = model.data.id;
        activityViewController.show_url = model.data.url;
        activityViewController.share_url = model.data.share_url;
        activityViewController.isLogin = model.data.isLogin;
        activityViewController.shareType = model.data.shareType;
        [self.navigationController pushViewController:activityViewController animated:YES];
    }else if (model.type.intValue == 3){
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Can" bundle:nil];
        
        RJNativeAndWebViewController *webVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJNativeAndWebViewController"];
        webVc.activeId = model.data.id;
        [self.navigationController pushViewController:webVc animated:YES];
    }
    /**
     *  TalkingData 自定义事件
     */
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *labelStr = @"";
        if (model.type.intValue == 0) {
            labelStr =[labelStr stringByAppendingString:@"跳转原生"];
        }else if(model.type.intValue == 1|| model.type.intValue == 2){
            labelStr =[labelStr stringByAppendingString:@"跳转网页"];
        }
        labelStr = [labelStr stringByAppendingString:[NSString stringWithFormat:@"id=%ld",(long)model.data.id.integerValue]];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic addEntriesFromDictionary:@{@"标题":model.data.title?:@"",@"banner位置":[NSString stringWithFormat:@"第%ld个",tag+1],@"idfa":[RJAppManager sharedInstance].IDFA,@"时间":[[RJAppManager sharedInstance]nowTimeString],@"是否登录":[[RJAccountManager sharedInstance]hasAccountLogin]?@"是":@"否"}];
        if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
            [dic addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token,@"userid":[NSString stringWithFormat:@"userid_%d",[RJAccountManager sharedInstance].account.id.intValue]}];
        }
        [TalkingData trackEvent:@"首页Banner点击" label:labelStr parameters:dic];
    });

}
#pragma mark - ========去往商品列表界面 传递参数============
- (void)pushToGoodListWithDictionary:(NSDictionary *)dic{
    
    HomeGoodListViewController *goodListVc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
    goodListVc.parameterDictionary = [dic copy];


    
    [self.navigationController pushViewController:goodListVc animated:YES];
}
- (void)pushToGoodListWithDictionary:(NSDictionary *)dic title:(NSString *)title{
    
    HomeGoodListViewController *goodListVc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
    goodListVc.parameterDictionary = [dic copy];
    if (title) {
        goodListVc.titleStr = title;
    }
    
    [self.navigationController pushViewController:goodListVc animated:YES];
}
#pragma mark - ===========去往新的品牌界面========
- (void)pushToNewBrandDetailWithDictionary:(NSDictionary *)dic brandId:(NSNumber *)brandid{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
    rootVc.parameterDictionary = dic;
    rootVc.brandId = brandid;
    
    
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(rootVc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1001];
//    statisticalDataModel.entranceTypeId = brandid;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
    
    [self.navigationController pushViewController:rootVc  animated:YES];
}

#pragma mark - UITabelViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    id model = self.dataSource[indexPath.row];
    
    if ([model isKindOfClass:[RJHomeItemTypeZeroModel class]]) {
        HomePageFourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        RJHomeItemTypeZeroModel *model = self.dataSource[indexPath.row];
        cell.delegate = self;
        cell.fatherViewClassName = NSStringFromClass(self.class);
        cell.model = model;
        return cell;
    }
    /**
     *  主题带搭配Cell
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {

        RJHomeNewSubjectAndCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell"];
        RJHomeItemTypeFourModel *model = self.dataSource[indexPath.row];
        cell.model = model;
//        cell.delagate = self;
        cell.buttonViewHieghtConstraint.constant = 35;
        cell.buttonView.hidden = NO;
//        cell.userDelegate = self;
        cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        cell.likeButton.tag = indexPath.row;
        [cell.likeButton addTarget:self action:@selector(subjectLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.bigButton addTarget:self action:@selector(goSubjectListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.delegate = self;
        /**
         *  统计ID
         */
        cell.trackingId = [NSString stringWithFormat:@"%@&RJHomeNewSubjectAndCollectionCell&id=%@",NSStringFromClass(self.class),model.id.stringValue];
        
        return cell;
    }
    /**
     *  搭配带单品Cell
     */
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]) {

        RJHomeCollectionAndGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeCollectionAndGoodCell"];
        cell.topViewHieghtConstraint.constant = 35;
        cell.topView.hidden = NO;
        [cell layoutSubviews];
        RJHomeItemTypeTwoModel *model = self.dataSource[indexPath.row];
        cell.model = model;
        cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        cell.likeButton.tag = indexPath.row;
        [cell.likeButton addTarget:self action:@selector(collectionLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        //加入合辑button添加点击事件
        cell.putIntoThemeButton.tag = indexPath.row;
        [cell.putIntoThemeButton addTarget:self action:@selector(putIntoThemeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.delegate = self;
        [cell.topViewButton addTarget:self action:@selector(goCollectionListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.userDelegate = self;
        
        /**
         *  统计ID
         */
        cell.trackingId = [NSString stringWithFormat:@"%@&RJHomeCollectionAndGoodCell&id=%@",NSStringFromClass(self.class),model.id.stringValue];

        return cell;
        
    }
    /**
     *  资讯Cell
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        HomeTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTopicTableViewCell"];
        cell.topView.hidden = NO;
        cell.topViewHeightConstraint.constant = 35;
        [cell.topView layoutSubviews];
        [cell.topView setNeedsLayout];
        
        RJHomeTopicModel *model = self.dataSource[indexPath.row];
        cell.model = model;
        [cell.topicButton addTarget:self action:@selector(goTopicListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.likeButton addTarget:self action:@selector(topicLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.categoryView.hidden = YES;
        if (model.categoryId) {
            cell.categoryView.hidden = NO;
            cell.categoryNameLabel.text = model.categoryName;
            cell.categoryButton.tag = indexPath.row;
            [cell.categoryButton addTarget:self action:@selector(goTopicCategoryListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        cell.likeButton.tag = indexPath.row;
        cell.likeButton.titleLabel.text =[NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        
        cell.delegate = self;
        
        return cell;
    }
    /**
     *  首页cell展示H5活动
     */
    if ([model isKindOfClass:[RJHomeWebActivityModel class]]) {
        RJHomeActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeActivityTableViewCell"];
        cell.normalModel = model;
        return cell;
    }
    /**
     *  闺蜜节活动cell
     */
    if ([model isKindOfClass:[RJHomeSpecialWebModel class]]) {
        RJHomeActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeActivityTableViewCell"];
        RJHomeSpecialWebModel *model = self.dataSource[indexPath.row];
        [cell.activeImageView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:GetImage(@"640X200")];
        
        cell.trackingId = [NSString stringWithFormat:@"%@&RJHomeActivityTableViewCell&id=%@",NSStringFromClass(self.class),model.id.stringValue];

        return cell;
    }
    /**
     *  2.2.0 热卖单品cell
     */
    if ([model isKindOfClass:[RJHomeHotGoodModel class]]) {
        RJHomeHotGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotCell"];
        RJHomeHotGoodModel *model =  self.dataSource[indexPath.row];
        cell.delegate = self;
        cell.model = model;
        
        return cell;
    }
    /**
     *  2.2.0 上方H5 下方原生
     */
    if ([model isKindOfClass:[RJHomeTypeTenModel class]]) {
        /**
         *  公用一种Cell
         */
        RJHomeActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeActivityTableViewCell"];
        RJHomeTypeTenModel *model = self.dataSource[indexPath.row];
        [cell.activeImageView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:GetImage(@"640X200")];
        cell.trackingId = [NSString stringWithFormat:@"%@&RJNativeAndWebCell&id=%@",NSStringFromClass(self.class),model.id.stringValue];

        return cell;
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.dataSource[indexPath.row];
    
    /**
     *  主题带搭配Cell
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
//        CGFloat topViewHei = SCREEN_WIDTH/2;
//        CGFloat view2Hei = 45;
//        CGFloat collectionViewHei = SCREEN_WIDTH/2 + 50;
//        return topViewHei + view2Hei + collectionViewHei + 6 +1;
        RJHomeItemTypeFourModel *model = self.dataSource[indexPath.row];

        CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell" configuration:^(RJHomeNewSubjectAndCollectionCell * cell) {
            cell.subjectDescLabel.text = model.memo;
            cell.buttonViewHieghtConstraint.constant = 35; 
        }];
        return hei;
    }
    /**
     *  搭配带单品Cell高度
     */
    
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){

        RJHomeItemTypeTwoModel *model = self.dataSource[indexPath.row];
        //    CGFloat collectionImageWid = (SCREEN_WIDTH)/4 * 3;
        //    CGFloat collectionViewHei = collectionImageWid + 10 +10 + 69;
        CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeCollectionAndGoodCell" configuration:^(RJHomeCollectionAndGoodCell * cell) {
            cell.topViewHieghtConstraint.constant = 35;
            cell.tagHeightConstraint.constant = 0;

            if (model.themeTagList.count) {
                cell.tagHeightConstraint.constant = 38;
                
            }
            cell.collectionDesLabel.text = model.memo;
        }];
        return hei;
    }
    
    if ([model isKindOfClass:[RJHomeItemTypeZeroModel class]]) {
        CGFloat imageHei = SCREEN_WIDTH/16.0*9.0;
        CGFloat collectionViewHei = SCREEN_WIDTH/320 *114+8+8;
        return imageHei + collectionViewHei +65 + 5;
    }
    /**
     *  资讯
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        CGFloat imageHei = SCREEN_WIDTH/16*9;
        return imageHei + 6 + 35;
    }
    /**
     *  首页cell 展示活动 h5
     */
    if ([model isKindOfClass:[RJHomeWebActivityModel class]]) {
        CGFloat imageHei = SCREEN_WIDTH/16*9;
        return imageHei + 6;
    }
    if ([model isKindOfClass:[RJHomeSpecialWebModel class]] || [model isKindOfClass:[RJHomeTypeTenModel class]]) {
        CGFloat imageHei = SCREEN_WIDTH/16*9;
        return imageHei + 6;
    }
    if ([model isKindOfClass:[RJHomeHotGoodModel class]]) {
        CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
        CGFloat height = imageWid + 10 +15 + 69;
        return height * 2 + 35 +6;
    }
    return 44;

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //用全局变量记录被点击cell的indexPath,用于返回该UI时刷新
    _indexPath = indexPath;
    
    id model = self.dataSource[indexPath.row];
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){
        //去搭配详情界面
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
        
        __block RJHomeItemTypeTwoModel *model = self.dataSource[indexPath.row];
        collectionViewController.collectionId = model.id;
        collectionViewController.delegate = self;//add 8.13
        
        [self.navigationController pushViewController:collectionViewController animated:YES];

    }
    /**
     *  去主题详情界面（合辑详情界面）
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
        __block RJHomeItemTypeFourModel *model = self.dataSource[indexPath.row];
        
        vc.themeItemId = model.themeItemId;
        
        vc.delegate = self;//add 8.13


        
        [self.navigationController pushViewController:vc animated:YES];
    }
    /**
     *  去资讯详情界面
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        
        {
            HHTopicDetailViewController *hh_VC = [[HHTopicDetailViewController alloc]init];
            __block RJHomeTopicModel *model = self.dataSource[indexPath.row];
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
            hh_VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:hh_VC animated:YES];
        }
        
//        RJTopicDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJTopicDetailViewController"];
//        __block RJHomeTopicModel *model = self.dataSource[indexPath.row];
//        vc.shareModel = model.inform;
//        vc.informId = model.informId;
//        vc.isThumbUp = model.isThumbsup;
//        
//        vc.zanBlock = ^(NSInteger state){
//            model.isThumbsup = [NSNumber numberWithInteger:state];
//            
//            if (model.isThumbsup.boolValue) {
//                
//                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue+1];
//            } else {
//                
//                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue-1];
//                if (model.thumbsupCount.intValue<0) {
//                    
//                    model.thumbsupCount = [NSNumber numberWithInt:0];
//                }
//            }
//            
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        };
//        
//        
//        //    /**
//        //     *  add 12.19 统计上报
//        //     */
//        //    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//        //    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//        //    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//        //    statisticalDataModel.entranceType = [NSNumber numberWithInt:1013];
//        //    statisticalDataModel.entranceTypeId = model.informId;
//        //    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
//        
//        [self.navigationController pushViewController:vc animated:YES];
    }
    /**
     *  H5活动
     */
    if ([model isKindOfClass:[RJHomeWebActivityModel class]]) {
        RJHomeWebActivityModel *model = self.dataSource[indexPath.row];
        if (model.inform) {
            RJWebViewController *webVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJWebViewController"];
            webVc.urlStr = model.inform.showUrl;
            webVc.shareModel = model.inform;
            webVc.webId = model.id;
            
//            /**
//             *  add 12.20 统计上报
//             */
//            ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//            statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//            statisticalDataModel.NextVCName = NSStringFromClass(webVc.class);
//            statisticalDataModel.entranceType = [NSNumber numberWithInt:1018];
//            statisticalDataModel.entranceTypeId = model.id;
//            [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

            
            
            [self.navigationController pushViewController:webVc animated:YES];
        }
    }
    /**
     *  特殊的H5活动 闺蜜节那种
     */
    if ([model isKindOfClass:[RJHomeSpecialWebModel class]]) {
        RJHomeSpecialWebModel *model = self.dataSource[indexPath.row];
        
        
        ActivityViewController *activityViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ActivityViewController"];
        activityViewController.activityId = model.id;
        activityViewController.show_url = model.show_url;
        activityViewController.share_url = model.share_url;
        activityViewController.isLogin = model.isLogin;
        activityViewController.shareType = model.shareType;
        
//        /**
//         *  add 12.20 统计上报
//         */
//        ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//        statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//        statisticalDataModel.NextVCName = NSStringFromClass(activityViewController.class);
//        statisticalDataModel.entranceType = [NSNumber numberWithInt:1017];
//        statisticalDataModel.entranceTypeId = model.id;
//        [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

        
        
        [self.navigationController pushViewController:activityViewController animated:YES];
    }
    if ([model isKindOfClass:[RJHomeTypeTenModel class]]) {
        RJHomeTypeTenModel *model = self.dataSource[indexPath.row];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Can" bundle:nil];
        
        RJNativeAndWebViewController *webVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJNativeAndWebViewController"];
        webVc.activeId = model.id;
        
        
//        /**
//         *  add 12.19 统计上报
//         */
//        ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//        statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//        statisticalDataModel.NextVCName = NSStringFromClass(webVc.class);
//        statisticalDataModel.entranceType = [NSNumber numberWithInt:1014];
//        statisticalDataModel.entranceTypeId = model.id;
//        [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

        [self.navigationController pushViewController:webVc animated:YES];

    }
}

#pragma mark - 加入合辑点击事件
- (void)putIntoThemeButtonClicked:(UIButton *)sender {
    
    //添加主题之前用户必须已经登录，需要取用户对应token
    //去登录界面
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [mainStory instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        
        return;
    }
    
    _indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    RJHomeItemTypeTwoModel *model = self.dataSource[sender.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    getToThemeVC.HomeItemTypeTwoModel = model;
    getToThemeVC.collectionID = model.id;
    getToThemeVC.parameterDictionary = @{@"colloctionId":model.id};
    getToThemeVC.delegate = self;
    
    [self.navigationController pushViewController:getToThemeVC animated:YES];
}

#pragma mark - HomePageFourCellDelegate
- (void)bigImageTapedWithDic:(NSDictionary *)dic{
    
    [self pushToGoodListWithDictionary:dic];

}
- (void)bigImageBrandTapedWithDic:(NSDictionary *)dic brandId:(NSNumber *)brandid{
    [self pushToNewBrandDetailWithDictionary:dic brandId:brandid];
}
- (void)collectionTapedWithGoodId:(NSString *)goodId{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    NSNumber *goodId2 = [NSNumber numberWithInteger:goodId.integerValue];
    goodsDetaiVC.goodsId = goodId2;

//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1006];
//    statisticalDataModel.entranceTypeId = (NSNumber *)goodId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
    
    
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
/**
 *  点击下面单品 去单品详情界面
 */
#pragma mark - RJHomeCollectionAndGoodCellDelegate
- (void)collectionTapedWithGoodId:(NSString *)goodId fromCollectionId:(NSNumber *)collectionId{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    NSNumber *goodId2 = [NSNumber numberWithInteger:goodId.integerValue];
    goodsDetaiVC.goodsId = goodId2;
    goodsDetaiVC.fomeCollectionId = collectionId;
    
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = collectionId;
//    statisticalDataModel.entranceTypeId = (NSNumber *)goodId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
- (void)collectionTapedWithTagId:(NSString *)tagId{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
    vc.themeItemId = [NSNumber numberWithInt:[tagId intValue]];
//    vc.parameterDictionary = @{@"thememItemId":tagId};
    
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1015];
//    statisticalDataModel.entranceTypeId = (NSNumber *)tagId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - RJHomeSubjectAndCollectionCellDelegate
- (void)collectionSelectWithId:(NSNumber *)number{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = number;
    
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1016];
//    statisticalDataModel.entranceTypeId = number;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    
    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}
#pragma mark - segue跳转
- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(nullable id)sender{
    if ([identifier isEqualToString:@"GoCartSegue"]) {
        if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self presentViewController:loginNav animated:YES completion:^{
                
            }];
            return NO;
        }
    }
    return YES;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
  
}

- (void)statusBarTappedAction:(NSNotification*)notification {
    [self.tableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - 去资讯列表
- (void)goTopicListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RJTopicListViewController *topicList = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicListViewController"];
    if (sender.tag != 0) {
        RJHomeTopicModel *model = self.dataSource[sender.tag];
        topicList.selectCategoryId = model.categoryId;
        topicList.selectCategoryTitle = model.categoryName;
    }
    
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(topicList.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1007];
//    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
    
    [self.navigationController pushViewController:topicList animated:YES];
}
- (void)goTopicCategoryListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RJTopicListViewController *topicList = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicListViewController"];
    RJHomeTopicModel *model = self.dataSource[sender.tag];
    topicList.selectCategoryId = model.categoryId;
    topicList.selectCategoryTitle = model.categoryName;

//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(topicList.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1008];
//    statisticalDataModel.entranceTypeId = model.categoryId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:topicList animated:YES];
}

#pragma mark - 去搭配List
- (void)goCollectionListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RJDiscoveryMatchViewController *macthVc = [storyBorad instantiateViewControllerWithIdentifier:@"RJDiscoveryMatchViewController"];
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(macthVc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1009];
//    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:macthVc animated:YES];

}
#pragma mark - 去主题List
- (void)goSubjectListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RJDiscoveryThemeViewController *themeVc = [storyBorad instantiateViewControllerWithIdentifier:@"RJDiscoveryThemeViewController"];
    
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(themeVc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1010];
//    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:themeVc animated:YES];
}
#pragma mark - 点赞
- (void)subjectLikeButtonAction:(CCButton *)sender{
//    NSLog(@"主题点赞");
    /**
     *  WTF!
     */
    if ([self ifHasLogin]) {
        [self subjectLikeRequest:sender];
    }
    
}

#pragma mark - 主题点赞接口

- (void)subjectLikeRequest:(CCButton *)sender{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=theme_item"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    RJHomeItemTypeTwoModel *model = self.dataSource[sender.tag];
    
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
                
                RJHomeItemTypeFourModel *model = self.dataSource[sender.tag];
                
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

- (void)collectionLikeButtonAction:(CCButton *)sender{

    if ([self ifHasLogin]) {
        [self collectionLikeRequest:sender];
    }
    
}

#pragma mark - 搭配点赞接口
- (void)collectionLikeRequest:(CCButton *)sender{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"/b82/api/v5/thumb?type=collocation";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    RJHomeItemTypeTwoModel *model = self.dataSource[sender.tag];
    
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
                
                RJHomeItemTypeTwoModel *model = self.dataSource[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@", thumbCount];
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            
            }
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:2];
        
    }];
}
- (void)tapGestureAction:(id)sender{
    NSLog(@"Tap");
}
- (void)topicLikeButtonAction:(CCButton *)sender{
    if ([self ifHasLogin]) {
        [self topicLikeRequest:sender];
    }

}


#pragma mark - 资讯点赞接口
- (void)topicLikeRequest:(CCButton *)sender{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=inform";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    RJHomeTopicModel *model = self.dataSource[sender.tag];
    if (model.id) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.informId}];
    }
    __weak __typeof(&*self)weakSelf = self;

    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
         if ([responseObject objectForKey:@"state"]) {
         
             NSNumber *state = [responseObject objectForKey:@"state"];
         
             if (state.intValue == 0) {
         
                 NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
         
                 BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
         
                 sender.selected = thumb;
         
                 RJHomeTopicModel *model = self.dataSource[sender.tag];
         
                 model.isThumbsup = [NSNumber numberWithBool:thumb];
 
                 model.thumbsupCount = thumbCount;

                 sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
         
             }
         
             else if (state.intValue == 1) {
         
                 [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
             }
         }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription]  hideDelay:1];

    }];
}
//搭配详情的代理方法
//搭配详情header点赞上级UI（本VC）刷新数据
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    
    id model = self.dataSource[_indexPath.row];
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){
        //搭配详情界面
        RJHomeItemTypeTwoModel *model = self.dataSource[_indexPath.row];
        model.isThumbsup = [NSNumber numberWithBool:btnSelected];
        if (btnSelected) {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
            
        } else {
            
            if (model.thumbsupCount.intValue <=0) {
                
                model.thumbsupCount = [NSNumber numberWithInt:0];
                
            } else{
                
                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    /**
     *  主题详情界面（合辑详情界面）
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        RJHomeItemTypeFourModel *model = self.dataSource[_indexPath.row];
        model.isThumbsup = [NSNumber numberWithBool:btnSelected];

        if (btnSelected) {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
            
        } else {
            
            if (model.thumbsupCount.intValue <=0) {
                
                model.thumbsupCount = [NSNumber numberWithInt:0];
                
            } else{
                
                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}

- (void)setHomeCartButtonNumber{
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]){
        
        if ([RJAccountManager sharedInstance].account.cartProductQuantity) {
            _cartButton.titleLabel.text = [RJAccountManager sharedInstance].account.cartProductQuantity.stringValue;
        }

    }
    //未登录购物袋数量隐藏
    else{
        _cartButton.titleLabel.text = @"";
    }
    
}



- (BOOL)ifHasLogin{
    //判断用户是否登录  !!!!@WTF 之前写的什么鬼
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return NO;
    }
    return YES;
}

- (void)dealloc{
    
    //移除购物袋数量改变通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCartNumberChanged object:nil];
    //移除注册成功登录通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccess object:nil];
    //移除注册退出登录通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogoutSuccess object:nil];
}

-(void)forbiddenSideBack{

    //关闭ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
    
}
- (void)resetSideBack {

    //开启ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)addGuideView{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:RJFirstInHome]) {
        GuideView *guidView = [[GuideView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        guidView.identifier = RJFirstInHome;
        if (DEVICE_IS_IPHONE4) {
            guidView.localImage = @"home_4";
        }
        if (DEVICE_IS_IPHONE5) {
            guidView.localImage = @"home_5";
        }
        if (DEVICE_IS_IPHONE6) {
            guidView.localImage = @"home_6";
        }
        if (DEVICE_IS_IPHONE6Plus) {
            guidView.localImage = @"home_6p";
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:guidView];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RJFirstInHome];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
}

@end
