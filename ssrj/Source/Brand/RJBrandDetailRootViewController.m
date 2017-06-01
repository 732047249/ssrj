
#import "RJBrandDetailRootViewController.h"
#import "RJBrandDetailGoodsViewController.h"
#import "RJBrandDetailPublishViewController.h"
//#import "RJBrandDetailThumbViewController.h"
#import "SwipeTableView.h"
#import "CustomSegmentControl.h"
#import "RJBrandHeaderModel.h"
#import "UIImage+New.h"
#import "RJUserFollowListViewController.h"
#import "RJUserFansListViewController.h"
@interface RJBrandDetailRootViewController ()<SwipeTableViewDataSource,SwipeTableViewDelegate,UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate,RJBrandDetailGoodsViewControllerDelegate>

@property (strong, nonatomic) SwipeTableView  *swipeTableView;
@property (strong, nonatomic) STHeaderView *tableViewHeaderView;
@property (nonatomic, strong) CustomSegmentControl * segmentBar;


@property (strong, nonatomic) RJBrandDetailGoodsViewController * goodVc;
@property (strong, nonatomic) RJBrandDetailPublishViewController * publishVc;
//@property (strong, nonatomic) RJBrandDetailThumbViewController * thumbVc;
@property (strong, nonatomic) UIImageView * brandBannerImageView;
@property (strong, nonatomic) UILabel * brandNameLabel;
@property (strong, nonatomic) UILabel * fansCountLabel;
@property (strong, nonatomic) UILabel * followCountLabel;
@property (strong, nonatomic) UIButton * followButton;
@property (strong, nonatomic) RJBrandHeaderModel * headerModel;
@end

@implementation RJBrandDetailRootViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self addBackButton];
    [self setTitle:@"" tappable:NO];
    
    self.swipeTableView = [[SwipeTableView alloc]initWithFrame:self.view.bounds];
    self.swipeTableView.backgroundColor = [UIColor  clearColor];
//    self.swipeTableView.swipeHeaderTopInset = 0;
    
    self.swipeTableView.isNavHidden = NO;
    
    self.swipeTableView.delegate = self;
    self.swipeTableView.dataSource = self;
    self.swipeTableView.shouldAdjustContentSize = YES;
    self.swipeTableView.swipeHeaderView = self.tableViewHeaderView;
//    _swipeTableView.swipeHeaderBar = self.segmentBar;
    [self.view addSubview:_swipeTableView];
    [_swipeTableView.contentView.panGestureRecognizer requireGestureRecognizerToFail:self.screenEdgePanGestureRecognizer];
    _swipeTableView.swipeHeaderBar = self.segmentBar;
    
    [self.filterDictionary addEntriesFromDictionary:@{@"Category":[NSMutableArray array],
                                                      @"Brand":[NSMutableArray array],
                                                      @"Price":[NSMutableArray array],
                                                      @"Color":[NSMutableArray array]}];
    [self getBrandHeanderData];


}

- (void)getBrandHeanderData{
    if (self.brandId) {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        requestInfo.URLString = [NSString stringWithFormat:@"api/v5/brand/view.jhtml?id=%@",self.brandId];
        if ([RJAccountManager sharedInstance].token) {
            [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
        }
        //筛选！！！！
        if (self.filterDictionary) {
            NSMutableArray *category = [self.filterDictionary objectForKey:@"Category"];
            if (category.count) {
                NSString *str = [category componentsJoinedByString:@";"];
                [requestInfo.getParams addEntriesFromDictionary:@{@"categoryTag":str}];
            }
            NSMutableArray *brand = [self.filterDictionary objectForKey:@"Brand"];
            if (brand.count) {
                NSString *str = [brand componentsJoinedByString:@";"];
                [requestInfo.getParams addEntriesFromDictionary:@{@"brands":str}];
            }
            NSMutableArray *price = [self.filterDictionary objectForKey:@"Price"];
            if (price.count) {
                NSString *str = [price componentsJoinedByString:@";"];
                [requestInfo.getParams addEntriesFromDictionary:@{@"prices":str}];
            }
            NSMutableArray *color = [self.filterDictionary objectForKey:@"Color"];
            if (color.count) {
                NSString *str = [color componentsJoinedByString:@";"];
                [requestInfo.getParams addEntriesFromDictionary:@{@"colors":str}];
            }
            
        }
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *num = responseObject[@"state"];
                if (num.boolValue == 0) {
                    NSDictionary *dic = responseObject[@"data"];
                    RJBrandHeaderModel *model = [[RJBrandHeaderModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        self.headerModel = model;
                        [self setTitle:model.name tappable:NO];
                        
                        self.brandNameLabel.text = model.name;
                        [self.brandBannerImageView sd_setImageWithURL:[NSURL URLWithString:model.brandImg2] placeholderImage:GetImage(@"640X200")];
                        
                        self.fansCountLabel.text = [NSString stringWithFormat:@"%@",model.fansCount];
                        self.followCountLabel.text = [NSString stringWithFormat:@"%@",model.subscribeCount];
                        self.followButton.selected = model.isSubscribe.boolValue;
                        
                        NSString *singleStr = [NSString stringWithFormat:@"推荐单品 (%@)",_headerModel.goodsCount?:@""];
                        
                        NSString *releaseStr = [NSString stringWithFormat:@"发布 (%@)",_headerModel.releaseCount?:@""];
                        
                        //  NSString *thumbStr = [NSString stringWithFormat:@"点赞 (%@)",_headerModel.thumbupCount?:@""];
                        
                        NSArray *array = @[singleStr, releaseStr];
                        
                        [self.segmentBar reloadSegmentBarItemsDataWithArray:array];
                        
                    }
                    
                }else{
                    [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                }
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];


}
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer {
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.navigationController.view.gestureRecognizers.count > 0) {
        for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers) {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    return screenEdgePanGestureRecognizer;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick beginLogPageView:@"品牌界面"];
    [TalkingData trackPageBegin:@"品牌界面"];


}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick endLogPageView:@"品牌界面"];
    [TalkingData trackPageEnd:@"品牌界面"];
}
- (STHeaderView *)tableViewHeaderView{
    if (_tableViewHeaderView == nil) {
        self.tableViewHeaderView = [[STHeaderView alloc]init];
        CGFloat brandImageHei = SCREEN_WIDTH/64 *27;
        self.brandBannerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,SCREEN_WIDTH,brandImageHei )];
        self.brandBannerImageView.backgroundColor = [UIColor clearColor];
        self.brandBannerImageView.contentMode = UIViewContentModeScaleAspectFill;
        _tableViewHeaderView.frame = CGRectMake(0, 0, SCREEN_WIDTH, brandImageHei);
        [self.tableViewHeaderView addSubview:_brandBannerImageView];
        _tableViewHeaderView.backgroundColor = [UIColor clearColor];
        
        
        CGFloat magicF = SCREEN_WIDTH/320;
        UIImageView *bgImageView = [[UIImageView alloc]initWithFrame:self.brandBannerImageView.bounds];
        bgImageView.image = GetImage(@"Brand_bg");
        [_tableViewHeaderView addSubview:bgImageView];
        self.brandNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 25 * SCREEN_WIDTH/320, SCREEN_WIDTH/2, 0)];
        self.brandNameLabel.textAlignment = NSTextAlignmentCenter;
        self.brandNameLabel.textColor = [UIColor whiteColor];
        self.brandNameLabel.font = GetBoldFont(16);
        self.brandNameLabel.text = @"BLOCH";
        [self.brandNameLabel sizeToFit];
        self.brandNameLabel.text = @"";
        self.brandNameLabel.width = SCREEN_WIDTH/2;
        [_tableViewHeaderView addSubview:self.brandNameLabel];
        
        
        UIButton *button1 = [UIButton buttonWithType:0];
        button1.frame = CGRectMake(SCREEN_WIDTH/2 +25*magicF, self.brandNameLabel.bottomPosition +10*SCREEN_WIDTH/320, (SCREEN_WIDTH/2 -50)/2, 25);
        [button1 setBackgroundColor:[UIColor clearColor]];
        [_tableViewHeaderView addSubview:button1];
        
        UILabel *fansLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        fansLabel.text = @"粉丝";
        fansLabel.font = GetFont(13);
        [fansLabel sizeToFit];
        fansLabel.textColor = [UIColor whiteColor];
        [button1 addSubview:fansLabel];
        [fansLabel setOrigin:CGPointMake(0, 0)];
        
        
//        self.fansCountLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.fansCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button1.frame.size.width-fansLabel.frame.size.width-5, 16)];
        
        self.fansCountLabel.font = GetFont(13);
        self.fansCountLabel.textColor = [UIColor whiteColor];
        self.fansCountLabel.text = @"0";
        self.fansCountLabel.textAlignment = NSTextAlignmentLeft;
//        [self.fansCountLabel sizeToFit];
        self.fansCountLabel.origin = CGPointMake(fansLabel.xPosition + fansLabel.width +5, 0);
        [button1 addSubview:self.fansCountLabel];
        [button1 addTarget:self action:@selector(fansButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *button2 = [UIButton buttonWithType:0];
        button2.frame = CGRectMake(button1.xPosition +button1.width +10 *magicF, button1.yPosition, SCREEN_WIDTH - (button1.xPosition +button1.width +10), 25);
        button2.backgroundColor = [UIColor clearColor];
        [_tableViewHeaderView addSubview:button2];

        
        UILabel *followLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        followLabel.text = @"关注";
        followLabel.font = GetFont(13);
        [followLabel sizeToFit];
        followLabel.textColor = [UIColor whiteColor];
        [button2 addSubview:followLabel];
        [followLabel setOrigin:CGPointMake(0, 0)];
        
        
//        self.followCountLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.followCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, button2.frame.size.width-followLabel.frame.size.width-5, 16)];
        self.followCountLabel.font = GetFont(13);
        self.followCountLabel.textColor = [UIColor whiteColor];
        self.followCountLabel.text = @"0";
        self.followCountLabel.textAlignment = NSTextAlignmentLeft;
//        [self.followCountLabel sizeToFit];
        self.followCountLabel.origin = CGPointMake(followLabel.xPosition + followLabel.width +5, 0);
        [button2 addSubview:self.followCountLabel];
        [button2 addTarget:self action:@selector(followListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        self.followButton = [UIButton buttonWithType:0];
        
        self.followButton.frame = CGRectMake(0, button1.bottomPosition +8*SCREEN_WIDTH/320, 80*SCREEN_WIDTH/320, 25*SCREEN_WIDTH/320);
        self.followButton.center = CGPointMake(SCREEN_WIDTH -SCREEN_WIDTH/2/2, self.followButton.center.y);
        [self.followButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#5d32b5"] size:self.followButton.size] forState:UIControlStateNormal];
        [_tableViewHeaderView addSubview:self.followButton];
    
        self.followButton.titleLabel.font = GetFont(13);
        [self.followButton setTitle:@"十 关注" forState:0];
        self.followButton.layer.cornerRadius = 12*SCREEN_WIDTH/320;
        self.followButton.clipsToBounds = YES;
        
        
        [self.followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.followButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#dfdfdf"] size:self.followButton.size] forState:UIControlStateSelected];
        
        [self.followButton setTitle:@"已关注" forState:UIControlStateSelected];
        
        button1.trackingId = [NSString stringWithFormat:@"%@&tableViewHeaderView&button1",NSStringFromClass([self class])];
        button2.trackingId = [NSString stringWithFormat:@"%@&tableViewHeaderView&button2",NSStringFromClass([self class])];
        self.followButton.trackingId = [NSString stringWithFormat:@"%@&tableViewHeaderView&followButton",NSStringFromClass([self class])];
    }
    return _tableViewHeaderView;
}
- (CustomSegmentControl * )segmentBar {
    if (nil == _segmentBar) {
    
        _segmentBar = [[CustomSegmentControl alloc]initWithItems:@[@"推荐单品",@"发布"]];
        _segmentBar.parentVcName = NSStringFromClass(self.class);
        _segmentBar.parentVcID = self.brandId;

        _segmentBar.size = CGSizeMake(SCREEN_WIDTH, 40);
        _segmentBar.font = [UIFont systemFontOfSize:15];
        _segmentBar.textColor = [UIColor blackColor];
        _segmentBar.selectedTextColor = [UIColor colorWithHexString:@"#6225de"];
        _segmentBar.backgroundColor = [UIColor whiteColor];
        _segmentBar.selectionIndicatorColor = [UIColor clearColor];
        _segmentBar.selectedSegmentIndex = _swipeTableView.currentItemIndex;
        [_segmentBar addTarget:self action:@selector(changeSwipeViewIndex:) forControlEvents:UIControlEventValueChanged];
        _segmentBar.IndexChangeBlock = ^(NSInteger index){
        };
    }
    
    return _segmentBar;
}
- (void)changeSwipeViewIndex:(UISegmentedControl *)seg {
    [_swipeTableView scrollToItemAtIndex:seg.selectedSegmentIndex animated:NO];
    // request data at current index
    //    [self getDataAtIndex:seg.selectedSegmentIndex];
}
#pragma mark -  关注接口
- (void)followButtonAction:(UIButton *)sender{
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UINavigationController * nav =[[RJAccountManager sharedInstance]getLoginVc];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/member/subscribe/subscribeBrand.jhtml?";
    [requestInfo.postParams addEntriesFromDictionary:@{@"id":self.brandId}];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state  = responseObject[@"state"];
        if (state.boolValue == 0) {
            NSNumber *data = responseObject[@"data"];
            NSNumber *fansCount = responseObject[@"fansCount"];
            self.headerModel.fansCount = fansCount;
            self.headerModel.isSubscribe = data;
            self.fansCountLabel.text = [NSString stringWithFormat:@"%d",self.headerModel.fansCount.intValue];
            if (data.boolValue == 1) {
                //关注了
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"关注成功" image:nil delyTime:2];
                self.followButton.selected = YES;
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"取消关注成功" image:nil delyTime:1.5];
                self.followButton.selected = NO;
            }
        }else{
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil delyTime:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"请求失败，请稍后再试" image:nil];
    }];
}

- (void)fansButtonAction:(UIButton *)sender{
    UIStoryboard *storyBoard  = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserFansListViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserFansListViewController"];
    vc.userId = self.brandId;
    vc.type = RJFansListBrand;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)followListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBoard  = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserFollowListViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserFollowListViewController"];
    vc.userId = self.brandId;
    vc.type = RJFollowListBrand;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SwipeTableView M
- (NSInteger)numberOfItemsInSwipeTableView:(SwipeTableView *)swipeView {
    return 2;
}
- (UIScrollView *)swipeTableView:(SwipeTableView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIScrollView *)view {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    if (index == 0) {
        if (!self.goodVc) {
            self.goodVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailGoodsViewController"];
            self.goodVc.fatherViewController = self;
            self.goodVc.delegate = self;
            if (self.brandId) {
                self.goodVc.brandId = self.brandId;
            }
            if (self.parameterDictionary) {
                self.goodVc.parameterDictionary = self.parameterDictionary;
            }
//            self.goodVc.stCollectionView = self.goodVc.collectionView;
//            [self addChildViewController:self.goodVc];
//            [self.goodVc didMoveToParentViewController:self];
        }
        view = self.goodVc.collectionView;
    }
    if(index == 1){
        if (!self.publishVc) {
            self.publishVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailPublishViewController"];
            self.publishVc.faterViewController = self;
            if (self.brandId) {
                self.publishVc.brandId = self.brandId;
            }
        }
        view = self.publishVc.tableView;
    }
//    else if(index == 2){
//        if (!self.thumbVc) {
//            self.thumbVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailThumbViewController"];
//            self.thumbVc.faterViewController = self;
//            if (self.brandId) {
//                self.thumbVc.brandId = self.brandId;
//            }
//        }
//        view = self.thumbVc.tableView;
//    }
    return view;
}
- (CGFloat)swipeTableView:(SwipeTableView *)swipeTableView heightForRefreshHeaderAtIndex:(NSInteger)index {
    
    return 54;
    
}


- (BOOL)swipeTableView:(SwipeTableView *)swipeTableView shouldPullToRefreshAtIndex:(NSInteger)index {
    return YES;
}

// swipetableView index变化，改变seg的index
- (void)swipeTableViewCurrentItemIndexDidChange:(SwipeTableView *)swipeView {
    _segmentBar.selectedSegmentIndex = swipeView.currentItemIndex;
}
@end
