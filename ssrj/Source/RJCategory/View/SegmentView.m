//
//  SegmentView.m
//  categoryDemo
//
//  Created by MFD on 16/5/24.
//  Copyright © 2016年 MFD. All rights reserved.
//

#define windowContentWidth  ([[UIScreen mainScreen] bounds].size.width)
#define windowContentHeight  ([[UIScreen mainScreen] bounds].size.height)
#define MFDRedColor [UIColor colorWithRed:255/255.0 green:92/255.0 blue:79/255.0 alpha:1]
#define MFDSelectColor         [UIColor blackColor]
#define MAX_TitleNumInWindow 5


#import "SegmentView.h"
@interface SegmentView()
@property (nonatomic,strong) NSMutableArray *btns;
@property (nonatomic,strong) NSArray *titles;
@property (nonatomic,strong) UIButton *titleBtn;

@property (nonatomic,strong) UIScrollView *bgScrollView;
@property (nonatomic,strong) UIView *selectLine;
@property (nonatomic,strong) UIView *selectBgLine;


@property (nonatomic,assign) CGFloat btn_w;
@end

@implementation SegmentView

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titleArray clickBlock:(btnClickBlock)block{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        self.layer.shadowRadius = 2;
        self.layer.shadowOpacity = 0.2;
        _btn_w = 0.0;
        if (titleArray.count < MAX_TitleNumInWindow+1) {
            _btn_w = windowContentWidth/titleArray.count;
        }else{
            _btn_w = windowContentWidth/MAX_TitleNumInWindow;
        }
        _titles = titleArray;
        _defaultIndex=1;
        _titleFont = [UIFont systemFontOfSize:15];
        _btns = [NSMutableArray arrayWithCapacity:0];
        _titleNomalColor = [UIColor whiteColor];
//      _titleSelectColor = MFDRedColor;
        _titleSelectColor = [UIColor colorWithRed:65/255.0 green:31/255.0 blue:142/255.0 alpha:1];
        
        _bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, windowContentWidth, self.frame.size.height)];
        _bgScrollView.backgroundColor = [UIColor whiteColor];
        _bgScrollView.showsHorizontalScrollIndicator = NO;
        _bgScrollView.contentSize = CGSizeMake(_btn_w*titleArray.count, self.frame.size.height);
        [self addSubview:_bgScrollView];
        
        _selectBgLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-4, _btn_w*2, 4)];
        _selectBgLine.backgroundColor = [UIColor colorWithRed:25/255.0 green:13/255.0 blue:49/255.0 alpha:1];
        [_bgScrollView addSubview:_selectBgLine];
        
        _selectLine = [[UIView alloc]initWithFrame:CGRectMake(0, self.frame.size.height-4, _btn_w, 4)];
        _selectLine.backgroundColor = [UIColor colorWithRed:90/255.0 green:26/255.0 blue:245/255.0 alpha:1];
        [_bgScrollView addSubview:_selectLine];
        
        for (int i=0; i<titleArray.count; i++) {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(_btn_w*i, 0, _btn_w, self.frame.size.height-4)];
            btn.tag = i+1;
            [btn setTitle:titleArray[i] forState:UIControlStateNormal];
//            [btn setTitleColor:_titleNomalColor forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithRed:98/255.0 green:94/255.0 blue:108/255.0 alpha:1] forState:UIControlStateNormal];
            [btn setTitleColor:_titleNomalColor forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchDown];
            [btn setBackgroundColor:[UIColor colorWithRed:25/255.0 green:13/255.0 blue:49/255.0 alpha:1]];
            btn.titleLabel.font = _titleFont;            
            [_bgScrollView addSubview:btn];
            [_btns addObject:btn];
            if (0 == i) {
                _titleBtn = btn;
                btn.selected = YES;
            }
            self.block = block;
        }
    }
    
    return  self;
    
}


- (void)btnClick:(UIButton *)btn{
    if (self.block) {
        self.block(btn.tag);
    }
    
    if (btn.tag == _defaultIndex) {
        return;
    }else{
        _titleBtn.selected = !_titleBtn.selected;
        _titleBtn = btn;
        _titleBtn.selected = YES;
        _defaultIndex=btn.tag;
    }
    
    //计算偏移量
    CGFloat offsetX = btn.frame.origin.x - 2*_btn_w;
    if (offsetX < 0) {
        offsetX = 0;
    }
    CGFloat maxOffsetX = _bgScrollView.contentSize.width-windowContentWidth;
    if (offsetX > maxOffsetX) {
        offsetX = maxOffsetX;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        [_bgScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
        _selectLine.frame = CGRectMake(btn.frame.origin.x, self.frame.size.height-4, btn.frame.size.width, 4);
        
    }];
    
    
}

-(void)setTitleNomalColor:(UIColor *)titleNomalColor{
    _titleNomalColor=titleNomalColor;
    [self updateView];
}

-(void)setTitleSelectColor:(UIColor *)titleSelectColor{
    _titleSelectColor=titleSelectColor;
    [self updateView];
}

-(void)setTitleFont:(UIFont *)titleFont{
    _titleFont=titleFont;
    [self updateView];
}

-(void)setDefaultIndex:(NSInteger)defaultIndex{
    _defaultIndex=defaultIndex;
    [self updateView];
}

- (void)updateView{
    for (UIButton *btn in _btns) {
//        [btn setTitleColor:_titleNomalColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithRed:98/255.0 green:94/255.0 blue:108/255.0 alpha:1] forState:UIControlStateNormal];
        [btn setTitleColor:_titleNomalColor forState:UIControlStateSelected];
        btn.titleLabel.font = _titleFont;
        
        _selectLine.backgroundColor = [UIColor colorWithRed:90/255.0 green:26/255.0 blue:245/255.0 alpha:1];;
        
        if (btn.tag-1 == _defaultIndex-1) {
            _titleBtn = btn;
            btn.selected = YES;
            _selectLine.frame = CGRectMake(btn.frame.origin.x, self.frame.size.height-4, btn.frame.size.width, 4);
        }else{
            btn.selected = NO;
        }
    }
}

@end
