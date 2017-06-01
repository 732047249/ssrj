//
//  DiscoveryViewController.m
//  ssrj
//
//  Created by MFD on 16/6/28.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "HMSegmentedControl.h"
#import "RJDiscoveryMatchViewController.h"
#import "RJDiscoveryThemeViewController.h"

//头部索引背景颜色
#define topBGCOLO [UIColor colorWithHexString:@"#190d31"]
//头部标题选中颜色
#define titleSelectedColor [UIColor colorWithHexString:@"#ffffff"]
//头部标题未选中颜色
#define titleNormalColor [UIColor colorWithHexString:@"#ffffff"]


@interface DiscoveryViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property (nonatomic,strong)HMSegmentedControl *topPageController;
@property (nonatomic,strong)UIPageViewController *pageViewController;
@property (nonatomic,strong)NSMutableArray *pages;

@property (nonatomic,strong)UIScrollView *pageScrollView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation DiscoveryViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    topBgView.backgroundColor = topBGCOLO;
    [self.view addSubview:topBgView];
    
    self.topPageController = [[HMSegmentedControl alloc]initWithSectionTitles:@[@"搭配",@"主题"]];
    self.topPageController.backgroundColor = topBGCOLO;
    self.topPageController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:titleSelectedColor};
    self.topPageController.selectedTitleTextAttributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:18    ],NSForegroundColorAttributeName:titleSelectedColor};
    self.topPageController.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.topPageController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.topPageController.selectionIndicatorColor = [UIColor colorWithHexString:@"#6225de"];
    self.topPageController.selectionIndicatorHeight = 3.0f;
    self.topPageController.frame = CGRectMake(0, 20, SCREEN_WIDTH, 44);
    self.topPageController.userDraggable = YES;
    [self.view addSubview:_topPageController];
    
    self.pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageViewController.view.frame = self.containerView.bounds;
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
    [self.pageViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self addChildViewController:self.pageViewController];
    [self.containerView addSubview:self.pageViewController.view];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.topPageController addTarget:self action:@selector(pageControlValueChanged) forControlEvents:UIControlEventValueChanged];
    
    [self setupViewControllers];
}

- (void)pageControlValueChanged{
    
    UIPageViewControllerNavigationDirection direction = [self.topPageController selectedSegmentIndex] > [self.pages indexOfObject:[self.pageViewController.viewControllers lastObject]] ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [self.pageViewController setViewControllers:@[[self selectedController]]
                                      direction:direction
                                       animated:YES
                                     completion:NULL];
}

- (void)setupViewControllers{
    NSMutableArray *pages = [NSMutableArray new];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RJDiscoveryMatchViewController *macthVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJDiscoveryMatchViewController"];
    RJDiscoveryThemeViewController *themeVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJDiscoveryThemeViewController"];
    [pages addObject:macthVc];
    [pages addObject:themeVc];
    [self setPages:pages];
    if (self.pages.count > 0) {
        [self.topPageController setSelectedSegmentIndex:0 animated:YES];
        [self.pageViewController setViewControllers:@[self.pages[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
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


@end
