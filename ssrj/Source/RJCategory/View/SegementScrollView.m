//
//  SegementScrollView.m
//  categoryDemo
//
//  Created by MFD on 16/5/24.
//  Copyright © 2016年 MFD. All rights reserved.
//

#define KWIDTH [UIScreen mainScreen].bounds.size.width

#import "SegementScrollView.h"


@interface SegementScrollView()<UIScrollViewDelegate,UISearchBarDelegate>
@property (nonatomic,strong) UISearchBar *searchbar1;
@property (nonatomic,strong) UISearchBar *searchbar2;

@end


@implementation SegementScrollView
- (instancetype)initWithFrame:(CGRect)frame titleArray:(NSArray *)titleArray contentViewArray:(NSArray *)contentViewArray{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgScrollView];
    
        _segmentView = [[SegmentView alloc]initWithFrame:CGRectMake(0, 0, KWIDTH, 44) titles:titleArray clickBlock:^(NSInteger index) {
            [_bgScrollView setContentOffset:CGPointMake(KWIDTH*(index -1), 0)];
        }];
        _segmentView.backgroundColor = [UIColor colorWithRed:65/255.0 green:31/255.0 blue:142/255.0 alpha:1];
        [self addSubview:_segmentView];
   
        for (int i=0; i<contentViewArray.count; i++) {
            UIView *contentView = (UIView *)contentViewArray[i];
            contentView.frame = CGRectMake(KWIDTH * i, _segmentView.bounds.size.height+44, KWIDTH, _bgScrollView.frame.size.height - _segmentView.bounds.size.height-44-44);
            if (i == 1) {
                contentView.frame = CGRectMake(KWIDTH + 6, _segmentView.bounds.size.height + 6+44, KWIDTH - 12, _bgScrollView.frame.size.height - _segmentView.bounds.size.height  - 12 -44 - 44);
            }
            [_bgScrollView addSubview:contentView];
        
        }
    }
    return self;
}


#pragma mark --lazy
- (UIScrollView *)bgScrollView{
    if (!_bgScrollView) {
        _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _segmentView.frame.size.height, KWIDTH, self.bounds.size.height-_segmentView.bounds.size.height)];
        self.searchbar1 = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 44, KWIDTH, 44)];
        self.searchbar1.searchBarStyle = UISearchBarStyleMinimal;
        self.searchbar1.placeholder = @"搜索：分类 品牌 系列 商品";
        self.searchbar1.userInteractionEnabled = NO;
        self.searchbar1.delegate = self;
        [_bgScrollView addSubview:self.searchbar1];
        
        self.searchbar2 = [[UISearchBar alloc]initWithFrame:CGRectMake(KWIDTH, 44, KWIDTH, 44)];
        self.searchbar2.searchBarStyle = UISearchBarStyleMinimal;
        self.searchbar2.placeholder = @"搜索：分类 品牌 系列 商品";
        [_bgScrollView addSubview:self.searchbar2];
        
        _bgScrollView.contentSize = CGSizeMake(KWIDTH*2, self.bounds.size.height-_segmentView.bounds.size.height);
        _bgScrollView.backgroundColor = [UIColor whiteColor];
        _bgScrollView.showsVerticalScrollIndicator = NO;
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.delegate = self;
        _bgScrollView.bounces = NO;
        _bgScrollView.pagingEnabled = YES;
    }
    return _bgScrollView;
}


#pragma mark --searchDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
   

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
//     NSLog(@"searchBar edit");
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_bgScrollView)
    {
        NSInteger p=_bgScrollView.contentOffset.x/KWIDTH;
        _segmentView.defaultIndex=p+1;
        
    }
    
}
@end
