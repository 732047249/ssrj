//
//  SegmentView.h
//  categoryDemo
//
//  Created by MFD on 16/5/24.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "A-Z_brandsTableVIew.h"
typedef void(^btnClickBlock)(NSInteger index);

@interface SegmentView : UIView
@property (nonatomic,strong) UIColor *titleNomalColor;
@property (nonatomic,strong) UIColor *titleSelectColor;
@property (nonatomic,strong) UIFont *titleFont;
@property (nonatomic,assign) NSInteger defaultIndex;
//点击后的回调
@property (nonatomic,copy) btnClickBlock block;

- (instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titleArray clickBlock:(btnClickBlock)block;
@end
