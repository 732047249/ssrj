//
//  SearchDetailViewController.m
//  ssrj
//
//  Created by YiDarren on 16/9/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "SearchDetailForTopic.h"
#import "SearchDetailForHeji.h"
#import "SearchDetailForDaPei.h"
#import "SearchDetailForSingleGoods.h"
#import "HMSegmentedControl.h"
#import "RJDiscoveryThemeViewController.h"

@interface SearchDetailViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIScrollViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) HMSegmentedControl *topPageController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIScrollView *pageScrollView;
@property (strong, nonatomic) NSMutableArray *pages;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;
@property (strong, nonatomic) UILabel *inputLabel;
@property (strong, nonatomic) UIButton *inputFieldButton;


@end

@implementation SearchDetailViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
    //本UI返回,清空搜索输入框内容，防止点击进来传值被覆盖
    self.inputLabel.text = _inputLabel.text;

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    //自定义navigationView
    UIView *navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH-60, 32)];
    navView.layer.cornerRadius = 5;
    navView.layer.masksToBounds = YES;
    navView.backgroundColor = [UIColor colorWithHexString:@"#EFEFF4"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_icon2"]];
    imageView.frame = CGRectMake(6, 6, 20, 20);
    [navView addSubview:imageView];
    
    
    //文本输入框
    _inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(32, 0, SCREEN_WIDTH-60-32, 32)];
    _inputLabel.text = _searchWords;
    _inputLabel.textColor = [UIColor darkGrayColor];
    [_inputLabel setFont:[UIFont systemFontOfSize:15]];
    [navView addSubview:_inputLabel];

    
    //button位于文本输入框的上层
    _inputFieldButton = [[UIButton alloc] initWithFrame:CGRectMake(32, 0, SCREEN_WIDTH-60-32, 32)];
    [navView addSubview:_inputFieldButton];
    [_inputFieldButton addTarget:self action:@selector(inputWordsAction) forControlEvents:UIControlEventTouchDown];
    
    
    //cancel按钮
    self.navigationItem.titleView = navView;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonClicked)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    

    self.topPageController = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"单品", @"搭配", @"合辑", @"资讯"]];
    self.topPageController.backgroundColor = [UIColor whiteColor];
    self.topPageController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#c6c6c6"]};
    self.topPageController.selectedTitleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#5d32b5"]};
    
    self.topPageController.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.topPageController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.topPageController.selectionIndicatorColor = [UIColor colorWithHexString:@"#5d32b5"];
    self.topPageController.selectionIndicatorHeight = 2.0f;
    self.topPageController.frame = CGRectMake(0, 0, self.view.width, 44);
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, 1)];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    self.topPageController.userDraggable = YES;
    
    [self.view addSubview:_topPageController];
    [self.view addSubview:lineLabel];
    
    //添加隔离线
    UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4.0, 0, 1, 44)];
    leftLine.backgroundColor = [UIColor colorWithHexString:@"#E5E5E5"];
    
    UIView *middleLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2.0, 0, 1, 44)];
    middleLine.backgroundColor = [UIColor colorWithHexString:@"#E5E5E5"];
    
    UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4.0, 0, 1, 44)];
    rightLine.backgroundColor = [UIColor colorWithHexString:@"#E5E5E5"];
    
    [self.view addSubview:leftLine];
    [self.view addSubview:middleLine];
    [self.view addSubview:rightLine];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.view.frame = self.contentContainer.bounds;
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
    [self.pageViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    
    [self addChildViewController:self.pageViewController];
    [self.contentContainer addSubview:self.pageViewController.view];//竟然弄丢了，卧槽
    self.contentContainer.backgroundColor = [UIColor whiteColor];
    [self.topPageController addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    [self setupViewControllers];
    
}

#pragma mark - 取消按钮
- (void)cancelButtonClicked {
    //本UI返回,清空搜索输入框内容，防止点击进来传值被覆盖
    self.inputLabel.text = @"";
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)setupViewControllers{
    NSMutableArray *pages = [NSMutableArray new];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    SearchDetailForSingleGoods *followedVC = [storyBoard instantiateViewControllerWithIdentifier:@"SearchDetailForSingleGoods"];
    followedVC.searchWord = _searchWords;
    
    SearchDetailForDaPei *releaseVC = [storyBoard instantiateViewControllerWithIdentifier:@"SearchDetailForDaPei"];
    releaseVC.searchWord = _searchWords;
    
    SearchDetailForHeji *heJiVC = [storyBoard instantiateViewControllerWithIdentifier:@"SearchDetailForHeji"];
    heJiVC.searchWord = _searchWords;
    
    SearchDetailForTopic *topicVC = [storyBoard instantiateViewControllerWithIdentifier:@"SearchDetailForTopic"];
    topicVC.searchWord = _searchWords;
    
//    RJDiscoveryThemeViewController *heJiVC = [storyBoard instantiateViewControllerWithIdentifier:@"RJDiscoveryThemeViewController"];
    
    
    [pages addObject:followedVC];
    [pages addObject:releaseVC];
    [pages addObject:heJiVC];
    [pages addObject:topicVC];
    [self setPages:pages];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView =(UIScrollView *)view;
            _pageScrollView.delegate = self;
            _pageScrollView.scrollEnabled = YES;
            _pageScrollView.scrollsToTop = NO;
        }
    }
    if ([self.pages count]>0) {
        [self.topPageController setSelectedSegmentIndex:0 animated:YES];
        [self.pageViewController setViewControllers:@[self.pages[0]]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
    }
    
}

#pragma mark --UITextFieldDelegate
- (void)inputWordsAction {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}


#pragma mark - Callback
- (void)pageControlValueChanged:(id)sender
{
    
    UIPageViewControllerNavigationDirection direction = [self.topPageController selectedSegmentIndex] > [self.pages indexOfObject:[self.pageViewController.viewControllers lastObject]] ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [self.pageViewController setViewControllers:@[[self selectedController]]
                                      direction:direction
                                       animated:YES
                                     completion:NULL];
    
}

- (UIViewController *)selectedController
{
    return self.pages[[self.topPageController selectedSegmentIndex]];
}

- (void)setSelectedPageIndex:(NSUInteger)index animated:(BOOL)animated {
    if (index < [self.pages count]) {
        [self.topPageController setSelectedSegmentIndex:index animated:YES];
        [self.pageViewController setViewControllers:@[self.pages[index]]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:animated
                                         completion:NULL];
        
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    //    NSLog(@"%@",NSStringFromCGPoint(scrollView.contentOffset));
    
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pages indexOfObject:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    return self.pages[--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pages indexOfObject:viewController];
    
    if ((index == NSNotFound)||(index+1 >= [self.pages count])) {
        return nil;
    }
    
    return self.pages[++index];
}

- (void)pageViewController:(UIPageViewController *)viewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed){
        return;
    }
    [self.topPageController setSelectedSegmentIndex:[self.pages indexOfObject:[viewController.viewControllers lastObject]] animated:YES];
}
-(NSMutableArray *)pages{
    if (!_pages) {
        _pages = [[NSMutableArray alloc]init];
    }
    return _pages;
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
