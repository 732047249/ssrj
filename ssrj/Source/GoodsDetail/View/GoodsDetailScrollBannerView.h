//
//  GoodsDetailScrollBannerView.h
//  ssrj
//
//  Created by MFD on 16/6/6.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GoodsDetailScrollBannerViewDelegate <NSObject>
- (void)didSelectImageWithTag:(NSInteger)tag andImageViews:(NSMutableArray *)imageViews hasVideo:(BOOL)flag;

@end

@interface GoodsDetailScrollBannerView : UIView
@property (nonatomic,weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic,weak) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) id<GoodsDetailScrollBannerViewDelegate> delegate;
@property (nonatomic,strong) UIActivityIndicatorView * indicatorView;
- (void)uploadScrollBannerViewWithDataArray:(NSMutableArray *)dataArray;
- (void)startTimer;
- (void)stopTimer;

@end
