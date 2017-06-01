//
//  HHMyGoodsCell.m
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHYiStoreMyGoodsCell.h"
#import "Masonry.h"
@interface HHYiStoreMyGoodsCell ()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIImageView *fashionCurrencyImageView;
@property (nonatomic, strong) UILabel *fashionCurrencyLabel;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *brandNameLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@property (nonatomic, strong) UILabel *marketPriceLabel;
@end

@implementation HHYiStoreMyGoodsCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configView];
    }
    return self;
}

- (void)configView {
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    _pageControl.pageIndicatorTintColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:_pageControl];
    
    _deleteButton = [[UIButton alloc] init];
    [_deleteButton setImage:GetImage(@"yiStore_quchu") forState:UIControlStateNormal];
    [_deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
    
    _fashionCurrencyImageView = [[UIImageView alloc] init];
    _fashionCurrencyImageView.image = GetImage(@"yiStore_biaoqian");
    [self addSubview:_fashionCurrencyImageView];
    
    _fashionCurrencyLabel = [[UILabel alloc] init];
    _fashionCurrencyLabel.font = [UIFont systemFontOfSize:12];
    _fashionCurrencyLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_fashionCurrencyLabel];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:13];
    [self addSubview:_nameLabel];
    
    _brandNameLabel = [[UILabel alloc]init];
    _brandNameLabel.font = [UIFont systemFontOfSize:12];
    _brandNameLabel.textColor = [UIColor colorWithHexString:@"#898e90"];
    [self addSubview:_brandNameLabel];
    
    _priceLabel = [[UILabel alloc] init];
    _priceLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_priceLabel];
    
    _marketPriceLabel = [[UILabel alloc] init];
    _marketPriceLabel.font = [UIFont systemFontOfSize:14];
    _marketPriceLabel.textColor = [UIColor colorWithHexString:@"898e90"];
    [self addSubview:_marketPriceLabel];
    
    [self setupRect];
}
- (void)setupRect {
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(10);
        make.right.equalTo(self).offset(-10);
        make.height.equalTo(_scrollView.mas_width);
    }];
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_bottom);
        make.centerX.equalTo(_scrollView);
        make.height.mas_equalTo(15);
    }];
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self).offset(8);
        make.size.mas_equalTo(CGSizeMake(17, 17));
    }];
    [_fashionCurrencyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(56, 29));
        make.right.equalTo(self).offset(-7);
        make.centerY.equalTo(_deleteButton);
    }];
    [_fashionCurrencyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_fashionCurrencyImageView).offset(10);
        make.right.equalTo(_fashionCurrencyImageView).offset(-2);
        make.centerY.equalTo(_fashionCurrencyImageView);
        make.height.equalTo(_fashionCurrencyImageView);
    }];
    
    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_scrollView.mas_bottom);
        make.height.mas_equalTo(15);
    }];
    _nameLabel.text = @" ";
    [_nameLabel sizeToFit];
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.top.equalTo(_pageControl.mas_bottom).offset(5);
        make.height.mas_equalTo(_nameLabel.bounds.size.height);
    }];
    _brandNameLabel.text = @" ";
    [_brandNameLabel sizeToFit];
    [_brandNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(_nameLabel);
        make.top.equalTo(_nameLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(_brandNameLabel.bounds.size.height);
    }];
    
    _priceLabel.text = @" ";
    [_priceLabel sizeToFit];
    [_priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_brandNameLabel);
        make.top.mas_equalTo(_brandNameLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(_priceLabel.bounds.size.height);
    }];
    
    _marketPriceLabel.text = @" ";
    [_marketPriceLabel sizeToFit];
    [_marketPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_priceLabel.mas_right).offset(5);
        make.centerY.equalTo(_priceLabel);
        make.height.mas_equalTo(_marketPriceLabel.bounds.size.height);
        make.right.equalTo(self);
    }];
    
//    [self layoutIfNeeded];
//    NSLog(@"%@---%@",NSStringFromCGRect(_pageControl.frame),NSStringFromCGRect(_marketPriceLabel.frame));//238.5 + 17 + 5  - 177.5
}

- (void)setGoodsModel:(RJBaseGoodModel *)goodsModel {
    _goodsModel = goodsModel;
    if (goodsModel.fashionCurrency.intValue > 0) {
        _fashionCurrencyLabel.text = [NSString stringWithFormat:@"币:%d",[goodsModel.fashionCurrency intValue]];
        _fashionCurrencyLabel.hidden = NO;
        _fashionCurrencyImageView.hidden = NO;
    }else {
        _fashionCurrencyLabel.hidden = YES;
        _fashionCurrencyImageView.hidden = YES;
    }
    
    self.nameLabel.text = goodsModel.name;
    self.brandNameLabel.text = goodsModel.brandName;
    self.marketPriceLabel.attributedText = [NSString effectivePriceWithString:goodsModel.marketPrice];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%d",[goodsModel.effectivePrice intValue]];

    for (UIImageView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [view removeFromSuperview];
        }
    }
    [self.scrollView setContentOffset:CGPointZero];
    
    
    CGFloat scrollWidth = SCREEN_WIDTH /2 - 20;
    for (int i= 0; i<goodsModel.imgsList.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scrollWidth * i, 0, scrollWidth, scrollWidth)];
        
        RJGoodListImageListModel * imageModel = goodsModel.imgsList[i];
        
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageModel.imgThumbnail] placeholderImage:GetImage(@"default_1x1")];
        [self.scrollView addSubview:imageView];
        
        //给视频图片添加点击播放时间
        //            if (i == 0) {
        //                imageModel.videoPath = @"http://vedio.ssrj.cn/static/K165-116-NV.mp4";
        //            }
        //            if (imageModel.videoPath.length) {
        //                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickVideo:)];
        //                imageView.tag = i + 30;
        //                imageView.userInteractionEnabled = YES;
        //                [imageView addGestureRecognizer:tap];
        //            }
    }
    [self.scrollView setContentSize:CGSizeMake(scrollWidth *goodsModel.imgsList.count, scrollWidth)];
    self.pageControl.numberOfPages = goodsModel.imgsList.count;
}
- (void)deleteButtonClick:(UIButton *)sender {
    if (self.deleteBlcok) {
        self.deleteBlcok(self.goodsModel.goodId);
    }
}
#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollWidth = scrollView.frame.size.width;
    NSInteger i = (scrollView.contentOffset.x)/scrollWidth;
    self.pageControl.currentPage = i;
}
@end
