
#import "ChoseCouponViewController.h"
#import "EnableCouponViewController.h"
#import "UnableCouponViewController.h"
#import "HMSegmentedControl.h"
@interface ChoseCouponViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate,EnableCouponDelegate>
@property (strong, nonatomic) HMSegmentedControl * topPageController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIScrollView * pageScrollView;
@property (strong, nonatomic) NSMutableArray * pages;
@property (weak, nonatomic)  IBOutlet UIView *contentContainer;

@end

@implementation ChoseCouponViewController

- (void)viewDidLoad{
    [super viewDidLoad];
//    [self addBackButton];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, 60, 30);
    [button setTitle:@"完成" forState:0];
    button.titleLabel.font = GetFont(15);
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    [self setTitle:@"使用现金券" tappable:NO];
    self.topPageController = [[HMSegmentedControl alloc]initWithSectionTitles:@[@" 可使用 ",@" 不可使用"]];
    self.topPageController.backgroundColor = [UIColor whiteColor];
    self.topPageController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#c6c6c6"]};
    self.topPageController.selectedTitleTextAttributes = @{
                                                           NSFontAttributeName: [UIFont systemFontOfSize:15],
                                                           NSForegroundColorAttributeName: [UIColor blackColor]
                                                           };
    self.topPageController.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.topPageController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.topPageController.selectionIndicatorColor = [UIColor colorWithHexString:@"#5d32b5"];
    self.topPageController.selectionIndicatorHeight = 2.0f;
    self.topPageController.frame = CGRectMake(0, 0, self.view.width, 35);
    UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH, 1)];
    lineLabel.backgroundColor = [UIColor colorWithHexString:@"#efefef"];

    self.topPageController.userDraggable = YES;
    
    [self.view addSubview:_topPageController];
    [self.view addSubview:lineLabel];
    
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.view.frame = self.contentContainer.bounds;
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
    
    EnableCouponViewController *enableVc = [storyBoard instantiateViewControllerWithIdentifier:@"EnableCouponViewController"];
    
    enableVc.delegate = self;
    enableVc.selectId = self.choseId;
    enableVc.cartItemIds = self.cartItemIds;
    UnableCouponViewController * unableVc = [storyBoard instantiateViewControllerWithIdentifier:@"UnableCouponViewController"];
    unableVc.cartItemIds = self.cartItemIds;
    [pages addObject:enableVc];
    [pages addObject:unableVc];
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
#pragma  mark - Delegate回调
- (void)choseCouponWithModel:(RJCouPonModel *)model{
    if (self.delegate && [self.delegate respondsToSelector:@selector(updateOrderWithModel:)]) {
        [self.delegate updateOrderWithModel:model];
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
