//
//  CommentCell3.m
//  ssrj
//
//  Created by MFD on 16/9/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CommentCell3.h"
#import "Masonry.h"

@implementation CommentCell3

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self  = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _sepView = [[UIView alloc]initWithFrame:CGRectZero];
//        _sepView.backgroundColor = [UIColor colorWithHexString:@"e5e5e5"];
        
        _textField = [[UITextField alloc]initWithFrame:CGRectZero];
        _textField.borderStyle = UITextBorderStyleNone;
        _textField.layer.cornerRadius = 4;
        _textField.layer.masksToBounds = YES;
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
        
        [self.contentView addSubview:_sepView];
        [self.contentView addSubview:_textField];
        [self.contentView addSubview:_sendButton];
        
        
        [_sepView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(1);
            make.width.mas_equalTo(SCREEN_WIDTH);
            make.top.equalTo(self.contentView.mas_top);
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
