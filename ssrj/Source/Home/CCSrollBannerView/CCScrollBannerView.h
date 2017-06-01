//
//  CCScrollBannerView.h
//  ssrj
//
//  Created by CC on 16/5/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCScrollBannerViewDelegate <NSObject>
- (void)didSelectImageWithTag:(NSInteger)tag;

@end


@interface CCScrollBannerView : UIView
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) id<CCScrollBannerViewDelegate> delegate;
- (void)uploadScrollBannerViewWithImageDataArray:(NSMutableArray *)dataArray;
- (void)startTimer;
- (void)stopTimer;
@end
