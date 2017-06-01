//
//  MFDMineOrdersViewController.m
//  ssrj
//
//  Created by LiHaoFeng on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDMineOrdersViewController.h"
#import "HMSegmentedControl.h"
#import "MFDAllOrdersViewController.h"
#import "MFDWaitPayViewController.h"
#import "MFDWaitSendViewController.h"
#import "MFDWaitReceiveViewController.h"
#import "MFDServiceViewController.h"


@interface MFDMineOrdersViewController()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic,strong)HMSegmentedControl *topPageController;
@property (nonatomic,strong)UIPageViewController *pageViewController;
//pageViewController -pages
@property (nonatomic,strong)NSMutableArray *pages;
@property (nonatomic,strong)UIScrollView *pageScrollView;

@end


@implementation MFDMineOrdersViewController

- (NSMutableArray *)pages{
    if (!_pages) {
        _pages = [[NSMutableArray alloc]init];
    }
    return _pages;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];

}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setTitle:@"我的订单" tappable:NO];
    [self addBackButton];
    
    NSArray *titles = @[@"全部",@"待付款",@"待收货",@"已完成",@"售后"];
    self.topPageController = [[HMSegmentedControl alloc]initWithSectionTitles:titles];
    self.topPageController.frame = CGRectMake(0, 0, SCREEN_WIDTH, 37);
    self.topPageController.backgroundColor = [UIColor whiteColor];
    
    self.topPageController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor blackColor]};
    self.topPageController.selectedTitleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#5d32b5"]};
    self.topPageController.selectionIndicatorColor = [UIColor colorWithHexString:@"#5d32b5"];
    
    self.topPageController.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.topPageController.selectionIndicatorHeight = 2.0f;
    self.topPageController.userDraggable = YES;
    self.topPageController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    
    [self.view addSubview:_topPageController];
    
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.view.frame = self.containerView.bounds;
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
    [self.pageViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self addChildViewController:self.pageViewController];
    [self.containerView addSubview:self.pageViewController.view];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.topPageController addTarget:self
                               action:@selector(pageControlValueChanged:)
                     forControlEvents:UIControlEventValueChanged];
    
    [self setupViewControllers];
}

- (void)setupViewControllers{
    NSMutableArray *page = [NSMutableArray new];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    
    MFDAllOrdersViewController *mineOrders = [sb instantiateViewControllerWithIdentifier:@"MFDAllOrdersViewController"];
    MFDWaitPayViewController *waitPay = [sb instantiateViewControllerWithIdentifier:@"MFDWaitPayViewController"];
    MFDWaitSendViewController *waitSend = [sb instantiateViewControllerWithIdentifier:@"MFDWaitSendViewController"];
    MFDWaitReceiveViewController *waitReceive = [sb instantiateViewControllerWithIdentifier:@"MFDWaitReceiveViewController"];
    MFDServiceViewController *service = [sb instantiateViewControllerWithIdentifier:@"MFDServiceViewController"];
    
    [page addObject:mineOrders];
    [page addObject:waitPay];
    [page addObject:waitReceive];
    [page addObject:waitSend];
    [page addObject:service];
    
    [self setPages:page];
    
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


#pragma  mark -Callback

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





@end
