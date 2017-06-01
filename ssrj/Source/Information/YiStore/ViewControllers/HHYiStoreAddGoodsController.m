//
//  HHYiStoreAddGoodsController.m
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHYiStoreAddGoodsController.h"
#import "FilterNavigationController.h"
#import "FilterListViewController.h"
#import "HHYiStoreCatoryViewController.h"

#import "HMSegmentedControl.h"
#import "RJBaseGoodModel.h"

#import "HHYiStoreCatogeryModel.h"

#import "Masonry.h"

static NSString * const CommitUrl = @"http://192.168.1.173:8888/api/v1/mshop/goods/add";
static NSString * const CategoryTitlesUrl = @"/b180/api/v1/collocation/home/";
//static NSString * const CommitUrl = @"http://192.168.1.252:8000/api/v1/mshop/goods/add";

@interface HHYiStoreAddGoodsController ()<FilterListViewDelegate, UIScrollViewDelegate>
//筛选导航控制器
@property (strong, nonatomic) FilterNavigationController * filterViewController;
@property (nonatomic,strong)HMSegmentedControl *segmentedControl;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *categoryArr;
@property (strong, nonatomic) NSMutableDictionary *filterDictionary;
@property (nonatomic, strong) NSMutableArray *tabbarTitleArr;
@property (nonatomic, assign) NSInteger selectIndex;
//导航条筛选按钮
@property (nonatomic,strong) UIButton *filterBtn;
@property (nonatomic, strong) UIButton *chooseSureBtn;
@property (nonatomic, strong) UIButton *chooseAllBtn;

@end

@implementation HHYiStoreAddGoodsController {
    CGFloat chooseBarHeight;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"微店-添加商品页"];
    [TalkingData trackPageBegin:@"微店-添加商品页"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"微店-添加商品页"];
    [TalkingData trackPageEnd:@"微店-添加商品页"];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self configUI];
    
    [self getNetData];
    chooseBarHeight = kScreenWidth > 375 ? 48 : 40;
}
- (void)getNetData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = CategoryTitlesUrl;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            [weakSelf.categoryArr removeAllObjects];
            NSArray *data = responseObject[@"data"];
            NSDictionary *dataDict = [data firstObject];
            if (dataDict && [dataDict isKindOfClass:[NSDictionary class]]) {
                for (NSDictionary *fashDict in dataDict[@"fashion"]) {
                    NSError *error;
                    HHYiStoreCatogeryModel *fashion = [[HHYiStoreCatogeryModel alloc] initWithDictionary:fashDict error:&error];
                    if (!error) {
                        [self.categoryArr addObject:fashion];
                    }
                }
            }
            if (self.categoryArr.count > 0) {
                [self configTabBar];
                [self configScrollView];
                [self configChooseBar];
            }
        }else{
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
    }];
}

- (void)configUI {
    self.title = @"全部女装";
    self.view.backgroundColor = [UIColor whiteColor];
    [self addBackButton];
    UIButton *filterBtn = [[UIButton alloc] init];
    [filterBtn setTitle:@"筛选" forState:UIControlStateNormal];
    filterBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [filterBtn sizeToFit];
    [filterBtn addTarget:self action:@selector(filterBtnClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:filterBtn];
    filterBtn.trackingId = @"HHYiStoreAddGoodsController&filterBtn";
    
}
- (void)configTabBar {
    self.segmentedControl = [[HMSegmentedControl alloc] init];
    for (HHYiStoreCatogeryModel *model in self.categoryArr) {
        [self.tabbarTitleArr addObject:[NSString stringWithFormat:@"  %@  ",model.title]];
    }
    self.segmentedControl.sectionTitles = _tabbarTitleArr;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.backgroundColor = [UIColor whiteColor];
    self.segmentedControl.selectedTitleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#5d32b5"],NSFontAttributeName : [UIFont systemFontOfSize:15]};
    self.segmentedControl.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#a4a4a4"],NSFontAttributeName : [UIFont systemFontOfSize:15]};
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationNone;
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        [weakSelf resetChooseBar];
        _selectIndex = index;
        weakSelf.title = weakSelf.tabbarTitleArr[index];
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(kScreenWidth * index, 0, kScreenWidth, weakSelf.scrollView.height) animated:NO];
        NSArray *childs = weakSelf.childViewControllers;
        [weakSelf.filterDictionary setObject:[NSMutableArray array] forKey:@"Category"];
        HHYiStoreCatoryViewController *vc = childs[index];
        vc.filterDictionary = weakSelf.filterDictionary;
        [weakSelf.scrollView removeSubviews];
        vc.view.frame = CGRectMake(kScreenWidth * index, 0, kScreenWidth, weakSelf.scrollView.height);
        vc.view.trackingId = [NSString stringWithFormat:@"%@&HHYiStoreCatoryViewController&index=%zd",NSStringFromClass([weakSelf class]),index];
        [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
        [weakSelf.scrollView addSubview:vc.view];

    }];
    [self.view addSubview:self.segmentedControl];
    _segmentedControl.frame = CGRectMake(0, 0, kScreenWidth, 40);
    
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
- (void)configScrollView {
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
//    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self.view addSubview:_scrollView];
    [_segmentedControl bringToFront];
    
    CGFloat y = CGRectGetMaxY(_segmentedControl.frame)-1;
    _scrollView.frame = CGRectMake(0, y, kScreenWidth, self.view.frame.size.height - y - chooseBarHeight);
    _scrollView.contentSize = CGSizeMake(kScreenWidth * self.categoryArr.count, _scrollView.height);
    
    
    for (int i = 0 ; i < self.categoryArr.count ; i ++) {
        HHYiStoreCatogeryModel *model = self.categoryArr[i];
        HHYiStoreCatoryViewController *vc = [HHYiStoreCatoryViewController new];
        vc.ID = model.ID;
        [self addChildViewController:vc];
        if (i == self.selectIndex) {
            vc.view.frame = CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.height);
            vc.view.trackingId = [NSString stringWithFormat:@"%@&HHYiStoreCatoryViewController&index=%d",NSStringFromClass([self class]),i];
            [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
            [_scrollView addSubview:vc.view];
            [_scrollView scrollRectToVisible:CGRectMake(kScreenWidth * i, 0, kScreenWidth, _scrollView.height) animated:YES];
        }
    }
}
- (void)configChooseBar {
    _chooseAllBtn = [[UIButton alloc] init];
    _chooseSureBtn.backgroundColor = [UIColor whiteColor];
    _chooseAllBtn.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
    _chooseAllBtn.layer.borderWidth = 0.7;
    [_chooseAllBtn setTitle:@"添加全部商品" forState:UIControlStateNormal];
    [_chooseAllBtn setTitle:@"取消全选" forState:UIControlStateSelected];
    [_chooseAllBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_chooseAllBtn addTarget:self action:@selector(allButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_chooseAllBtn];
    
    
    self.chooseSureBtn = [[UIButton alloc] init];
    _chooseSureBtn.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
    _chooseSureBtn.backgroundColor = [UIColor colorWithHexString:@"#5d32b5"];
    [_chooseSureBtn setTitle:@"添加添加 0" forState:UIControlStateNormal];
    _chooseSureBtn.layer.borderWidth = 0.7;
    [_chooseSureBtn addTarget:self action:@selector(chooseSureBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_chooseSureBtn];
    
    [_chooseAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.equalTo(self.view);
        make.height.mas_equalTo(chooseBarHeight);
        make.width.equalTo(self.view).multipliedBy(0.5);
    }];
    [_chooseSureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.right.equalTo(self.view);
        make.height.mas_equalTo(chooseBarHeight);
        make.left.equalTo(_chooseAllBtn.mas_right);
    }];
}
#pragma mark - 取消全选
- (void)cancelChooseAllState {
    _chooseAllBtn.selected = NO;
}
#pragma mark - 更新选择的商品数量
- (void)updateChooseSureBtnNummber {
    
    HHYiStoreCatoryViewController *vc = self.childViewControllers[_selectIndex];
    [_chooseSureBtn setTitle:[NSString stringWithFormat:@"添加 %zd",[vc choosedGoods].count] forState:UIControlStateNormal];
}
- (void)resetChooseBar {
    HHYiStoreCatoryViewController *vc = self.childViewControllers[_selectIndex];
    [self cancelChooseAllState];
    [vc clearAll];
    [self updateChooseSureBtnNummber];
}
#pragma mark - event
- (void)allButtonClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    HHYiStoreCatoryViewController *vc = self.childViewControllers[_selectIndex];
    if (sender.selected) {
        [vc chooseAll];
    }else {
        [vc clearAll];
    }
    [self updateChooseSureBtnNummber];
}
- (void)chooseSureBtnClick:(UIButton *)sender {
    HHYiStoreCatoryViewController *vc = self.childViewControllers[_selectIndex];
    NSArray *choosedGoods = [vc choosedGoods];
    if (choosedGoods.count == 0) {
        [HTUIHelper addHUDToView:self.view withString:@"请添加商品" hideDelay:0.5];
    }
    //TODO: 提交选择的单品
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    requestInfo.URLString = CommitUrl;
    NSString *ids = @"";
    for (int i = 0; i < choosedGoods.count; i++) {
        RJBaseGoodModel *model = choosedGoods[i];
        if (!model.goodId.length) {
            continue;
        }
        if (i == choosedGoods.count - 1) {
            ids = [ids stringByAppendingString:model.goodId];
        }else {
            ids = [ids stringByAppendingString:[NSString stringWithFormat:@"%@,",model.goodId]];
        }
    }
    if (!ids.length) {
        return;
    }
    [requestInfo.postParams addEntriesFromDictionary:@{@"id": ids}];
    [[ZHNetworkManager sharedInstance] postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            if ([weakSelf.delegate respondsToSelector:@selector(yiStoreAddGoodsContollerDidFinishedChooseGoods)]) {
                [self.delegate yiStoreAddGoodsContollerDidFinishedChooseGoods];
            }
            [[HTUIHelper shareInstance] removeHUD];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }else {
            [[HTUIHelper shareInstance] removeHUDWithEndString:responseObject[@"msg"] image:nil delyTime:0.2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance] removeHUDWithEndString:@"error" image:nil delyTime:0.2];
    }];
}
- (void)filterBtnClick {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.filterViewController = [storyboard instantiateViewControllerWithIdentifier:@"FilterNavigationController"];
    FilterListViewController *vc = [self.filterViewController.viewControllers firstObject];
    /**
     *  把这个界面的筛选dic 赋值给筛选界面
     */
    vc.dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.filterDictionary mutableCopy]];
    HHYiStoreCatogeryModel *model = self.categoryArr[_selectIndex];
    if (model) {
        vc.parameterDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"classifys" : model.ID}];
    }
    vc.delegate = self;
    [vc updateFilterDic];
    [self presentViewController:self.filterViewController animated:YES completion:nil];
}
#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self resetChooseBar];
    
    NSInteger index = scrollView.contentOffset.x / kScreenWidth;
    _selectIndex = index;
    self.title = self.tabbarTitleArr[index];
    [self.filterDictionary setObject:[NSMutableArray array] forKey:@"Category"];
    
    NSArray *childs = self.childViewControllers;
    HHYiStoreCatoryViewController *vc = childs[index];
    [self.filterDictionary setObject:[NSMutableArray array] forKey:@"Category"];
    [_scrollView removeSubviews];
    vc.view.frame = CGRectMake(kScreenWidth * index, 0, kScreenWidth, _scrollView.height);
    vc.view.trackingId = [NSString stringWithFormat:@"%@&HHYiStoreCatoryViewController&index=%zd",NSStringFromClass([self class]),index];
    [[RJAppManager sharedInstance] trackingWithTrackingId:vc.view.trackingId];
    [_scrollView addSubview:vc.view];
    [_segmentedControl setSelectedSegmentIndex:index animated:YES notify:NO];
}
#pragma mark - FilterListViewDelegate
- (void)filiterDownWithDictionary:(NSMutableDictionary *)dic shouldReload:(BOOL)flag{
    
    self.filterDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (flag) {
        HHYiStoreCatoryViewController *vc = self.childViewControllers[self.selectIndex];
        vc.filterDictionary = dic;
        [vc reloadData];
    }
}
- (NSMutableArray *)categoryArr {
    if (!_categoryArr) {
        _categoryArr = [NSMutableArray array];
    }
    return _categoryArr;
}

- (NSMutableArray *)tabbarTitleArr {
    if (!_tabbarTitleArr) {
        _tabbarTitleArr = [NSMutableArray array];
    }
    return _tabbarTitleArr;
}
- (NSMutableDictionary *)filterDictionary {
    if (!_filterDictionary) {
        _filterDictionary  = [NSMutableDictionary dictionary];
        [_filterDictionary addEntriesFromDictionary:@{@"Category":[NSMutableArray array],
                                                          @"Brand":[NSMutableArray array],
                                                          @"Price":[NSMutableArray array],
                                                          @"Color":[NSMutableArray array]}];
    }
    return _filterDictionary;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
