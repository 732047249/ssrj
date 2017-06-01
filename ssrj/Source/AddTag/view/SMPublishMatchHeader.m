//
//  SMPublishMatchHeader.m
//  ssrj
//
//  Created by MFD on 16/11/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMPublishMatchHeader.h"
#import "Masonry.h"
#define KPublishPage 10
@interface SMPublishMatchHeader()<UITextFieldDelegate,UITextViewDelegate>
@property (nonatomic,strong)UIView *searchBg;
@property (nonatomic,strong)UIImageView *searchImageView;


@end
@implementation SMPublishMatchHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UIView *topBg = [[UIView alloc] init];
        topBg.backgroundColor = [UIColor whiteColor];
        [self addSubview:topBg];
        
        UIView *bottomBg = [[UIView alloc] init];
        bottomBg.backgroundColor = [UIColor whiteColor];
        [self addSubview:bottomBg];
        
        //top
        _matchNameTF = [[UITextField alloc]init];
        _matchNameTF.placeholder = @"添加搭配名称";
        _matchNameTF.font = [UIFont systemFontOfSize:16];
        _matchNameTF.delegate = self;
        _matchNameTF.returnKeyType = UIReturnKeyDone;
        [_matchNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [topBg addSubview:_matchNameTF];
        
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [topBg addSubview:topLine];
        
        _matchDiscriptTF = [[SMPlaceHolderTextView alloc]init];
        _matchDiscriptTF.placeholder = @"添加搭配描述";
        _matchDiscriptTF.textColor = [UIColor colorWithHexString:@"#898e90"];
//        _matchDiscriptTF.textContainerInset = UIEdgeInsetsMake(8, 0, 8, 0);
        _matchDiscriptTF.font = [UIFont systemFontOfSize:13];
        _matchDiscriptTF.delegate = self;
        _matchDiscriptTF.returnKeyType = UIReturnKeyDone;
        [topBg addSubview:_matchDiscriptTF];
        
        _imageView = [[UIImageView alloc]init];
        _imageView.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
        _imageView.layer.borderWidth = 1;
        [topBg addSubview:_imageView];
        
        //bottom
        _addThemeLabel = [UILabel new];
        _addThemeLabel.text = @"加入合辑";
        _addThemeLabel.textColor = [UIColor colorWithHexString:@"#424446"];
        _addThemeLabel.font = [UIFont systemFontOfSize:12];
        [bottomBg addSubview:_addThemeLabel];
        
        _searchBg = [[UIView alloc]init];
        _searchBg.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _searchBg.layer.cornerRadius = 3;
        _searchBg.layer.masksToBounds = YES;
        [bottomBg addSubview:_searchBg];
        
        _searchImageView = [[UIImageView alloc]init];
        _searchImageView.image = [UIImage imageNamed:@"search_icon2"];
        _searchImageView.contentMode = UIViewContentModeScaleToFill;
        [_searchBg addSubview:_searchImageView];
        
        _searchTF = [[UITextField alloc]init];
        _searchTF.delegate = self;
        _searchTF.placeholder = @"搜索您要加入的合辑";
        _searchTF.font = GetFont(14);
        [_searchBg addSubview:_searchTF];
        //all = 120 + 10 + 70 + 10
        [topBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(120);
        }];
        [bottomBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.left.equalTo(topBg);
            make.top.equalTo(topBg.mas_bottom).offset(7.5);
            make.height.mas_equalTo(60);
        }];
        //top
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(topBg);
            make.size.mas_equalTo(CGSizeMake(100, 100));
            make.right.equalTo(topBg).offset(-KPublishPage);
        }];
        [_matchNameTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_imageView);
            make.left.equalTo(topBg).offset(KPublishPage);
            make.height.mas_equalTo(30);
            make.right.equalTo(_imageView.mas_left).offset(-20);
        }];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(_matchNameTF);
            make.top.equalTo(_matchNameTF.mas_bottom);
            make.height.mas_equalTo(1);
        }];
        [_matchDiscriptTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(topLine).offset(-4);
            make.right.equalTo(topLine);
            make.top.equalTo(topLine.mas_bottom);
            make.bottom.equalTo(_imageView);
        }];
        //bottom
        [_addThemeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(bottomBg);
            make.left.equalTo(bottomBg).offset(KPublishPage);
            make.right.equalTo(bottomBg).offset(-KPublishPage);
            make.height.mas_equalTo(30);
        }];
        [_searchBg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_addThemeLabel.mas_bottom);
            make.left.right.equalTo(_addThemeLabel);
            make.height.mas_equalTo(30);
        }];
        [_searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_searchBg);
            make.left.equalTo(_searchBg).offset(10);
            make.size.mas_equalTo(CGSizeMake(18, 18));
        }];
        [_searchTF mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_searchImageView.mas_right).offset(7.5);
            make.top.right.bottom.equalTo(_searchBg);
        }];
        
//        [self layoutIfNeeded];//127.5+70
//        NSLog(@"%@",NSStringFromCGRect(bottomBg.frame));
    }
    return self;
}
//设置设置输入框不能接受编辑事件，其他的可以
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == _searchTF) {
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField == _matchNameTF) {
        if (textField.text.length > 20) {
            textField.text = [textField.text substringToIndex:20];
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"最多输入20个字符" hideDelay:1];
            [textField resignFirstResponder];
        }
    }
}
- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length > 100) {
        textView.text = [textView.text substringToIndex:100];
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"最多输入100个字符" hideDelay:1];
        [textView resignFirstResponder];
    }
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
    
}
@end
