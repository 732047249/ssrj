//
//  ThemeCommentCell2.m
//  ssrj
//
//  Created by MFD on 16/9/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ThemeCommentCell2.h"
#import <Masonry.h>

@implementation ThemeCommentCell2

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _arrow = [[UIImageView alloc]initWithFrame:CGRectZero];
        _arrow.image = [UIImage imageNamed:@"sort_section_down"];
        
        _label = [[UILabel alloc]initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:15];
        _label.text = @"展开更多评论";
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor colorWithHexString:@"898e90"];
        
        _moreCommentBtn = [[UIButton alloc]initWithFrame:CGRectZero];
        
        _sepView = [[UIView alloc]initWithFrame:CGRectZero];
        _sepView.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
        
        _textField = [[UITextField alloc]initWithFrame:CGRectZero];
        _textField.borderStyle = UITextBorderStyleRoundedRect;
        _textField.backgroundColor = [UIColor colorWithHexString:@"f1f0f6"];
        _textField.textColor = [UIColor colorWithHexString:@"424446"];
        _textField.returnKeyType = UIReturnKeySend;
        
        _sendButton = [[UIButton alloc]initWithFrame:CGRectZero];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _sendButton.titleLabel.textColor = [UIColor whiteColor];
        _sendButton.backgroundColor = [UIColor colorWithHexString:@"190e31"];
        _sendButton.layer.cornerRadius = 4;
        _sendButton.layer.masksToBounds = YES;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        
        [self.contentView addSubview:_arrow];
        [self.contentView addSubview:_label];
        [self.contentView addSubview:_moreCommentBtn];
        [self.contentView addSubview:_sepView];
        [self.contentView addSubview:_textField];
        [self.contentView addSubview:_sendButton];
        
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.top.equalTo(self.contentView.mas_top).offset(10);
        }];
        
        [_arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_label.mas_left).offset(-5);
            make.centerY.equalTo(_label.mas_centerY);
            make.height.mas_equalTo(10);
            make.width.mas_equalTo(10);
        }];
        
        [_sepView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.top.equalTo(_label.mas_bottom).offset(10);
        }];
        
        [_moreCommentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left);
            make.right.equalTo(self.contentView.mas_right);
            make.top.equalTo(self.contentView.mas_top);
            make.bottom.equalTo(self.sepView.mas_top);
        }];
        
        [_sendButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_sepView.mas_bottom).offset(10);
            make.right.equalTo(self.contentView.mas_right).offset(-10);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
            make.width.mas_equalTo(50);
        }];
        
        [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView.mas_left).offset(10);
            make.right.equalTo(_sendButton.mas_left).offset(-5);
            make.height.equalTo(_sendButton.mas_height);
            make.centerY.equalTo(_sendButton.mas_centerY);
        }];

    }
    
    return self;
}
@end
