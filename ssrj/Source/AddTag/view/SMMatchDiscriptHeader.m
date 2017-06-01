//
//  SMMatchDiscriptHeader.m
//  ssrj
//
//  Created by MFD on 16/11/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDiscriptHeader.h"
#import "Masonry.h"
@interface SMMatchDiscriptHeader()<UITextFieldDelegate>
@property (nonatomic,strong)UIImageView *searchImageView;
@property (nonatomic,strong)UIView *line;
@property (nonatomic,strong)UIView *whiteBgView;
@end
@implementation SMMatchDiscriptHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _whiteBgView = [[UIView alloc] init];
        _whiteBgView.backgroundColor = [UIColor whiteColor];
        _whiteBgView.layer.cornerRadius = 4;
        _whiteBgView.layer.masksToBounds = YES;
        [self addSubview:_whiteBgView];
        
        self.searchImageView = [[UIImageView alloc] init];
        self.searchImageView.image = [UIImage imageNamed:@"search_icon2"];
        self.searchImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.searchImageView];
        
        self.textField = [[UITextField alloc] init];
        _textField.placeholder = @"搜索：品牌";
        _textField.font = [UIFont systemFontOfSize:13];
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.delegate = self;
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:self.textField];
        
        _line = [[UIView alloc] init];
        _line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self addSubview:_line];
        
        [_whiteBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(7, 7, 6, 7));
        }];
        
        [_searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_whiteBgView).offset(10);
            make.size.mas_equalTo(CGSizeMake(14, 14));
            make.centerY.equalTo(_whiteBgView);
        }];
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_searchImageView.mas_right).offset(7.5);
            make.top.bottom.equalTo(_whiteBgView);
            make.right.equalTo(_whiteBgView).offset(0);
        }];
        [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self);
            make.left.equalTo(_whiteBgView.mas_right);
        }];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
        NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
        _textField.trackingId = [NSString stringWithFormat:@"%@&SMMatchDiscriptHeader&textField",vcName];
    }
    return self;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_textField resignFirstResponder];
    return YES;
}
@end
