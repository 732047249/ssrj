//
//  HHSelecteGoodsOrMatchController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHSelecteGoodsOrMatchController.h"
#import "HHInforGoodsController.h"
#import "HHInforMatchController.h"
#import "HMSegmentedControl.h"
@interface HHSelecteGoodsOrMatchController ()<UIScrollViewDelegate>
@property (nonatomic,strong)HMSegmentedControl *segmentBar;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (strong,nonatomic)NSMutableArray *controllerArray;
@end

@implementation HHSelecteGoodsOrMatchController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _controllerArray = [NSMutableArray array];
    self.title = @"插入单品或搭配";
    [self addBackButton];
    [self.view addSubview:self.segmentBar];
    [self configScrollView];
    [self configViewControllers];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
- (void)configScrollView {
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, kScreenHeight - 64 - 40)];
    _scrollView.bounces = NO;
    _scrollView.contentSize = CGSizeMake(kScreenWidth * 2, _scrollView.bounds.size.height);
    _scrollView.delegate = self;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
}
- (void)configViewControllers{
    
    HHInforGoodsController *goods = [[HHInforGoodsController alloc] init];
    HHInforMatchController *match = [[HHInforMatchController alloc] init];
    [self addChildViewController:goods];
    [self addChildViewController:match];
    goods.view.frame = CGRectMake(0, 0, _scrollView.width, _scrollView.height);
    goods.view.trackingId = [NSString stringWithFormat:@"HHSelecteGoodsOrMatchController&index=0"];
    [[RJAppManager sharedInstance] trackingWithTrackingId:goods.view.trackingId];
    [_scrollView addSubview:goods.view];
    
    _controllerArray = [NSMutableArray arrayWithArray:@[goods,match]];
    
}

#pragma mark - scrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / scrollView.bounds.size.width;
    [self.segmentBar setSelectedSegmentIndex:page animated:YES];
    UIViewController *controll = _controllerArray[page];
    if (![_scrollView.subviews containsObject:controll.view]) {
        
        controll.view.frame = CGRectMake(page * kScreenWidth, 0, _scrollView.width, _scrollView.height);
        controll.view.trackingId = [NSString stringWithFormat:@"HHSelecteGoodsOrMatchController&index=%zd",page];
        [_scrollView addSubview:controll.view];
    }
    [[RJAppManager sharedInstance] trackingWithTrackingId:controll.view.trackingId];
}

#pragma mark - get
- (HMSegmentedControl *)segmentBar {
    if (!_segmentBar) {
        _segmentBar = [[HMSegmentedControl alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
        _segmentBar.sectionTitles = @[@"单品",@"搭配"];
        [_segmentBar setTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17], NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#cccccc"]}];
        [_segmentBar setSelectedTitleTextAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17], NSForegroundColorAttributeName : APP_BASIC_COLOR2}];
        _segmentBar.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
        _segmentBar.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
        _segmentBar.selectionIndicatorHeight = 2;
        _segmentBar.backgroundColor = [UIColor whiteColor];
        _segmentBar.selectionIndicatorEdgeInsets = UIEdgeInsetsMake(0, -10, 0, -20);
        [_segmentBar setSelectionIndicatorColor:APP_BASIC_COLOR2];
        __weak __typeof(&*self)weakSelf = self;
        [_segmentBar setIndexChangeBlock:^(NSInteger index) {
            
            [weakSelf.scrollView scrollRectToVisible:CGRectMake(kScreenWidth * index, 0, kScreenWidth, weakSelf.scrollView.bounds.size.height) animated:YES];
            UIViewController *control = weakSelf.controllerArray[index];
            if (![weakSelf.scrollView.subviews containsObject:control.view]) {
                
                control.view.frame = CGRectMake(index * kScreenWidth, 0, weakSelf.scrollView.width, weakSelf.scrollView.height);
                control.view.trackingId = [NSString stringWithFormat:@"HHSelecteGoodsOrMatchController&index=%zd",index];
                [weakSelf.scrollView addSubview:control.view];
            }
            [[RJAppManager sharedInstance] trackingWithTrackingId:control.view.trackingId];
        }];
        
    }
    return _segmentBar;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
