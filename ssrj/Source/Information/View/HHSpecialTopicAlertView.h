//
//  HHSpecialTopicAlertView.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJTopicCategoryModel.h"
@class HHSpecialTopicAlertView;
@protocol HHSpecialTopicAlertViewDelegate <NSObject>

- (void)specialTopicAlertView:(HHSpecialTopicAlertView *)alertView clickBtnIndex:(NSInteger)index;
- (void)specialTopicAlertViewCanceled;

@end

@interface HHSpecialTopicAlertView : UIView

//index 传 10000 表示没有选中任何专题
- (void)showWithRect:(CGRect)rect modelArray:(NSArray *)modelArray selectBtnIndex:(NSInteger)index;

@property (nonatomic,assign) id<HHSpecialTopicAlertViewDelegate> delegate;
@end
