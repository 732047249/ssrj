//
//  MineBoughtGoodsCollectionViewCell.m
//  ssrj
//
//  Created by YiDarren on 16/8/6.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MineBoughtGoodsCollectionViewCell.h"

@interface MineBoughtGoodsCollectionViewCell ()<UIScrollViewDelegate>

@end


@implementation MineBoughtGoodsCollectionViewCell

- (void)showRightLine{
    self.lineView.hidden = NO;
}
- (void)hideRightLine{
    self.lineView.hidden = YES;
    
}
-(void)prepareForReuse{
    [super prepareForReuse];
    
    self.zanImageView.highlighted = self.model.isThumbsup;
}

-(void)setModel:(MineBoughtGoodsModel *)model{
    if (_model != model) {
        _model = model;
        //    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
        self.goodNameLabel.text = model.name;
        self.goodBrandLabel.text = model.brandName;
        self.markPriceLabel.attributedText = [NSString effectivePriceWithString:model.marketPrice.stringValue];
        self.effectivePriceLabel.text = [NSString stringWithFormat:@"￥%@",model.effectivePrice];
        self.specialImageView.image = nil;
        
        self.effectivePriceLabel.textColor = [UIColor blackColor];
        
        if (model.isNewProduct) {
            
            self.specialImageView.image = GetImage(@"xinping_right");
            
        }
        if (model.isSpecialPrice) {
            self.effectivePriceLabel.textColor = [UIColor colorWithHexString:@"#F63649"];
            
            self.specialImageView.image = GetImage(@"tejia_right");
        }
        
        for (UIImageView *view in self.imageScrollView.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [view removeFromSuperview];
            }
        }
        [self.imageScrollView setContentOffset:CGPointZero];
        
        CGFloat scrollWidth = SCREEN_WIDTH /2 - 20;
        for (int i= 0; i<model.imgsList.count; i++) {

            UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(scrollWidth * i, 0, scrollWidth, scrollWidth)];
            
            NSString *imageUrl = [[model.imgsList objectAtIndex:i] objectForKey:@"imgThumbnail"];
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:GetImage(@"default_1x1")];
            
            [self.imageScrollView addSubview:imageView];
        }
        [self.imageScrollView setContentSize:CGSizeMake(scrollWidth *model.imgsList.count, scrollWidth)];
        [self.viewOne bringSubviewToFront:self.specialImageView];
        self.pageControl.numberOfPages = model.imgsList.count;
    }
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.imageScrollView.delegate = self;
    self.imageScrollView.scrollsToTop = NO;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
    [self.contentView addGestureRecognizer:tapGesture];
    
}
- (void)tapGestureAction:(UITapGestureRecognizer *)sender{
    UIView *view = sender.view;
    [self.delegate tapGsetureWithIndexRow:view.tag];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat scrollWidth = scrollView.frame.size.width;
    NSInteger i = (scrollView.contentOffset.x)/scrollWidth;
    self.pageControl.currentPage = i;
}


@end
