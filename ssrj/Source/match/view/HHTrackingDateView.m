//
//  HHTrackingDateView.m
//  dd
//
//  Created by 夏亚峰 on 17/2/28.
//  Copyright © 2017年 MFD. All rights reserved.
//

#import "HHTrackingDateView.h"
#import "HHTrackingDateItem.h"
#import "Masonry.h"
//#import "HHConst.h"

#define item_line_height 20
#define item_height 50

@interface HHTrackingDateView ()<HHTrackingDateItemDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIButton *commitButton;
@property (nonatomic, strong) HHTrackingDateItem *beginItem;
@property (nonatomic, strong) HHTrackingDateItem *endItem;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, copy) NSString *beginDateString;
@property (nonatomic, copy) NSString *endDateString;

@end

@implementation HHTrackingDateView

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static HHTrackingDateView *single;
    dispatch_once(&onceToken, ^{
        single = [[HHTrackingDateView alloc] init];
    });
    return single;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
        [self addSubview:self.effectView];
        [self addSubview:self.containerView];
        self.beginItem = [[HHTrackingDateItem alloc] init];
        [self item:self.beginItem title:@"开始时间" dateString:self.beginDateString];
        self.endItem = [[HHTrackingDateItem alloc]init];
        [self item:self.endItem title:@"结束时间" dateString:self.endDateString];
        self.commitButton = [[UIButton alloc] init];
        [self.commitButton setTitle:@"完成" forState:UIControlStateNormal];
        [self.commitButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.containerView addSubview:self.commitButton];
        [self.commitButton addTarget:self action:@selector(commitButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self setupRect];
        
    }
    return self;
}
- (void)commonInit {
    self.beginDateString = @"2016-01-01";
    self.endDateString = [self now];
}
- (NSString *)now {
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
//    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

- (void)item:(HHTrackingDateItem *)item title:(NSString *)title dateString:(NSString *)dateString{
    if ([dateString containsString:@" "]) {
        dateString = [[dateString componentsSeparatedByString:@" "] firstObject];
    }
    item.itemName = title;
    item.delegate = self;
    item.dateString = dateString;
    [self.containerView addSubview:item];
}
- (void)setupRect {
    
    [self.beginItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView).offset(10);
        make.top.equalTo(self.containerView).offset(10);
        make.height.mas_equalTo(item_height);
    }];
    
    [self.endItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.beginItem);
        make.top.equalTo(self.beginItem.mas_bottom).offset(20);
        make.height.mas_equalTo(item_height);
    }];
    
    [self.commitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.containerView);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(40);
        make.top.mas_equalTo(self.endItem.mas_bottom).offset(20);
    }];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(70);
        make.centerX.equalTo(self);
        make.right.equalTo(self.beginItem).offset(10);
        make.height.mas_offset(190 + 10);
    }];
    
    [self layoutIfNeeded];
    NSLog(@"%@",NSStringFromCGRect(self.beginItem.frame));
    NSLog(@"%.f",CGRectGetMaxY(self.commitButton.frame));
}

- (void)trackingDateItem:(HHTrackingDateItem *)trackingDateItem didSetupDate:(NSString *)dateString {
    
}
- (void)show {
    if (self.superview) {
        return;
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    self.frame = keyWindow.bounds;
    self.effectView.frame = self.bounds;
    [keyWindow addSubview:self];
}
- (void)dismiss {
    [self removeFromSuperview];
}
- (void)commitButtonClick {
    [self.beginItem endEditing:YES];
    [self.endItem endEditing:YES];
    if (!self.beginItem.dateString.length || !self.endItem.dateString.length) {
        [HTUIHelper addHUDToView:self withString:@"起始时间输入内容有误" hideDelay:0.5];
        return;
    }
    if (!self.endItem.dateString.length || !self.endItem.dateString.length) {
        [HTUIHelper addHUDToView:self withString:@"结束时间输入内容有误" hideDelay:0.5];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:self.beginItem.dateString forKey:@"HHUserDefaults_beginDateString"];
    [[NSUserDefaults standardUserDefaults] setObject:self.endItem.dateString forKey:@"HHUserDefaults_endDateString"];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [[RJAppManager sharedInstance] scanAllViewWithView:window];
    [self dismiss];
}
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.cornerRadius = 15;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
}
- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *beffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        _effectView = [[UIVisualEffectView alloc]initWithEffect:beffect];
    }
    return _effectView;
}
@end
