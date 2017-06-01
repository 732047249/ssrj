//
//  SMGoodsDetailScrollView.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMGoodsDetailScrollView.h"
#import "RJGoodDetailModel.h"
#import "Masonry.h"

#import <MediaPlayer/MediaPlayer.h>
@interface SMGoodsDetailScrollView ()<UIScrollViewDelegate>{
    NSMutableArray *_imageViews;
}
@property (assign, nonatomic) BOOL  hasVideo;
@property (nonatomic,strong) MPMoviePlayerController *mpPlayer;

@end
@implementation SMGoodsDetailScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.delegate = self;
//        _scrollView.bounces = YES;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = APP_BASIC_COLOR;
        _pageControl.pageIndicatorTintColor = [UIColor grayColor];
        [self addSubview:_pageControl];
        
        [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.bottom.equalTo(self);
            make.height.mas_equalTo(37);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playbackstateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playDidFinish:) //媒体播放完成或用户手动退出，具体完成原因可以通过通知userInfo中的key为MPMoviePlayerPlaybackDidFinishReasonUserInfoKey的对象获取
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:nil];
    }
    return self;
}
- (void)uploadScrollBannerViewWithDataArray:(NSMutableArray *)dataArray{
    if (!dataArray.count) {
        return;
    }
    for (UIImageView * subImage in self.scrollView.subviews) {
        if ([subImage isKindOfClass:[UIImageView class]]) {
            [subImage removeFromSuperview];
        }
    }
    //    if (self.timer) {
    //        [self.timer setFireDate:[NSDate distantFuture]];
    //    }
    
    
    self.hasVideo = NO;
    //播放按钮
    __weak __typeof(&*self)weakSelf = self;
    UIButton *btn = [[UIButton alloc]init];
    [btn setImage:[UIImage imageNamed:@"bofang_2"] forState:UIControlStateNormal];
    [self.superview addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(weakSelf.pageControl.mas_centerY);
        //        make.right.mas_equalTo(weakSelf.pageControl.mas_right).offset(2);
        make.left.mas_equalTo(weakSelf.pageControl.mas_left);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(10);
    }];
    btn.hidden = YES;
    
    self.pageControl.numberOfPages = dataArray.count;
    self.pageControl.currentPage = 0;
    self.pageControl.hidden = NO;
    self.dataArray = [NSMutableArray arrayWithArray:dataArray];
    CGFloat scrollViewWidth = CGRectGetWidth(self.scrollView.frame);
    CGFloat scrollViewHeight = CGRectGetHeight(self.scrollView.frame);
    
    _imageViews = [NSMutableArray array];
    
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth * (idx + 1), 0, CGRectGetWidth(self.scrollView.frame), scrollViewHeight)];//无缝滚动效果 首页是第0页 默认是从第一页开始
        imageView.contentMode = UIViewContentModeScaleToFill;
        //        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = idx;
        //默认传的Url
        RJGoodDetailProductImagesModel *model = self.dataArray[idx];
        if (model.videoPath.length) {
            btn.hidden = NO;
            self.hasVideo = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.large.length?model.large:model.thumbnail] placeholderImage:GetImage(@"default_1x1")];
            
        }else{
            [imageView sd_setImageWithURL:[NSURL URLWithString:model.large] placeholderImage:GetImage(@"default_1x1")];
        }
        
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tabGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapGesture:)];
        [imageView addGestureRecognizer:tabGesture];
        [self.scrollView addSubview:imageView];
        
        if (!model.videoPath.length) {
            [_imageViews addObject:imageView];
        }
    }];
    
    //取出数组最后一个图片 放到第0页
    UIImageView *zeroImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, scrollViewWidth, scrollViewHeight)];
    RJGoodDetailProductImagesModel *model = self.dataArray.lastObject;
    [zeroImageView sd_setImageWithURL:[NSURL URLWithString:model.large.length?model.large:model.thumbnail]];
    zeroImageView.contentMode = UIViewContentModeScaleToFill;
    [self.scrollView addSubview:zeroImageView];
    
    //取出数组第一张图片 放到最后一页
    UIImageView *lastImageView = [[UIImageView alloc]initWithFrame:CGRectMake(scrollViewWidth * (self.dataArray.count +1), 0, scrollViewWidth, scrollViewHeight)];
    RJGoodDetailProductImagesModel *model2 = self.dataArray.firstObject;
    [lastImageView sd_setImageWithURL:[NSURL URLWithString:model2.large]];
    lastImageView.contentMode = UIViewContentModeScaleToFill;
    [self.scrollView addSubview:lastImageView];
    //原理 4-1-2-3-4-1
    //设置scrollview的可见区域
    [self.scrollView setContentSize:CGSizeMake(scrollViewWidth * (self.dataArray.count +2), scrollViewHeight)];
    [self.scrollView setContentOffset:CGPointMake(scrollViewWidth, 0)];
    [self bringSubviewToFront:self.pageControl];
    
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


- (void)imageTapGesture:(UITapGestureRecognizer *)sender{
    /**
     *  统计上报
     */
    if (sender.view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
    }
    RJGoodDetailProductImagesModel *model = self.dataArray[sender.view.tag];
    if (model.videoPath) {
        self.mpPlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:model.videoPath]];
        _mpPlayer.view.frame = sender.view.bounds;
        _mpPlayer.controlStyle = MPMovieControlStyleNone;
        _mpPlayer.shouldAutoplay = YES;
        _mpPlayer.repeatMode = MPMovieRepeatModeNone;
        [_mpPlayer setFullscreen:YES animated:YES];
        _mpPlayer.scalingMode = MPMovieScalingModeNone;
        _mpPlayer.view.backgroundColor = [UIColor clearColor];
        
        [sender.view addSubview:_mpPlayer.view];
        
        [_mpPlayer prepareToPlay];
        [_mpPlayer play];
    }
    [self.delegate didSelectImageWithTag:sender.view.tag andImageViews:_imageViews hasVideo:self.hasVideo];
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
#pragma mark - player
- (void)playbackstateDidChange:(NSNotification *)noti{
    
    switch (self.mpPlayer.playbackState) {
        case MPMoviePlaybackStateInterrupted:
            //中断
            //            NSLog(@"中断");
            break;
        case MPMoviePlaybackStatePaused:
            //暂停
            //            NSLog(@"暂停");
            break;
        case MPMoviePlaybackStatePlaying:
            //播放中
            //            NSLog(@"播放中");
            break;
        case MPMoviePlaybackStateSeekingBackward:
            //后退
            //            NSLog(@"后退");
            break;
        case MPMoviePlaybackStateSeekingForward:
            //快进
            //            NSLog(@"快进");
            break;
        case MPMoviePlaybackStateStopped:
            //停止
            //            NSLog(@"停止");
            break;
            
        default:
            break;
    }
    
}

- (void)playDidFinish:(NSNotification *)noti
{
    //播放完成
    //    NSLog(@"播放完成");
    if (self.mpPlayer) {
        [self.mpPlayer.view removeFromSuperview];
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
