//
//  SMMatchEditView.h
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
// 编辑条

#import <UIKit/UIKit.h>
#import "SMMatchImageView.h"
typedef NS_ENUM(NSInteger, SMMatchEditButtonType) {
    SMMatchEditButtonTypeRemove,
    SMMatchEditButtonTypeFlip,
    SMMatchEditButtonTypeClone,
    SMMatchEditButtonTypeCutout,
    SMMatchEditButtonTypeForward,
    SMMatchEditButtonTypeBack//下移
};

@class SMMatchEditView;
@protocol  SMMatchEditViewDelegate<NSObject>

- (void)didClickEditView:(SMMatchEditView *)editView buttonType:(SMMatchEditButtonType)buttonType;
@end

@interface SMMatchEditView : UIView
@property (nonatomic,weak)id<SMMatchEditViewDelegate> delegate;

//设置编辑条的能否点击的状态
- (void)setMatchEditViewWithButtonType:(SMMatchEditButtonType)type enabled:(BOOL)enabled;
//根据SMMatchImageView 设置编辑条的能否点击的状态
- (void)setEditviewStateWithMatchImage:(SMMatchImageView *)imageView;
@end
