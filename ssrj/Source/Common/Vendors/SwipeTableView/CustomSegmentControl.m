//
//  CustomSegmentControl.m
//  SwipeTableView
//
//  Created by Roy lee on 16/5/28.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

#import "CustomSegmentControl.h"
#import "UIView+STFrame.h"
#import "RJUserCenteRootViewController.h"

#define RGBColor(r,g,b)     [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

@interface CustomSegmentControl ()

@property (nonatomic, strong) UIView * contentView;
//@property (nonatomic, strong) NSArray * items;
@property (assign, nonatomic) CGFloat  itemWidth;
@end

@implementation CustomSegmentControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithItems:(NSArray *)items {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        if (items.count > 0) {
            self.items = items;
        }
    }
    return self;
}

- (void)reloadSegmentBarItemsDataWithArray:(NSArray *)array {
    
    _items = array;
    [self layoutSubviews];
}

- (void)commonInit {
    _contentView = [UIView new];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    _font = [UIFont systemFontOfSize:15];
    _textColor = RGBColor(50, 50, 50);
    _selectedTextColor = RGBColor(0, 0, 0);
    _selectionIndicatorColor = RGBColor(150, 150, 150);
    _items = @[@"Segment0",@"Segment1"];
    _indicatorViewColor = [UIColor colorWithHexString:@"#6225de"];
    _selectedSegmentIndex = 0;
    _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 1)];
    _lineView.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
    [_contentView addSubview:_lineView];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    for (UIView *subView in _contentView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    _contentView.backgroundColor = _backgroundColor;
    _contentView.frame = self.bounds;
    for (int i = 0; i < _items.count; i ++) {
        UIButton * itemBt = [UIButton buttonWithType:UIButtonTypeCustom];
        itemBt.tag = 666 + i;
        [itemBt setTitleColor:_textColor forState:UIControlStateNormal];
        [itemBt setTitleColor:_selectedTextColor forState:UIControlStateSelected];
        [itemBt setTitle:_items[i] forState:UIControlStateNormal];
        [itemBt.titleLabel setFont:_font];
        /**
         *  TrackingId
         */
        if (!self.parentVcID) {
            self.parentVcID = @0;
        }
        itemBt.trackingId = [NSString stringWithFormat:@"%@&itemBtn%d&id=%@",self.parentVcName,i,self.parentVcID];
        CGFloat itemWidth = self.width/_items.count;
        self.itemWidth = itemWidth;
        itemBt.size = CGSizeMake(itemWidth, self.height);
        itemBt.st_x    = itemWidth * i;
        if (i == _selectedSegmentIndex) {
            itemBt.backgroundColor = _selectionIndicatorColor;
            itemBt.selected = YES;
        }else {
            itemBt.backgroundColor = [UIColor clearColor];
        }
        [itemBt addTarget:self action:@selector(didSelectedSegment:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:itemBt];
        if (!self.indicatorView) {
            self.indicatorView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - 3, itemWidth, 3)];
            self.indicatorView.backgroundColor = _indicatorViewColor?:[UIColor redColor];
            [_contentView addSubview:_indicatorView];
        }
        self.lineView.width = self.contentView.width;
        self.lineView.st_y = self.contentView.height - 1;
        [_contentView addSubview:_lineView];

    }
    [self.contentView bringSubviewToFront:self.indicatorView];
    
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
    UIButton * oldItemBt      = [_contentView viewWithTag:666 + _selectedSegmentIndex];
    oldItemBt.backgroundColor = [UIColor clearColor];
    oldItemBt.selected        = NO;
    UIButton * itemBt      = [_contentView viewWithTag:666 + selectedSegmentIndex];
    itemBt.backgroundColor = _selectionIndicatorColor;
    itemBt.selected        = YES;
    
    _selectedSegmentIndex  = selectedSegmentIndex;
    self.indicatorView.st_x = selectedSegmentIndex *self.itemWidth;
}

- (void)didSelectedSegment:(UIButton *)itemBt {
    UIButton * oldItemBt      = [_contentView viewWithTag:666 + _selectedSegmentIndex];
    oldItemBt.backgroundColor = [UIColor clearColor];
    oldItemBt.selected        = NO;
    
    itemBt.backgroundColor = _selectionIndicatorColor;
    itemBt.selected        = YES;
    _selectedSegmentIndex  = itemBt.tag - 666;
    self.indicatorView.st_x = _selectedSegmentIndex *self.itemWidth;

    if (self.IndexChangeBlock) {
        self.IndexChangeBlock(_selectedSegmentIndex);
    }
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end





