
#import "RJZhuShouViewController.h"
#import "RJAnswerViewController.h"
#import "CCDiarySegmentControl.h"

#import "RJZhuShouCollectionsViewController.h"
#import "RJRecommentGoodViewController.h"
#import "UIImage+New.h"
#import "UIButton+AFNetworking.h"

#import "GuideView.h"

#import "SwipeTableView.h"
#import "CustomSegmentControl.h"
#import "Masonry.h"
@interface RJZhuShouViewController ()<UIScrollViewDelegate,CCDiaryTopBarChanegNumberDelegate,RJAnswerViewControllerDelegate,SwipeTableViewDataSource,SwipeTableViewDelegate,UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate>

@property (strong, nonatomic) NSMutableArray * sceneArray;
@property (strong, nonatomic) RJRecommentGoodViewController * goodVc;
@property (strong, nonatomic) RJZhuShouCollectionsViewController * collacotionVc;
@property (strong, nonatomic) NSMutableArray * selectSceneArray;
@property (nonatomic,strong) UIButton *reloadButton;
@property (nonatomic,strong) UIActivityIndicatorView * indicatorView;

/**
 *  3.1.0 改变页面结构 使用SwipeTableView
 */
@property (strong, nonatomic) SwipeTableView  *swipeTableView;
@property (strong, nonatomic) STHeaderView *tableViewHeaderView;
@property (nonatomic, strong) CustomSegmentControl * segmentBar;

@end

@implementation RJZhuShouViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self setTitle:@"场景穿搭" tappable:NO];
    [self addBarButtonItem:RJNavCartButtonItem onSide:RJNavRightSide];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    UIButton *button = [UIButton buttonWithType:0];
    [button setImage:GetImage(@"zuoti_icon") forState:0];
    button.size = CGSizeMake(44, 64);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button addTarget:self action:@selector(zuotiButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    /**
     *  统计ID
     */
    button.trackingId = [NSString stringWithFormat:@"%@&DaTiButton",NSStringFromClass(self.class)];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    
    
    self.swipeTableView = [[SwipeTableView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:_swipeTableView];

    [self.swipeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).with.insets(UIEdgeInsetsMake(0,0,0,0));
    }];
    
    self.swipeTableView.backgroundColor = [UIColor  clearColor];
    self.swipeTableView.swipeHeaderTopInset = 0;
    
    self.swipeTableView.isNavHidden = NO;
    
    self.swipeTableView.delegate = self;
    self.swipeTableView.dataSource = self;
    self.swipeTableView.shouldAdjustContentSize = YES;
    self.swipeTableView.swipeHeaderView = self.tableViewHeaderView;
    //    _swipeTableView.swipeHeaderBar = self.segmentBar;
    [_swipeTableView.contentView.panGestureRecognizer requireGestureRecognizerToFail:self.screenEdgePanGestureRecognizer];
    _swipeTableView.swipeHeaderBar = self.segmentBar;
    

    self.sceneArray = [NSMutableArray array];
    self.selectSceneArray = [NSMutableArray array];
    self.goodNumber = 0;
    self.collactionNumber = 0;
    
    [self getSecenData];
    
    self.isRootViewController = YES;
}

- (STHeaderView *)tableViewHeaderView{
    if (_tableViewHeaderView == nil) {
        
        self.tableViewHeaderView = [[STHeaderView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (86 - 15)*(SCREEN_WIDTH/320) +15)];
        self.topToolBarView = [[UIView alloc]initWithFrame:_tableViewHeaderView.bounds];
        [_tableViewHeaderView addSubview:self.topToolBarView];
        self.tagScrollView = [[UIScrollView alloc]initWithFrame:_tableViewHeaderView.bounds];
        [_tableViewHeaderView addSubview:self.tagScrollView];
        self.tagScrollView.scrollsToTop = NO;
        
        self.reloadButton = [UIButton buttonWithType:0];
        [self.reloadButton setTitle:@"点击重新加载" forState:0];
        [self.reloadButton setTitleColor:[UIColor blackColor] forState:0];
        self.reloadButton.size = CGSizeMake(SCREEN_WIDTH, self.tagScrollView.height);
        [self.reloadButton addTarget:self action:@selector(getSecenData) forControlEvents:UIControlEventTouchUpInside];
        [self.tagScrollView addSubview:self.reloadButton];
        self.reloadButton.hidden = YES;
        
        self.indicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        self.indicatorView.color = APP_BASIC_COLOR;
        self.indicatorView.center = self.tagScrollView.center;
        
        [self.tagScrollView addSubview:_indicatorView];
        [self.indicatorView startAnimating];
        self.tagScrollView.backgroundColor = [UIColor colorWithHexString:@"#f0eff5"];
        
        
    }
    return _tableViewHeaderView;
}
- (CustomSegmentControl *)segmentBar{
    if (_segmentBar == nil) {
        _segmentBar = [[CustomSegmentControl alloc]initWithItems:@[@"单品",@"搭配"]];
        _segmentBar.parentVcName = NSStringFromClass(self.class);
        
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
#pragma mark - SwipeTableView M
- (NSInteger)numberOfItemsInSwipeTableView:(SwipeTableView *)swipeView {
    return 2;
}
- (UIScrollView *)swipeTableView:(SwipeTableView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIScrollView *)view {
    if (index == 0) {
        if (!self.goodVc) {
            self.goodVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJRecommentGoodViewController"];
            self.goodVc.delegate = self;
            self.goodVc.fatherViewController = self;
            self.goodVc.collectionView.frame = self.swipeTableView.bounds;
            
        }
        view = self.goodVc.collectionView;
    }
    if (index == 1) {
        if (!self.collacotionVc) {
            self.collacotionVc= [self.storyboard instantiateViewControllerWithIdentifier:@"RJZhuShouCollectionsViewController"];
            self.collacotionVc.fatherViewController = self;
            _collacotionVc.delegate = self;
            self.collacotionVc.collectionView.frame = self.swipeTableView.bounds;
        }
        view = self.collacotionVc.collectionView;
    }
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
- (void)getSecenData{
    self.reloadButton.hidden = YES;
    self.indicatorView.hidden = NO;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v3/clad-aide/findfeatruescene"];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *dataArr = responseObject[@"data"];
                if (dataArr.count) {
                    [weakSelf.sceneArray removeAllObjects];
                    for (NSDictionary * dic in dataArr) {
                        RJZhuShouSceneModel *model = [[RJZhuShouSceneModel alloc]initWithDictionary:dic error:nil];
                        if (model) {
                            [weakSelf.sceneArray addObject:model];
                        }
                    }
                    [weakSelf updateScenceView];
                    
                }
            }else{
                weakSelf.reloadButton.hidden = NO;

//                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }else{
//            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        }
        weakSelf.indicatorView.hidden = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        weakSelf.reloadButton.hidden = NO;
        weakSelf.indicatorView.hidden = YES;

    }];
}
- (void)updateScenceView{
    for (UIView * view in self.tagScrollView.subviews) {
        [view removeFromSuperview];
    }
    CGFloat originX = 6;
    CGFloat sizeWith = 0;
    for (int i = 0; i<self.sceneArray.count; i++) {
        RJZhuShouSceneModel *model = self.sceneArray[i];
        UIButton *button = [UIButton buttonWithType:0];
//        [button setTitle:@"呵呵呵呵" forState:0];
//        button.titleLabel.font = GetBoldFont(12);
//        [button sizeToFit];
//        [button setWidth:button.width + 30];
        button.width = 65 *  (SCREEN_WIDTH/320);
        button.height = self.tagScrollView.height - 15;
//        [button setTitle:model.name forState:0];
//        [button setTitleColor:[UIColor whiteColor] forState:0];
//        [button setTitleColor:APP_BASIC_COLOR2 forState:UIControlStateSelected];

        button.layer.borderColor = APP_BASIC_COLOR2.CGColor;
        button.layer.borderWidth = 0;
        [button setBackgroundImageForState:0 withURL:[NSURL URLWithString:model.uncheckedImage] placeholderImage:GetImage(@"default_1x1")];
          [button setBackgroundImageForState:UIControlStateSelected withURL:[NSURL URLWithString:model.checkedImage] placeholderImage:GetImage(@"default_1x1")];
        [button setOrigin:CGPointMake(originX, 8)];
        originX += button.width + 6;

        button.tag = model.id.intValue;

        button.layer.cornerRadius = 3;
        button.clipsToBounds = YES;
        [self.tagScrollView addSubview:button];
        if (i == self.sceneArray.count -1) {
            sizeWith = originX + 6;
        }
//        button.titleLabel.layer.borderColor = [UIColor whiteColor].CGColor;
//        button.titleLabel.layer.borderWidth = 1;
        [button setTitle:@"" forState:0];
        [button addTarget:self action:@selector(tagButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        /**
         *  统计ID
         */
        button.trackingId = [NSString stringWithFormat:@"%@&scenseButton&id=%@",NSStringFromClass(self.class),model.id.stringValue];

    }
    [self.tagScrollView setContentSize:CGSizeMake(sizeWith, self.tagScrollView.height)];
}

- (void)tagButtonAction:(UIButton *)button{
    if ([self.selectSceneArray containsObject:[NSNumber numberWithInteger:button.tag]] && button.selected) {
        [self.selectSceneArray removeAllObjects];
        button.selected = NO;
        button.layer.borderWidth = 0;

    }else{
        for (UIButton * button in self.tagScrollView.subviews) {
            if ([button isKindOfClass:[UIButton class]]) {
                button.selected = NO;
                button.layer.borderWidth = 0;
            }
        }
        [self.selectSceneArray removeAllObjects];
        button.selected = YES;
        button.layer.borderWidth = 0;

        [self.selectSceneArray addObject:[NSNumber numberWithInteger:button.tag]];
    }
//    button.selected = !button.selected;
//    if (button.selected) {
//        [self.selectSceneArray addObject:[NSNumber numberWithInteger:button.tag]];
//    }else{
//        if ([self.selectSceneArray containsObject:[NSNumber numberWithInteger:button.tag]]) {
//            [self.selectSceneArray removeObject:[NSNumber numberWithInteger:button.tag]];
//        }
//    }
//    NSLog(@"%@",self.selectSceneArray);
    [self.goodVc sceneDataChanged:self.selectSceneArray];
    [self.collacotionVc sceneDataChanged:self.selectSceneArray];
//    [HTUIHelper addHUDToWindowWithString:@"加载中..."];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    
}


#pragma mark -CCDiarySegmentDelegate
- (void)selectedWithIndex:(NSInteger)index{
    //    [self setSelectedPageIndex:index animated:YES];
    
//    UIPageViewControllerNavigationDirection direction = self.topSegmentBarView.selectIndex > [self.pages indexOfObject:[self.pageViewController.viewControllers lastObject]] ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
//    
//    [self.pageViewController setViewControllers:@[[self selectedController]]
//                                      direction:direction
//                                       animated:YES
//                                     completion:NULL];
}
#pragma mark -CCDiaryTopBarChanegNumberDelegate
- (void)changeTopNumberWithNumber:(NSInteger)number index:(NSInteger)index{
    if (index == 0) {
        self.goodNumber = number;
    }
    if (index == 1) {
        self.collactionNumber = number;
    }
    NSString *singleStr = [NSString stringWithFormat:@"单品 (%ld)",(long)_goodNumber];
    //
    NSString *releaseStr = [NSString stringWithFormat:@"搭配 (%ld)",(long)_collactionNumber];
    
    NSArray *array = @[singleStr, releaseStr];
    
    [self.segmentBar reloadSegmentBarItemsDataWithArray:array];
    
    
//    CCDiaryTopBar *topbar = self.topSegmentBarView.topBars[index];
//    topbar.numberCountLabel.text = [NSString stringWithFormat:@"%ld",(long)number];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [MobClick beginLogPageView:@"推荐页面"];
    [TalkingData trackPageBegin:@"推荐页面"];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"推荐页面"];
    [TalkingData trackPageEnd:@"推荐页面"];


}
- (void)zuotiButtonAction:(id)sender {
    /**
     *  2.2.0 穿衣助手进来不需要登录 做题需要登录
     */
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        RJAnswerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJAnswerViewController"];
        vc.isPresentIn = YES;
        vc.delegate =  self;
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }else{
        [self presentViewController:[[RJAppManager sharedInstance]getLoginViewController] animated:YES completion:^{
            
        }];
    }
    

}
- (void)redoAnswerSaveAction{
    
    [self.goodVc sceneDataChanged:self.selectSceneArray];
    [self.collacotionVc sceneDataChanged:self.selectSceneArray];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
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
@end



@implementation RJZhuShouSceneModel



@end
