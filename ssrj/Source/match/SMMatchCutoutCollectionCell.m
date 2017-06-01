//
//  SMMatchCutoutCollectionCell.m
//  ssrj
//
//  Created by MFD on 16/11/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchCutoutCollectionCell.h"
#import "Masonry.h"
@implementation SMMatchCutoutCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        _imageView.userInteractionEnabled = YES;
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [_imageView addGestureRecognizer:tap];
        
        self.layer.borderColor = [UIColor blueColor].CGColor;
        
    }
    return self;
}
- (void)tapClick {
    if (self.clickBlock) {
        self.clickBlock();
    }
}
- (void)setCutModel:(SMMatchCutoutModel *)cutModel {
    _cutModel = cutModel;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:cutModel.image] placeholderImage:[UIImage imageNamed:@"placeHodler"]];
    if ([cutModel.selected boolValue]) {
        self.layer.borderWidth = 1;
    }else {
        self.layer.borderWidth = 0;
    }
}

@end
