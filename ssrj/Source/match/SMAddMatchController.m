//
//  SMAddMatchController.m
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "SMAddMatchController.h"
#import "SMAllGoodsViewController.h"
#import "SMMyGoodsController.h"
#import "SMSourceController.h"

#import "SMAllGoodsAndSourceModel.h"

#import "Masonry.h"
#define MFDWIDTH     [UIScreen mainScreen].bounds.size.width
#define KHEIGHT    [UIScreen mainScreen].bounds.size.height


//头部标题选中颜色
#define titleSelectedColor [UIColor colorWithHexString:@"#ffffff"]

//头部标题未选中颜色
#define titleNormalColor [UIColor colorWithHexString:@"#6c6876"]

#define KTopBarHeight 44

@interface SMAddMatchController ()<UIScrollViewDelegate>
@property (strong,nonatomic)UIScrollView *scrollView;
@property (strong,nonatomic)NSMutableArray *controllerArray;
@property (strong,nonatomic)UIView *navBar;

@end

@implementation SMAddMatchController


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    _controllerArray = [NSMutableArray array];
    [self configNavBar];
    [self setupScrollView];
    [self setupViewControllers];
    [self addNotification];
}
- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidScrollNotification:) name:@"ControllerScrollNotification" object:nil];
}

- (void)controllerDidScrollNotification:(NSNotification *)notification {
    NSString *stateString = notification.object;
    if ([stateString isEqualToString:@"top"]) {
        [UIView animateWithDuration:0.3 animations:^{
            _navBar.frame = CGRectMake(0, 0, kScreenWidth, 64);
            _scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.navBar.frame), kScreenWidth, _scrollView.height);
        } completion:^(BOOL finished) {
            [self.switchBtn setImage:[UIImage imageNamed:@"match_jiantou2"] forState:UIControlStateNormal];
            _navBar.backgroundColor = APP_BASIC_COLOR;
            self.segmentedControl.selectedTitleTextAttributes = @{
                                                                  NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                                  NSForegroundColorAttributeName:titleSelectedColor
                                                                  };
            
            self.segmentedControl.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor whiteColor]};
            self.segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#ffffff"];
            [self.segmentedControl setNeedsDisplay];
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            _navBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
            _scrollView.frame = CGRectMake(0, CGRectGetMaxY(self.navBar.frame), kScreenWidth, _scrollView.height);
        } completion:^(BOOL finished) {
            [self.switchBtn setImage:[UIImage imageNamed:@"match_jiantou1"] forState:UIControlStateNormal];
            _navBar.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
            self.segmentedControl.selectedTitleTextAttributes = @{
                                                                  NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                                  NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#5d32b5"]
                                                                  };
            
            self.segmentedControl.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]};
            self.segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#5d32b5"];
            [self.segmentedControl setNeedsDisplay];
        }];
    }
}
#pragma mark - UI
- (void)configNavBar {
    
    _navBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, KTopBarHeight)];
    _navBar.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
    [self.view addSubview:_navBar];
    
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setImage:[UIImage imageNamed:@"match_jiantou1"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(switchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _switchBtn = backBtn;
    [_navBar addSubview:backBtn];
    [backBtn sizeToFit];
    CGFloat width = backBtn.bounds.size.width;
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_navBar);
        make.left.equalTo(_navBar).offset(13);
        make.height.mas_offset(44);
        make.width.mas_equalTo(width);
    }];
    
    self.segmentedControl = [[HMSegmentedControl alloc] init];
    self.segmentedControl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    self.segmentedControl.sectionTitles = @[@"所有单品",@"我的单品",@"素材"];
    self.segmentedControl.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor blackColor]};
    self.segmentedControl.selectedTitleTextAttributes = @{
                                                          NSFontAttributeName: [UIFont boldSystemFontOfSize:16],
                                                          NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#5d32b5"]
                                                          };
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.selectionIndicatorColor = [UIColor colorWithHexString:@"#5d32b5"];
    self.segmentedControl.selectionIndicatorHeight = 1.0f;
    self.segmentedControl.userDraggable = NO;
    
    __weak typeof(self) weakSelf = self;
    [self.segmentedControl setIndexChangeBlock:^(NSInteger index) {
        
        if (index == 1) {
            //判断用户是否登录
            if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
                
                [weakSelf presentViewController:loginNav animated:YES completion:^{
                    if (weakSelf.scrollView.contentOffset.x < 30) {
                        [weakSelf.segmentedControl setSelectedSegmentIndex:0];
                    }else {
                        [weakSelf.segmentedControl setSelectedSegmentIndex:2];
                    }
                }];
                return;
            }
        }
        
        [weakSelf.scrollView scrollRectToVisible:CGRectMake(kScreenWidth * index, 0, kScreenWidth, kScreenHeight - KTopBarHeight) animated:YES];
        UIViewController *control = weakSelf.controllerArray[index];
        if (![weakSelf.scrollView.subviews containsObject:control.view]) {
            
            control.view.frame = CGRectMake(index * kScreenWidth, 0, weakSelf.scrollView.width, weakSelf.scrollView.height);
            control.view.trackingId = [NSString stringWithFormat:@"SMAddMatchController&subViewController&index=%zd",index];
            [weakSelf.scrollView addSubview:control.view];
        }
        [[RJAppManager sharedInstance] trackingWithTrackingId:control.view.trackingId];
    }];
    [_navBar addSubview:_segmentedControl];
    [_segmentedControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(_navBar);
        make.left.equalTo(backBtn.mas_right);
        make.height.mas_offset(30);
        make.centerY.equalTo(_switchBtn);
    }];
    
    backBtn.trackingId = [NSString stringWithFormat:@"SMAddMatchController&backBtn"];
}
- (void)setupScrollView {
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navBar.frame), kScreenWidth, kScreenHeight - 64)];
    _scrollView.contentSize = CGSizeMake(kScreenWidth * 3, kScreenHeight - 64);
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
}
- (void)setupViewControllers{
    
    SMAllGoodsViewController *allgoods = [[SMAllGoodsViewController alloc] init];
    SMMyGoodsController *mygoods = [[SMMyGoodsController alloc] init];
    SMSourceController *source = [[SMSourceController alloc]init];
    [self addChildViewController:allgoods];
    [self addChildViewController:mygoods];
    [self addChildViewController:source];
    allgoods.view.frame = CGRectMake(0, 0, _scrollView.width, _scrollView.height);
    allgoods.view.trackingId = [NSString stringWithFormat:@"SMAddMatchController&subViewController&index=0"];
    [[RJAppManager sharedInstance] trackingWithTrackingId:allgoods.view.trackingId];
    [_scrollView addSubview:allgoods.view];
    
    _controllerArray = [NSMutableArray arrayWithArray:@[allgoods,mygoods,source]];
    
}
#pragma mark - event
- (void)switchBtnClick{
    if (self.switchBlock) {
        self.switchBlock();
    }
}
#pragma mark - scrollViewdelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    if (page == 1) {
        //判断用户是否登录
        if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            __weak __typeof(&*self)weakSelf = self;
            [self presentViewController:loginNav animated:YES completion:^{
                [weakSelf.scrollView scrollRectToVisible:CGRectMake(kScreenWidth * weakSelf.segmentedControl.selectedSegmentIndex, 0, kScreenWidth, kScreenHeight - KTopBarHeight) animated:NO];
            }];
            return;
        }
    }
    [_segmentedControl setSelectedSegmentIndex:page animated:YES];
    UIViewController *controll = _controllerArray[page];
    if (![_scrollView.subviews containsObject:controll.view]) {

        controll.view.frame = CGRectMake(page * kScreenWidth, 0, _scrollView.width, _scrollView.height);
        [_scrollView addSubview:controll.view];
        controll.view.trackingId = [NSString stringWithFormat:@"SMAddMatchController&subViewController&index=%zd",page];
    }
    [[RJAppManager sharedInstance] trackingWithTrackingId:controll.view.trackingId];
}

@end
