//
//  SMCategoryDetailController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMCategaryDetailController.h"
#import "SMGoodsListViewController.h"
#import "SMStuffListViewController.h"
#import "FilterNavigationController.h"
#import "FilterListViewController.h"

#import "HMSegmentedControl.h"

#import "SMAllGoodsAndSourceModel.h"
#import "Masonry.h"
#define KTopTabBarHeight 40


@interface SMCategaryDetailController ()<FilterListViewDelegate, UIScrollViewDelegate>

//筛选导航控制器
@property (strong, nonatomic) FilterNavigationController * filterViewController;
@property (nonatomic,strong)HMSegmentedControl *segmentedControl;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)NSMutableArray *tabbarTitleArr;
@property (strong, nonatomic) UIView * navBar;
//导航条标题
@property (nonatomic,strong) UILabel *titleLabel;
//导航条返回按钮
@property (nonatomic,strong) UIButton *backBtn;
//导航条筛选按钮
@property (nonatomic,strong) UIButton *filterBtn;

/**
 *  筛选传递的参数
 */
@property (strong, nonatomic) NSMutableDictionary *filterDictionary;
@end

@implementation SMCategaryDetailController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //添加统计代码
    if (self.isFromAllGoods) {
        self.view.trackingId = [NSString stringWithFormat:@"SMCategaryDetailController&SMGoodsListViewController"];
    }else {
        self.view.trackingId = [NSString stringWithFormat:@"SMCategaryDetailController&SMStuffListViewController"];
    }
    
    self.view.backgroundColor = [UIColor whiteColor];
    _tabbarTitleArr = [NSMutableArray array];
    
    
    self.filterDictionary  = [NSMutableDictionary dictionary];
    [self.filterDictionary addEntriesFromDictionary:@{@"Category":[NSMutableArray array],
                                                      @"Brand":[NSMutableArray array],
                                                      @"Price":[NSMutableArray array],
                                                      @"Color":[NSMutableArray array]}];
    [self configNavigationBar];
    [self configTabBar];
    [self configScrollView];
    [self addNotification];
    
}
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidScrollNotification:) name:@"ControllerScrollNotification" object:nil];
}

#pragma mark - UI
- (void)configScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    [_segmentedControl bringToFront];
    
    CGFloat y = CGRectGetMaxY(_segmentedControl.frame)-1;
    _scrollView.frame = CGRectMake(0, y, kScreenWidth, self.view.frame.size.height - y);
    _scrollView.contentSize = CGSizeMake(kScreenWidth * self.tabbarArray.count, _scrollView.height);
    
    
    for (int i = 0 ; i < self.tabbarArray.count ; i ++) {
        SMAllGoodsAndSourceModel *model = self.tabbarArray[i];
        if (self.isFromAllGoods) {
            SMGoodsListViewController *vc = [SMGoodsListViewController new];
            vc.ID = model.ID;
            [self addChildViewController:vc];
            if (i == self.selectIndex) {
                vc.view.frame = CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.height);
                vc.view.trackingId = [NSString stringWithFormat:@"SMGoodsListViewController&index=%zd",self.selectIndex];
                [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
                [_scrollView addSubview:vc.view];
                [_scrollView scrollRectToVisible:CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.height) animated:YES];
            }
            }else {
                SMStuffListViewController *vc = [SMStuffListViewController new];
                vc.ID = model.ID;
                [self addChildViewController:vc];
                if (i == self.selectIndex) {
                    vc.view.frame = CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.height);
                    vc.view.trackingId = [NSString stringWithFormat:@"SMStuffListViewController&index=%zd",self.selectIndex];
                    [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
                    [_scrollView addSubview:vc.view];
                    [_scrollView scrollRectToVisible:CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.height) animated:YES];
                }
            }
        
        
    }
}
- (void)configNavigationBar {
    SMAllGoodsAndSourceModel *model = self.tabbarArray[_selectIndex];
    
    _navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    _navBar.backgroundColor = APP_BASIC_COLOR;
    [self.view addSubview:_navBar];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImg = GetImage(@"back_icon");
    [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [_backBtn setImage:buttonImg forState:UIControlStateNormal];
    [_navBar addSubview:_backBtn];
    _backBtn.trackingId = @"SMCategaryDetailController&backBtn";
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.text = model.title;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navBar addSubview:_titleLabel];
    
    
    if (self.isFromAllGoods) {
        _filterBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 44)];
        [_filterBtn setTitle:@"筛选" forState:UIControlStateNormal];
        _filterBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_filterBtn addTarget:self action:@selector(filterBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_navBar addSubview:_filterBtn];
        [_filterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.equalTo(_navBar);
            make.size.mas_equalTo(CGSizeMake(60, 44));
        }];
        _filterBtn.trackingId = @"SMCategaryDetailController&filterBtn";
    }
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(_navBar);
        make.size.mas_equalTo(CGSizeMake(44, 40));
    }];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_navBar);
        make.bottom.equalTo(_navBar);
        make.size.mas_equalTo(CGSizeMake(180, 44));
    }];
}
- (void)configTabBar {
    // Tying up the segmented control to a scroll view
    self.segmentedControl = [[HMSegmentedControl alloc] init];
    for (SMAllGoodsAndSourceModel *model in self.tabbarArray) {
        [_tabbarTitleArr addObject:[NSString stringWithFormat:@"  %@  ",model.title]];
    }
    self.segmentedControl.sectionTitles = _tabbarTitleArr;
    self.segmentedControl.selectedSegmentIndex = 1;
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#5d32b5"],NSFontAttributeName : [UIFont systemFontOfSize:15]};
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#a4a4a4"],NSFontAttributeName : [UIFont systemFontOfSize:15]};
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        weakSelf.selectIndex = index;
        weakSelf.titleLabel.text = weakSelf.tabbarTitleArr[index];
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(kScreenWidth * index, 0, kScreenWidth, weakSelf.scrollView.height) animated:NO];
        NSArray *childs = weakSelf.childViewControllers;
        if (weakSelf.isFromAllGoods) {
            [weakSelf.filterDictionary setObject:[NSMutableArray array] forKey:@"Category"];
            SMGoodsListViewController *vc = childs[index];
            vc.filterDictionary = weakSelf.filterDictionary;
            [weakSelf.scrollView removeSubviews];
            vc.view.frame = CGRectMake(kScreenWidth * index, 0, kScreenWidth, weakSelf.scrollView.height);
            vc.view.trackingId = [NSString stringWithFormat:@"SMGoodsListViewController&index=%zd",index];
            [weakSelf.scrollView addSubview:vc.view];
            [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
        }else {
            SMStuffListViewController *vc = childs[index];
            [weakSelf.scrollView removeSubviews];
            vc.view.frame = CGRectMake(kScreenWidth * index, 0, kScreenWidth, weakSelf.scrollView.height);
            vc.view.trackingId = [NSString stringWithFormat:@"SMStuffListViewController&index=%zd",index];
            [weakSelf.scrollView addSubview:vc.view];
            [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
        }
    }];
    [self.view addSubview:self.segmentedControl];
    _segmentedControl.frame = CGRectMake(0, CGRectGetMaxY(_navBar.frame), kScreenWidth, KTopTabBarHeight);
    
    [self.segmentedControl setSelectedSegmentIndex:_selectIndex];
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    UIView *bottomLine = [[UIView alloc] init];
    bottomLine.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
    [self.segmentedControl addSubview:bottomLine];
    [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_segmentedControl);
        make.bottom.equalTo(_segmentedControl);
        make.height.mas_equalTo(1);
    }];
}

#pragma mark - event
- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)filterBtnClick {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.filterViewController = [storyboard instantiateViewControllerWithIdentifier:@"FilterNavigationController"];
    FilterListViewController *vc = [self.filterViewController.viewControllers firstObject];
    /**
     *  把这个界面的筛选dic 赋值给筛选界面
     */
    vc.dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.filterDictionary mutableCopy]];
    SMAllGoodsAndSourceModel *model = self.tabbarArray[_selectIndex];
    if (model) {
        vc.parameterDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"classifys" : model.ID}];
    }
    vc.delegate = self;
    [vc updateFilterDic];
    [self presentViewController:self.filterViewController animated:YES completion:nil];
}
- (void)controllerDidScrollNotification:(NSNotification *)notification {
    NSString *stateString = notification.object;
    if ([stateString isEqualToString:@"top"]) {
        [UIView animateWithDuration:0.3 animations:^{
            _navBar.frame = CGRectMake(0, 0, kScreenWidth, 64);
        } completion:^(BOOL finished) {
            UIImage *buttonImg = GetImage(@"back_icon");
            [_backBtn setImage:buttonImg forState:UIControlStateNormal];
             _navBar.backgroundColor = APP_BASIC_COLOR;
            _titleLabel.textColor = [UIColor whiteColor];
            if (_filterBtn) {
                [_filterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            _navBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
        } completion:^(BOOL finished) {
            UIImage *buttonImg = GetImage(@"match_jiantou1");
            [_backBtn setImage:buttonImg forState:UIControlStateNormal];
             _navBar.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
            _titleLabel.textColor = [UIColor blackColor];
            if (_filterBtn) {
                [_filterBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
        }];
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x / kScreenWidth;
    _selectIndex = index;
    self.titleLabel.text = self.tabbarTitleArr[index];
    [self.filterDictionary setObject:[NSMutableArray array] forKey:@"Category"];
    
    NSArray *childs = self.childViewControllers;
    if (self.isFromAllGoods) {
        SMGoodsListViewController *vc = childs[index];
        vc.filterDictionary = self.filterDictionary;
        [_scrollView removeSubviews];
        vc.view.frame = CGRectMake(kScreenWidth * index, 0, kScreenWidth, _scrollView.height);
        vc.view.trackingId = [NSString stringWithFormat:@"SMGoodsListViewController&index=%zd",index];
        [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
        [_scrollView addSubview:vc.view];
    }else {
        SMStuffListViewController *vc = childs[index];
        [_scrollView removeSubviews];
        vc.view.frame = CGRectMake(kScreenWidth * index, 0, kScreenWidth, _scrollView.height);
        vc.view.trackingId = [NSString stringWithFormat:@"SMStuffListViewController&index=%zd",index];
        [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
        [_scrollView addSubview:vc.view];
    }
    [_segmentedControl setSelectedSegmentIndex:index animated:YES notify:NO];
}

#pragma mark - FilterListViewDelegate
- (void)filiterDownWithDictionary:(NSMutableDictionary *)dic shouldReload:(BOOL)flag{
    
    self.filterDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (flag) {
        SMGoodsListViewController *vc = self.childViewControllers[self.selectIndex];
        vc.filterDictionary = dic;
        [vc reloadData];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
