//
//  LXSegmentScrollView.m
//  LiuXSegment
//
//  Created by liuxin on 16/5/17.
//  Copyright © 2016年 liuxin. All rights reserved.
//

#import "LXSegmentScrollView.h"
#import "LiuXSegmentView.h"

@interface LXSegmentScrollView()<UIScrollViewDelegate>
@property (strong,nonatomic)UIScrollView *bgScrollView;
@property (strong,nonatomic)LiuXSegmentView *segmentToolView;
@property (assign, nonatomic) NSUInteger titleAount;

@end

@implementation LXSegmentScrollView


-(instancetype)initWithFrame:(CGRect)frame
                  titleArray:(NSArray *)titleArray
            contentViewArray:(NSArray *)contentViewArray{
    if (self = [super initWithFrame:frame]) {
        
        self.titleAount = contentViewArray.count;

        _segmentToolView=[[LiuXSegmentView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44) titles:titleArray clickBlick:^void(NSInteger index) {

            [_bgScrollView setContentOffset:CGPointMake(SCREEN_WIDTH*(index-1), 0)];
        }];
        
        [self addSubview:self.bgScrollView];

        [self addSubview:_segmentToolView];
        
        
        for (int i=0;i<contentViewArray.count; i++ ) {
        
            UIView *contentView = (UIView *)contentViewArray[i];
            
            contentView.frame=CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, _bgScrollView.frame.size.height-_segmentToolView.bounds.size.height);
            
            [_bgScrollView addSubview:contentView];
        }

        
    }
    
    
    return self;
}






-(UIScrollView *)bgScrollView{
    if (!_bgScrollView) {
        _bgScrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, _segmentToolView.frame.size.height, SCREEN_WIDTH, self.bounds.size.height-_segmentToolView.bounds.size.height)];
        
        
        //contentSize 的大小，不做固定，SCREEN_WIDTH*_titleArr.count(这种情况竟然导致不能滑动! 打印知此时初始值为nil,导致contentSize为零)
        //NSLog(@"titleArr.count %lu  ", _titleArr.count);

        //固定直接给出个数 SCREEN_WIDTH*5
        
        _bgScrollView.contentSize=CGSizeMake(SCREEN_WIDTH*self.titleAount, self.bounds.size.height-_segmentToolView.bounds.size.height);
//        _bgScrollView.backgroundColor=[UIColor brownColor];
        _bgScrollView.showsVerticalScrollIndicator=NO;
        _bgScrollView.showsHorizontalScrollIndicator=NO;
        _bgScrollView.delegate=self;
        _bgScrollView.bounces=NO;
        _bgScrollView.pagingEnabled=YES;
    }
    return _bgScrollView;
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_bgScrollView)
    {
        NSInteger p=_bgScrollView.contentOffset.x/SCREEN_WIDTH;
        _segmentToolView.defaultIndex=p+1;
        
    }
    
}

@end
