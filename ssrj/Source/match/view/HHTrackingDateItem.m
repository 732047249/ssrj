//
//  HHTrackingDateItem.m
//  dd
//
//  Created by 夏亚峰 on 17/2/28.
//  Copyright © 2017年 MFD. All rights reserved.
//

#import "HHTrackingDateItem.h"
#import "Masonry.h"

#define row_height 10

@interface HHTrackingDateItem ()<UITextFieldDelegate> {
    NSString *_dateString;
}
@property (nonatomic, strong) UILabel *beginOrEndDateLabel;
@property (nonatomic, strong) UILabel *yearLabel;
@property (nonatomic, strong) UILabel *monthLabel;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UITextField *yearTextField;
@property (nonatomic, strong) UITextField *monthTextField;
@property (nonatomic, strong) UITextField *dayTextField;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) CGFloat textFieldWidth;

@end

@implementation HHTrackingDateItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configParams];
        self.beginOrEndDateLabel = [[UILabel alloc] init];
        [self label:self.beginOrEndDateLabel fontsize:self.fontsize textColor:self.textColor title:self.itemName];
        self.yearLabel = [[UILabel alloc] init];
        [self label:self.yearLabel fontsize:self.fontsize textColor:self.textColor title:@"年"];
        self.monthLabel = [[UILabel alloc] init];
        [self label:self.monthLabel fontsize:self.fontsize textColor:self.textColor title:@"月"];
        self.dayLabel = [[UILabel alloc] init];
        [self addSubview:self.dayLabel];
        [self label:self.dayLabel fontsize:self.fontsize textColor:self.textColor title:@"日"];
        self.yearTextField = [[UITextField alloc] init];
        self.yearTextField.keyboardType = UIKeyboardTypeNumberPad;
        [self textField:self.yearTextField text:@"2017"];
        self.monthTextField = [[UITextField alloc]init];
        self.monthTextField.keyboardType = UIKeyboardTypeNumberPad;
        [self textField:self.monthTextField text:@"11"];
        self.dayTextField = [[UITextField alloc] init];
        self.dayTextField.keyboardType = UIKeyboardTypeNumberPad;
        [self textField:self.dayTextField text:@"13"];
        
        [self setupRect];
    }
    return self;
}
- (void)configParams {
    self.itemName = @"起始时间";
    self.fontsize = 14.f;
    self.textColor = [UIColor blackColor];
    self.textFieldWidth = 50;
}
- (void)label:(UILabel *)label fontsize:(CGFloat)fontsize textColor:(UIColor *)textColor title:(NSString *)title {
    label.textColor = textColor;
    label.text = title;
    label.font = [UIFont systemFontOfSize:fontsize];
    [label sizeToFit];
    [self addSubview:label];
}
- (void)textField:(UITextField *)textField text:(NSString *)text {
    textField.text = text;
    textField.font = [UIFont systemFontOfSize:self.fontsize];
    textField.textAlignment = NSTextAlignmentRight;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.delegate = self;
    [self addSubview:textField];
}
- (void)setItemName:(NSString *)itemName {
    _itemName = itemName;
    self.beginOrEndDateLabel.text = itemName;
    [self setNeedsLayout];
}
- (void)setFontsize:(CGFloat)fontsize {
    _fontsize = fontsize;
    self.yearLabel.font = [UIFont systemFontOfSize:fontsize];
    self.monthLabel.font = [UIFont systemFontOfSize:fontsize];
    self.dayLabel.font = [UIFont systemFontOfSize:fontsize];
    self.yearTextField.font = [UIFont systemFontOfSize:fontsize];
    self.monthTextField.font = [UIFont systemFontOfSize:fontsize];
    self.dayTextField.font = [UIFont systemFontOfSize:fontsize];
    [self setNeedsLayout];
}
- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    self.yearLabel.textColor = textColor;
    self.monthLabel.textColor = textColor;
    self.dayLabel.textColor = textColor;
}
- (void)setDateString:(NSString *)dateString {
    _dateString = dateString;
    NSArray *arr = [dateString componentsSeparatedByString:@"-"];
    if (arr.count == 3) {
        self.yearTextField.text = arr[0];
        self.monthTextField.text = arr[1];
        self.dayTextField.text = arr[2];
    }
}
- (NSString *)dateString {
    return [[NSString stringWithFormat:@"%@-%@-%@",self.yearTextField.text,self.monthTextField.text,self.dayTextField.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)setupRect {
    NSArray *arr = @[self.beginOrEndDateLabel,self.yearLabel,self.monthLabel,self.dayLabel,self.yearTextField,self.monthTextField,self.dayTextField];
    [arr mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
    }];
    [self.beginOrEndDateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.width.mas_equalTo(self.beginOrEndDateLabel.bounds.size.width);
    }];
    [self.yearTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beginOrEndDateLabel.mas_right).offset(row_height);
        make.width.mas_equalTo(self.textFieldWidth);
    }];
    [self.yearLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.yearTextField.mas_right).offset(row_height);
        make.width.mas_equalTo(self.yearLabel.bounds.size.width);
    }];
    [self.monthTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.yearLabel.mas_right).offset(row_height);
        make.width.mas_equalTo(self.textFieldWidth);
    }];
    [self.monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.monthTextField.mas_right).offset(row_height);
        make.width.mas_equalTo(self.monthLabel.bounds.size.width);
    }];
    [self.dayTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.monthLabel.mas_right).offset(row_height);
        make.width.mas_equalTo(self.textFieldWidth);
    }];
    [self.dayLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.dayTextField.mas_right).offset(row_height);
        make.width.mas_equalTo(self.dayLabel.bounds.size.width);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.superview) {
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(312);
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.yearTextField) {
        if ([textField.text intValue] == 0 || [textField.text intValue] > 9999) {
            textField.text = @"2016";
        }else {
            textField.text = [NSString stringWithFormat:@"%.4d",[textField.text intValue]];
        }
    }
    if (textField == self.monthTextField || textField == self.dayTextField) {
        
        if ([textField.text intValue] == 0 || [textField.text intValue] > 31) {
            textField.text = @"01";
        }else {
            textField.text = [NSString stringWithFormat:@"%.2d",[textField.text intValue]];
        }
    }
}
@end
