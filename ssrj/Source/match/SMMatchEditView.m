//
//  SMMatchEditView.m
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "SMMatchEditView.h"
#import "UIButton+ImageTitleSpacing.h"
//height = 60
@implementation SMMatchEditView
{
    NSMutableArray *btnArray;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
        
        btnArray = [NSMutableArray array];
        NSArray *imageNormalArr = @[@"match_delete",@"match_flip",@"match_capy",@"match_caijian",@"match_onlayer",@"match_underlayer"];
        
        NSArray *imageDiseNabledArr = @[@"match_delete2",@"match_flip2",@"match_capy2",@"match_caijian2",@"match_onlayer2",@"match_underlayer2"];
        NSArray *titleArr = @[@"删除",@"翻转",@"复制",@"剪切",@"上移",@"下移"];
        
        CGFloat btnW = frame.size.width / imageNormalArr.count;
        CGFloat btnH = 50;
        
        for (int i = 0; i < imageNormalArr.count; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i * btnW, 0, btnW, btnH)];
            [btn setImage:[UIImage imageNamed:imageNormalArr[i]] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:imageDiseNabledArr[i]] forState:UIControlStateDisabled];
            [btn setTitle:titleArr[i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
            btn.titleLabel.font = [UIFont systemFontOfSize:12];
            btn.tag = 20 + i;
            [btn layoutButtonWithEdgeInsetsStyle:MKButtonEdgeInsetsStyleTop imageTitleSpace:10];
            [self addSubview:btn];
            
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [btnArray addObject:btn];
            
            btn.trackingId = [NSString stringWithFormat:@"%@&SMMatchEditView&button&index=%d",vcName,i];
        }
        
        
        UIView *topLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 1)];
        topLine.backgroundColor = [UIColor colorWithHexString:@"#e5e5e5"];
        [self addSubview:topLine];
    }
    return self;
}
- (void)setMatchEditViewWithButtonType:(SMMatchEditButtonType)type enabled:(BOOL)enabled {
    UIButton *btn = btnArray[type];
    btn.enabled = enabled;
}
- (void)setEditviewStateWithMatchImage:(SMMatchImageView *)imageView {
    //设置编辑条的能否点击的状态（删除，翻转复制永远可以点击，不用设置。需设置剪切、上移、下移的状态）
    
    //剪切
    if (imageView.goodsModel.ID.length == 0) {
        [self setMatchEditViewWithButtonType:SMMatchEditButtonTypeCutout enabled:NO];
    }else {
        [self setMatchEditViewWithButtonType:SMMatchEditButtonTypeCutout enabled:YES];
    }
    //下移
    if ([imageView.superview.subviews firstObject] == imageView) {
        [self setMatchEditViewWithButtonType:SMMatchEditButtonTypeBack enabled:NO];
    }else {
        [self setMatchEditViewWithButtonType:SMMatchEditButtonTypeBack enabled:YES];
    }
    //上移
    if ([imageView.superview.subviews lastObject] == imageView) {
        [self setMatchEditViewWithButtonType:SMMatchEditButtonTypeForward enabled:NO];
    }else {
        [self setMatchEditViewWithButtonType:SMMatchEditButtonTypeForward enabled:YES];
    }
}
- (void)btnClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickEditView:buttonType:)]) {
        [self.delegate didClickEditView:self buttonType:sender.tag - 20];
    }
}
@end
