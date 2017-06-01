//
//  SMMatchDiscriptDetailHeader.m
//  ssrj
//
//  Created by MFD on 16/11/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDiscriptDetailHeader.h"
#import "Masonry.h"
@interface SMMatchDiscriptDetailHeader()<UITextFieldDelegate>
@property (nonatomic,strong)UIView *line;
@property (nonatomic,strong)UIView *whiteBgView;
@end
@implementation SMMatchDiscriptDetailHeader
// 44 + 3
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _whiteBgView = [[UIView alloc] init];
        _whiteBgView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_whiteBgView];
        
        _label = [[UILabel alloc] init];
        [self addSubview:_label];
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:_line];
        
        self.textField = [[UITextField alloc] init];
        _textField.placeholder = @"搜索：商品";
        _textField.font = [UIFont systemFontOfSize:15];
        _textField.delegate = self;
        _textField.returnKeyType = UIReturnKeyDone;
        [self addSubview:self.textField];
        
        _cancelBtn = [[UIButton alloc]init];
        [_cancelBtn setImage:GetImage(@"match_deletehui") forState:UIControlStateNormal];
        _cancelBtn.frame = CGRectMake(0, 0, 22, 22);
        _textField.rightView = _cancelBtn;
        _textField.rightViewMode = UITextFieldViewModeWhileEditing;
        
        [_whiteBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.bottom.equalTo(self).offset(-10);
        }];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self);
            make.height.mas_equalTo(44);
            make.right.equalTo(self).offset(-20);
        }];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_label.mas_bottom);
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_label);
            make.top.equalTo(_line.mas_bottom);
            make.right.equalTo(self).offset(-20);
            make.height.mas_equalTo(44);
        }];
    }
    return self;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textField resignFirstResponder];
    return YES;
}
@end
