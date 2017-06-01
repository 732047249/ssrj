
#import "CCScrollBannerView.h"
#import "RJHomeBannerModel.h"
@interface CCScrollBannerView ()<UIScrollViewDelegate>
@end

@implementation CCScrollBannerView
-(void)awakeFromNib{
    [super awakeFromNib];
    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;
}


- (void)uploadScrollBannerViewWithImageDataArray:(NSMutableArray *)dataArray{
    if (!dataArray.count) {
        return;
    }
    for (UIImageView * subImage in self.scrollView.subviews) {
        if ([subImage isKindOfClass:[UIImageView class]]) {
            [subImage removeFromSuperview];
        }
    }
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
    self.pageControl.numberOfPages = dataArray.count;
    self.pageControl.currentPage = 0;
    self.pageControl.hidden = NO;
    self.dataArray = [NSMutableArray arrayWithArray:dataArray];
    CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.frame);
    CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.frame);

    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth * (idx + 1), 0, CGRectGetWidth(self.scrollView.frame), scrollViewHeight)];//无缝滚动效果 首页是第0页 默认是从第一页开始
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.tag = idx;
        //默认传的Url
        RJHomeBannerModel *model = self.dataArray[idx];
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:model.data.path]placeholderImage:GetImage(@"640X360")];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tabGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapGesture:)];
        [imageView addGestureRecognizer:tabGesture];
        [self.scrollView addSubview:imageView];
        /**
         *  统计id
         */
        imageView.trackingId = [NSString stringWithFormat:@"%@&homeBanner&id:%d",NSStringFromClass([[[RJAppManager sharedInstance]currentViewController]class]),model.data.id.intValue];
//        NSLog(@"%@",imageView.trackingId);
//        [[RJAppManager sharedInstance]getCustomerIdentiferWihtView:imageView];
    }];
    
    //取出数组最后一个图片 放到第0页
    UIImageView *zeroImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    RJHomeBannerModel *model = self.dataArray.lastObject;
    [zeroImageView sd_setImageWithURL:[NSURL URLWithString:model.data.path] placeholderImage:GetImage(@"640X360")];
    
    zeroImageView.contentMode = UIViewContentModeScaleToFill;
    [self.scrollView addSubview:zeroImageView];
    
    //取出数组第一张图片 放到最后一页
    UIImageView *lastImageView = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth * (self.dataArray.count +1), 0, scrollViewWidth, scrollViewHeight)];
    
    RJHomeBannerModel *model2 = self.dataArray.firstObject;
    [lastImageView sd_setImageWithURL:[NSURL URLWithString:model2.data.path] placeholderImage:GetImage(@"640X360")];
    
    lastImageView.contentMode = UIViewContentModeScaleToFill;
    [self.scrollView addSubview:lastImageView];
    //原理 4-1-2-3-4-1
    //设置scrollview的可见区域
    [self.scrollView setContentSize:CGSizeMake(scrollViewWidth * (self.dataArray.count +2), scrollViewHeight)];
    [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
    
    
    [self bringSubviewToFront:self.pageControl];
    
    
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
//    for (UIView * view in self.scrollView.subviews) {
//        [[RJAppManager sharedInstance]getCustomerIdentiferWihtView:view];
//    }

}
- (void)timerAction:(NSTimer *)timer{
    if (self.scrollView.isDragging) {
        return;
    }

    CGFloat scrollWidth = self.scrollView.frame.size.width;
    NSInteger index = self.pageControl.currentPage;
    if (index == _dataArray.count + 1) {
        index = 0;
    } else {
        index ++;
    }
    [self.scrollView setContentOffset:CGPointMake((index + 1) * scrollWidth, 0) animated:YES];
    
}
- (void)scrollViewFinish:(UIScrollView *)scrollView
{
    CGFloat scrollWidth = self.scrollView.frame.size.width;
    NSInteger index = (self.scrollView.contentOffset.x + scrollWidth * 0.5) / scrollWidth;
    if (index == _dataArray.count + 1) {
        //显示最后一张的时候，强制设置为第二张（也就是轮播图的第一张），这样就开始无限循环了
        [self.scrollView setContentOffset:CGPointMake(scrollWidth, 0) animated:NO];
    } else if (index == 0) {
        //显示第一张的时候，强制设置为倒数第二张（轮播图最后一张），实现倒序无限循环
        [self.scrollView setContentOffset:CGPointMake(_dataArray.count * scrollWidth, 0) animated:NO];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self startTimer];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}
#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat scrollWidth = self.scrollView.frame.size.width;
    NSInteger index = (self.scrollView.contentOffset.x + scrollWidth * 0.5) / scrollWidth;
    if (index == _dataArray.count + 2) {
        index = 1;
    } else if (index == 0) {
        index = _dataArray.count;
    }
    self.pageControl.currentPage = index - 1;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

    [self scrollViewFinish:scrollView];

}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewFinish:scrollView];
}

- (void)imageTapGesture:(UITapGestureRecognizer *)sender{
    
    UIView *view = sender.view;
    if (view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:view.trackingId];
    }
    [self.delegate didSelectImageWithTag:sender.view.tag];
}

- (void)startTimer{
    if (self.timer) {
        [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:2]];
    }
}
- (void)stopTimer{
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}
@end
