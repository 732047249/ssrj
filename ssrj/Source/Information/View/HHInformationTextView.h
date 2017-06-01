//
//  HHInformationTextView.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HHMenuPullButton.h"
@class HHInformationTextView;
@protocol HHInformationTextViewDelegate <NSObject>
/** 点击封面 */
- (void)informationTextView:(HHInformationTextView *)informationTextView didClickCover:(UIImageView *)coverImageView;

@end

@interface HHInformationTextView : UITextView
/** 标题输入框 */
@property (nonatomic, strong) UITextField *titleTextField;
/** 封面 */
@property (nonatomic, strong) UIImageView *coverImageView;
/** 专题按钮 */
@property (nonatomic, strong) HHMenuPullButton *selectSpecialTopicBtn;
@property (nonatomic, assign) id<HHInformationTextViewDelegate> clickCoverDelegate;
@property (nonatomic, strong) UILabel *placeholderLabel;
/** 清空 */
- (void)deleteAllContent;
@end
