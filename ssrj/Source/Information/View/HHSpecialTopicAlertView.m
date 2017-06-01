//
//  HHSpecialTopicAlertView.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHSpecialTopicAlertView.h"
#import "UIButton+ImageTitleSpacing.h"
#import "HHMenuPullButton.h"

@interface HHSpecialTopicAlertView()

@property (nonatomic,strong)NSMutableArray *btnArray;
@property (nonatomic,strong)HHMenuPullButton *specialTopicBtn;
@property (nonatomic, strong) NSArray *modelArray;
@property (nonatomic,strong)UIView *box;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic,strong) UIView *containerView;
@end

@implementation HHSpecialTopicAlertView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectIndex = 1000000;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        [self addSubview:self.specialTopicBtn];
        [self addSubview:self.containerView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)showWithRect:(CGRect)rect modelArray:(NSArray *)modelArray selectBtnIndex:(NSInteger)index{
    if (modelArray.count == 0) {
        return;
    }
    if (index > modelArray.count && index != 10000) {
        return;
    }
    
    /**
        设置选择专题按钮
     */
    _selectIndex = index;
    _modelArray = modelArray;
    
    CGRect btnRect = self.specialTopicBtn.frame;
    btnRect.origin = rect.origin;
    if (_selectIndex == 10000) {
        self.specialTopicBtn.nameLabel.text = @"选择专题";
        btnRect.size.width = [self widthWithText:@"选择专题" maxSize:CGSizeMake(kScreenWidth - 2 * btnRect.origin.x, 30) fontSize:14] + 50;
    }else {
        RJTopicCategoryModel *model = modelArray[index];
        _specialTopicBtn.nameLabel.text = model.name;
        btnRect.size.width = [self widthWithText:model.name maxSize:CGSizeMake(kScreenWidth - 2 * btnRect.origin.x, 30) fontSize:14] + 50;
        
    }
    self.specialTopicBtn.frame = btnRect;
    
    
    [self createBtn];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addSubview:self];
}

- (void)createBtn {
    CGRect rect = self.specialTopicBtn.frame;
    self.containerView.frame = CGRectMake(rect.origin.x, CGRectGetMaxY(rect) + 20, kScreenWidth - rect.origin.x * 2, 1);
    [self.containerView removeSubviews];
    [self.btnArray removeAllObjects];
    
    /**
     1.定义用于确定button位置的局部变量
     */
    
    CGFloat padding = 16;
    CGFloat buttonH = 30;
    CGFloat leftAndRightPadding = padding;
    CGFloat topAndBottomPadding = padding;
    CGFloat currentButtonX = leftAndRightPadding;
    CGFloat currentButtonY = topAndBottomPadding;
    
    /**
     2.定义button数组，用于重新排列每行
     */
    
    //存储 包含每行button的数组
    NSMutableArray *allButtonArr = [NSMutableArray array];
    //存储每行button数组
    NSMutableArray *buttonArr = [NSMutableArray array];
    
    for (int i = 0; i < _modelArray.count; i++) {
        RJTopicCategoryModel *model = _modelArray[i];
        
        CGFloat butttonW = [self widthWithText:model.name maxSize:CGSizeMake(self.containerView.size.width, buttonH) fontSize:14] + 30;
        CGFloat buttonX = currentButtonX;
        CGFloat buttonY = currentButtonY;
        
        if (buttonX + butttonW + leftAndRightPadding > self.containerView.size.width) {
            buttonX = leftAndRightPadding;
            buttonY = currentButtonY + (padding + buttonH);
            currentButtonY = buttonY;
            currentButtonX = buttonX;
            
            
            [allButtonArr addObject:[buttonArr copy]];
            [buttonArr removeAllObjects];
        }
        
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, butttonW, buttonH)];
        [btn setTitle:model.name forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn.layer.masksToBounds = YES;
        btn.layer.borderColor = [UIColor colorWithHexString:@"cccccc"].CGColor;
        btn.layer.borderWidth = 1;
        btn.layer.cornerRadius = btn.frame.size.height * 0.5;
        btn.tag = 100 + i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.containerView addSubview:btn];
        [self.btnArray addObject:btn];
        [buttonArr addObject:btn];
        
        buttonX = buttonX + (padding + butttonW);
        currentButtonX = buttonX;
        
    }
    //最后一行如果也需要居中的话，要把最后一行的button添加进来。
    [allButtonArr addObject:[buttonArr copy]];
    
    self.containerView.frame = CGRectMake(rect.origin.x, CGRectGetMaxY(rect) + 20, kScreenWidth - rect.origin.x * 2, currentButtonY + (buttonH + topAndBottomPadding));
    
    /**
     5.根据button数组，重新排列button
     */
    
    for (NSArray *buttonArr in allButtonArr) {
        CGFloat padding = 0;
        CGFloat allButtonWidth = 0;
        for (UIButton * btn in buttonArr) {
            allButtonWidth += btn.frame.size.width;
        }
        padding = (self.containerView.size.width - allButtonWidth) / (buttonArr.count + 1.0);
        
        CGRect lastRect = CGRectZero;
        for (UIButton * btn in buttonArr) {
            CGRect rect = btn.frame;
            rect.origin.x = lastRect.size.width + lastRect.origin.x + padding;
            btn.frame = rect;
            lastRect = rect;
        }
    }
    
    if (_selectIndex < _modelArray.count) {
        UIButton *selectBtn = _btnArray[_selectIndex];
        selectBtn.layer.borderWidth = 0;
        selectBtn.backgroundColor = [UIColor blackColor];
        [selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}
- (HHMenuPullButton *)specialTopicBtn {
    if (!_specialTopicBtn) {
        
        _specialTopicBtn = [[HHMenuPullButton alloc] init];
        _specialTopicBtn.backgroundColor = [UIColor whiteColor];
        _specialTopicBtn.nameLabel.font = [UIFont systemFontOfSize:14];
        _specialTopicBtn.layer.masksToBounds = YES;
        _specialTopicBtn.nameLabel.textColor = [UIColor blackColor];
        _specialTopicBtn.imageName = @"infor_up_1";
        _specialTopicBtn.frame = CGRectMake(0, 0, 1, 30);
        _specialTopicBtn.layer.cornerRadius = 15;
    }
    return _specialTopicBtn;
}
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
        
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.layer.masksToBounds = YES;
        _containerView.layer.cornerRadius = 15;
    }
    return _containerView;
}
#pragma mark - event
- (void)tapHandle:(UITapGestureRecognizer *)recognizer {
    [self removeFromSuperview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(specialTopicAlertViewCanceled)]) {
        [self.delegate specialTopicAlertViewCanceled];
    }
}
- (void)btnClick:(UIButton *)button {
    for (UIButton *btn in self.btnArray) {
        btn.backgroundColor = [UIColor whiteColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.layer.borderWidth = 1;
    }
    button.layer.borderWidth = 0;
    button.backgroundColor = [UIColor blackColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self removeFromSuperview];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(specialTopicAlertView:clickBtnIndex:)]) {
        [self.delegate specialTopicAlertView:self clickBtnIndex:button.tag - 100];
    }
}
#pragma mark - other
- (NSMutableArray *)btnArray {
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}

- (CGFloat)widthWithText:(NSString *)text maxSize:(CGSize)size fontSize:(CGFloat)fontSize{
    CGRect rect = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:fontSize]} context:nil];
    return rect.size.width;
}
@end
