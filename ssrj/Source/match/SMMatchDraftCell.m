//
//  SMMatchDraftCell.m
//  ssrj
//
//  Created by MFD on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDraftCell.h"
#import "Masonry.h"
@interface SMMatchDraftCell()
@property (nonatomic,strong)UIButton *deleteButton;
@end
@implementation SMMatchDraftCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(6, 6, 6, 6));
        }];
        self.layer.borderColor = [UIColor colorWithHexString:@"#f1f1f1"].CGColor;
        self.layer.borderWidth = 0.5;
        
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setImage:GetImage(@"match_redDel") forState:UIControlStateNormal];
        _deleteButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        [_deleteButton addTarget:self action:@selector(deleteBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
            
        }];
        self.isShowDeleteBtn = NO;
    }
    return self;
}
- (void)deleteBtnClick {
    if (self.deleteBlock) {
        self.deleteBlock();
    }
}
- (void)setIsShowDeleteBtn:(BOOL)isShowDeleteBtn {
    _isShowDeleteBtn = isShowDeleteBtn;
    _deleteButton.hidden = !isShowDeleteBtn;
}
@end
