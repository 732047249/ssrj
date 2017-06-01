//
//  RJCategoryViewController.m
//  ssrj
//
//  Created by MFD on 16/5/25.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJCategoryViewController.h"
#import "SegementScrollView.h"
#import "CollectionViewCell.h"
#import "A-Z_brandsTableVIew.h"
#import "categoryTableViewCell.h"
#import "Masonry.h"
#import "SegmentView.h"
#import "HMSegmentedControl.h"
#import "CategoryFenLeiViewController.h"
#import "CategoryPinPaiViewController.h"

#define MFDWIDTH     [UIScreen mainScreen].bounds.size.width
#define KHEIGHT    [UIScreen mainScreen].bounds.size.height

//头部索引背景颜色
#define topBGCOLO [UIColor colorWithHexString:@"#190d31"]

//头部标题选中颜色
#define titleSelectedColor [UIColor colorWithHexString:@"#ffffff"]

//头部标题未选中颜色
#define titleNormalColor [UIColor colorWithHexString:@"#6c6876"]

@interface RJCategoryViewController()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>
@property (nonatomic,strong)HMSegmentedControl *topPageController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;
@property (strong, nonatomic) NSMutableArray * pages;
@property (weak,nonatomic)UIScrollView *pageScrollView;
@end

@implementation RJCategoryViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    if ([RJAppManager sharedInstance].didClickHomeBrand) {
        [self.topPageController setSelectedSegmentIndex:1 animated:NO];
        [RJAppManager sharedInstance].didClickHomeBrand = NO;
    }

}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewDidLoad{
    
    UIView *topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, MFDWIDTH, 64)];
    topBgView.backgroundColor = topBGCOLO;
    [self.view addSubview:topBgView];
    
    self.topPageController = [[HMSegmentedControl alloc]initWithSectionTitles:@[@"分类",@"品牌"]];
    self.topPageController.backgroundColor = topBGCOLO;
    self.topPageController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.topPageController.selectedTitleTextAttributes = @{
                                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                                           NSForegroundColorAttributeName:titleSelectedColor
                                                           };
    self.topPageController.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.topPageController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.topPageController.selectionIndicatorColor = [UIColor colorWithHexString:@"#6225de"];
    self.topPageController.selectionIndicatorHeight = 3.0f;
    self.topPageController.frame = CGRectMake(0, 20, self.view.width, 44);
    self.topPageController.userDraggable = YES;
    
    [self.view addSubview:_topPageController];
    
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.view.frame = self.contentContainer.bounds;
//    self.pageViewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-69);
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
    [self.pageViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self addChildViewController:self.pageViewController];
    [self.contentContainer addSubview:self.pageViewController.view];
    self.contentContainer.backgroundColor = [UIColor whiteColor];
    [self.topPageController addTarget:self
                               action:@selector(pageControlValueChanged:)
                     forControlEvents:UIControlEventValueChanged];
    
    [self setupViewControllers];
}

- (void)setupViewControllers{
    NSMutableArray *pages = [NSMutableArray new];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    CategoryFenLeiViewController *fenlei = [storyBoard instantiateViewControllerWithIdentifier:@"CategoryFenLeiViewController"];
    CategoryPinPaiViewController *pinpai = [storyBoard instantiateViewControllerWithIdentifier:@"CategoryPinPaiViewController"];
    [pages addObject:fenlei];
    [pages addObject:pinpai];
    
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

-(NSMutableArray *)pages{
    if (!_pages) {
        _pages = [[NSMutableArray alloc]init];
    }
    return _pages;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
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

@end
