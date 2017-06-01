//
//  SMGoodsDetailScrollView.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SMGoodsDetailScrollViewDelegate <NSObject>
- (void)didSelectImageWithTag:(NSInteger)tag andImageViews:(NSMutableArray *)imageViews hasVideo:(BOOL)flag;

@end
@interface SMGoodsDetailScrollView : UIView
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) id<SMGoodsDetailScrollViewDelegate> delegate;

@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIPageControl *pageControl;
- (void)uploadScrollBannerViewWithDataArray:(NSMutableArray *)dataArray;
- (void)startTimer;
- (void)stopTimer;
@end
