//
//  MineSingleViewController.m
//  ssrj
//
//  Created by YiDarren on 16/8/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MineSingleViewController.h"
#import "HMSegmentedControl.h"
#import "MineFollowedSingleGoodViewController.h"
#import "MineBoughtGoodsViewController.h"
#import "MineFavoriteGoodsListCollectionViewCell.h"
#import "MineBoughtGoodsCollectionViewCell.h"
#import "CartViewController.h"

@interface MineSingleViewController ()<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate,MineBoughtGoodsCollectionViewCellDelegate, MineFavoriteGoodsListCollectionViewCellDelegate>
@property (strong, nonatomic) HMSegmentedControl *topPageController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) UIScrollView *pageScrollView;
@property (strong, nonatomic) NSMutableArray *pages;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@end

@implementation MineSingleViewController

//MineFavoriteGoodsListCollectionViewCellDelegate暂未用上
- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    [self setTitle:@"收藏的单品" tappable:NO];
    NSArray *btnArray = @[@1];
    [self addBarButtonItems:btnArray onSide:RJNavRightSide];
    
    self.topPageController = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"收藏", @"已购买"]];
    self.topPageController.backgroundColor = [UIColor whiteColor];
    self.topPageController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#c6c6c6"]};
    self.topPageController.selectedTitleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:15], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#5d32b5"]};
    
    self.topPageController.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.topPageController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.topPageController.selectionIndicatorColor = [UIColor colorWithHexString:@"#5d32b5"];
    self.topPageController.selectionIndicatorHeight = 2.0f;
    self.topPageController.frame = CGRectMake(0, 0, self.view.width, 39);
    
    UILabel *lineLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
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
    [self.contentContainer addSubview:self.pageViewController.view];//竟然弄丢了，卧槽
    self.contentContainer.backgroundColor = [UIColor whiteColor];
    [self.topPageController addTarget:self action:@selector(pageControlValueChanged:) forControlEvents:UIControlEventValueChanged];

    [self setupViewControllers];

}

- (void)cartButtonClickedButton {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CartViewController *vc = [story instantiateViewControllerWithIdentifier:@"CartViewController"];
    [self.navigationController pushViewController:vc animated:YES];

}


- (void)setupViewControllers{
    NSMutableArray *pages = [NSMutableArray new];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    MineFollowedSingleGoodViewController *followedVC = [storyBoard instantiateViewControllerWithIdentifier:@"MineFollowedSingleGoodViewController"];
    
//    followedVC.delegate = self;
//    followedVC.selectId = self.choseId;
    
    MineBoughtGoodsViewController * boughtVC = [storyBoard instantiateViewControllerWithIdentifier:@"MineBoughtGoodsViewController"];
    
    [pages addObject:followedVC];
    [pages addObject:boughtVC];
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
