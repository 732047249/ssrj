//
//  ImageBrowserViewController.m
//  ssrj
//
//  Created by MFD on 16/8/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ImageBrowserViewController.h"
#import "ImageBrowserFlowLayout.h"
#import "ImageBrowserCell.h"
#import "UIImage+ImageEffects.h"


#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define kPageControlHeight 40.0f
#define kImageBrowserWidth ([UIScreen mainScreen].bounds.size.width + 10.0f)
#define kImageBrowserHeight [UIScreen mainScreen].bounds.size.height
#define kCellIdentifier @"LWImageBroserCellIdentifier"
#define RGB(A,B,C,D) [UIColor colorWithRed:A/255.0f green:B/255.0f blue:C/255.0f alpha:D]

@interface ImageBrowserViewController ()
<UICollectionViewDataSource,
UICollectionViewDelegate,
UIScrollViewDelegate,
ImageItemEventDelegate>

@property (nonatomic,strong) UIImageView* screenshotImageView;
@property (nonatomic,strong) UIImageView* blurImageView;
@property (nonatomic,strong) UIImage* screenshot;
@property (nonatomic,strong) ImageBrowserFlowLayout* flowLayout;
@property (nonatomic,strong) UICollectionView* collectionView;
@property (nonatomic,strong) UIPageControl* pageControl;
@property (nonatomic,strong) UIViewController* parentVC;
@property (nonatomic,assign,getter=isFirstShow) BOOL firstShow;

@end

@implementation ImageBrowserViewController

- (id)initWithParentViewController:(UIViewController *)parentVC style:(LWImageBrowserShowAnimationStyle)style imageModels:(NSArray *)imageModels currentIndex:(NSInteger)index{
    self  = [super init];
    if (self) {
        self.parentVC = parentVC;
        self.style = style;
        self.imageModels = imageModels;
        self.currentIndex = index;
        switch (self.style) {
            case LWImageBrowserAnimationStyleScale:
                self.screenshot = [self _screenshotFromView:[UIApplication sharedApplication].keyWindow];
                self.firstShow = YES;
                break;
            default:
                self.firstShow = NO;
                break;
        }
    }
    return self;
    
}

- (void)show{
    switch (self.style) {
        case LWImageBrowserAnimationStylePush: {
            [self.parentVC.navigationController pushViewController:self animated:YES];
        }
            break;
        default: {
            [self.parentVC presentViewController:self animated:NO completion:^{}];
        }
            break;
    }
}

#pragma mark -Setter & Getter
- (ImageBrowserFlowLayout *)flowLayout{
    if (!_flowLayout) {
        _flowLayout = [[ImageBrowserFlowLayout alloc] init];
    }
    return _flowLayout;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0,0,SCREEN_WIDTH + 10.0f,self.view.bounds.size.height)
                                             collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[ImageBrowserCell class]
            forCellWithReuseIdentifier:kCellIdentifier];
    }
    return _collectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0f,
                                                                       SCREEN_HEIGHT - kPageControlHeight - 10.0f,
                                                                       SCREEN_WIDTH,
                                                                       kPageControlHeight)];
        _pageControl.numberOfPages = self.imageModels.count;
        _pageControl.currentPage = self.currentIndex;
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}

- (UIImageView *)screenshotImageView {
    if (!_screenshotImageView) {
        _screenshotImageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        _screenshotImageView.image = self.screenshot;
    }
    return _screenshotImageView;
}

- (UIImageView *)blurImageView {
    if (!_blurImageView) {
        _blurImageView = [[UIImageView alloc] initWithFrame:SCREEN_BOUNDS];
        _blurImageView.alpha = 0.0f;
    }
    return _blurImageView;
}

#pragma mark - ViewControllerLifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.screenshotImageView];
    [self.view addSubview:self.blurImageView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageControl];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage* blurImage = [self.screenshot applyBlurWithRadius:20
                                                        tintColor:RGB(0, 0, 0, 0.6)
                                            saturationDeltaFactor:1.4
                                                        maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            _blurImageView.image = blurImage;
            [UIView animateWithDuration:0.1f animations:^{
                _blurImageView.alpha = 1.0f;
            }];
        });
    });
    [self.collectionView setContentOffset:CGPointMake(self.currentIndex * (SCREEN_WIDTH + 10.0f), 0.0f) animated:NO];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.style == LWImageBrowserAnimationStyleScale) {
        //        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        //需要在plist里面设置 View controller-based status bar appearance == YES;
        [self prefersStatusBarHidden];
    }
    [self _setCurrentItem];
    self.firstShow = NO;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.imageItem.firstShow = self.isFirstShow;
    cell.imageModel = [self.imageModels objectAtIndex:indexPath.row];
    cell.imageItem.eventDelegate = self;
    return cell;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset / SCREEN_WIDTH;
    self.currentIndex = index;
    self.pageControl.currentPage = self.currentIndex;
    if (self.style == LWImageBrowserAnimationStylePush) {
        self.title = [NSString stringWithFormat:@"%ld/%ld",
                      (NSInteger)(self.collectionView.contentOffset.x / SCREEN_WIDTH) + 1,
                      self.imageModels.count];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self _setCurrentItem];
}

#pragma mark - ImageItemDelegate

- (void)didClickedItemToHide {
    if (self.style == LWImageBrowserAnimationStyleScale) {
        [self _hide];
    }
    else {
        [self _hideNavigationBar];
    }
}

- (void)didFinishRefreshThumbnailImageIfNeed {
    if ([self.delegate respondsToSelector:@selector(imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed)]
        && [self.delegate conformsToProtocol:@protocol(LWImageBrowserDelegate)]) {
        [self.delegate imageBrowserDidFnishDownloadImageToRefreshThumbnialImageIfNeed];
    }
}

#pragma mark - Private

- (void)_didClickedLeftButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)_didClickedRightButton {
    NSMutableArray* tmpArray = [[NSMutableArray alloc] initWithArray:[self.imageModels copy]];
    [tmpArray removeObjectAtIndex:self.currentIndex];
    self.imageModels = tmpArray;
    [self _setCurrentItem];
    [self.collectionView reloadData];
    if (self.style == LWImageBrowserAnimationStylePush) {
        self.title = [NSString stringWithFormat:@"%ld/%ld",
                      (NSInteger)(self.collectionView.contentOffset.x / SCREEN_WIDTH) + 1,
                      self.imageModels.count];
    }
}

- (UIImage *)_screenshotFromView:(UIView *)aView {
    UIGraphicsBeginImageContextWithOptions(aView.bounds.size,NO,[UIScreen mainScreen].scale);
    [aView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

- (void)_hide {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    __weak typeof(self) weakSelf = self;
    switch (self.style) {
        case LWImageBrowserAnimationStylePush: {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        default: {
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
            if (self.currentImageItem.zoomScale != 1.0f) {
                self.currentImageItem.zoomScale = 1.0f;
            }
            [UIView animateWithDuration:0.25f
                                  delay:0.0f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 weakSelf.blurImageView.alpha = 0.0f;
                                 weakSelf.currentImageItem.imageView.frame = weakSelf.currentImageItem.imageModel.originPosition;
                             } completion:^(BOOL finished) {
                                 [weakSelf dismissViewControllerAnimated:NO completion:^{}];
                             }];
        }
            break;
    }
}

- (void)_hideNavigationBar {
    if (self.navigationController.navigationBarHidden == NO) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        
    } else {
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)_setCurrentItem {
    NSArray* cells = [self.collectionView visibleCells];
    if (cells.count != 0) {
        ImageBrowserCell* cell = [cells objectAtIndex:0];
        if (self.currentImageItem != cell.imageItem) {
            self.currentImageItem = cell.imageItem;
            [self _preDownLoadImageWithIndex:self.currentIndex];
        }
    }
}

/**
 *  预加载当前Index的前后两张图片
 *
 *  @param index 当前的Index
 */
- (void)_preDownLoadImageWithIndex:(NSInteger)index {
    SDWebImageManager* manager = [SDWebImageManager sharedManager];
    if (index + 1 < self.imageModels.count) {
        DetailImageBrowsweModel* nextModel = [self.imageModels objectAtIndex:index + 1];
        [manager downloadImageWithURL:nextModel.HDURL
                              options:0
                             progress:nil
                            completed:^(UIImage *image,
                                        NSError *error,
                                        SDImageCacheType cacheType,
                                        BOOL finished,
                                        NSURL *imageURL) {}];
    }
    if (index - 1 >= 0) {
        DetailImageBrowsweModel* previousModel = [self.imageModels objectAtIndex:index - 1];
        [manager downloadImageWithURL:previousModel.HDURL
                              options:0
                             progress:nil
                            completed:^(UIImage *image,
                                        NSError *error,
                                        SDImageCacheType cacheType,
                                        BOOL finished,
                                        NSURL *imageURL) {}];
    }
}


@end
