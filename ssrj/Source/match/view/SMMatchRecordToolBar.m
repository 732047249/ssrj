//
//  SMMatchRecordToolBar.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchRecordToolBar.h"
#import "Masonry.h"
@implementation SMMatchRecordToolBar
{
    NSMutableArray *btnArray;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        btnArray = [NSMutableArray array];
        UIButton *backBtn = [[UIButton alloc] init];
        backBtn.tag = 200;
        [backBtn setImage:[UIImage imageNamed:@"match_shangyibu1"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage imageNamed:@"match_shangyibu2"] forState:UIControlStateDisabled];
        backBtn.enabled = NO;
        [backBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:backBtn];
        
        UIButton *forwordBtn = [[UIButton alloc] init];
        forwordBtn.tag = 201;
        [forwordBtn setImage:[UIImage imageNamed:@"match_xiayibu"] forState:UIControlStateNormal];
        [forwordBtn setImage:[UIImage imageNamed:@"match_xiayibu1"] forState:UIControlStateDisabled];
        forwordBtn.enabled = NO;
        [forwordBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [forwordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:forwordBtn];
        
        UIButton *oringeBtn = [[UIButton alloc] init];
        oringeBtn.tag = 202;
        [oringeBtn setImage:[UIImage imageNamed:@"match_fangda"] forState:UIControlStateNormal];
        [oringeBtn setImage:[UIImage imageNamed:@"match_fangda2"] forState:UIControlStateDisabled];
        oringeBtn.enabled = NO;
        [oringeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [oringeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:oringeBtn];
        
        UIView *topLine = [[UIView alloc]init];
        topLine.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
        [self addSubview:topLine];
        
        [btnArray addObject:backBtn];
        [btnArray addObject:forwordBtn];
        [btnArray addObject:oringeBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.width.mas_equalTo(60);
        }];
        [forwordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(backBtn);
            make.left.equalTo(backBtn.mas_right);
            make.width.mas_equalTo(60);
        }];
        [oringeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self);
            make.width.mas_equalTo(60);
        }];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self);
            make.height.mas_equalTo(1);
        }];
        
        NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
        backBtn.trackingId = [NSString stringWithFormat:@"%@&SMMatchRecordToolBar&backBtn",vcName];
        forwordBtn.trackingId = [NSString stringWithFormat:@"%@&SMMatchRecordToolBar&forwordBtn",vcName];
        oringeBtn.trackingId = [NSString stringWithFormat:@"%@&SMMatchRecordToolBar&oringeBtn",vcName];
    }
    return self;
}
- (void)setRecordBarWithButtonType:(SMMatchRecordToolBarType)type enabled:(BOOL)enabled {
    
    UIButton *btn = btnArray[type];
    btn.enabled = enabled;
}
- (void)btnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickRecordToolBar:buttonType:)]) {
        [self.delegate didClickRecordToolBar:self buttonType:sender.tag - 200];
    }
}

@end
