//
//  SMMatchRecordToolBar.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger, SMMatchRecordToolBarType) {
    SMMatchRecordToolBarTypeBack,
    SMMatchRecordToolBarTypeForword,
    SMMatchRecordToolBarTypeAllScreen
};
@class SMMatchRecordToolBar;
@protocol  SMMatchRecordToolBarDelegate<NSObject>

- (void)didClickRecordToolBar:(SMMatchRecordToolBar *)toolBar buttonType:(SMMatchRecordToolBarType)tooBarType;

@end
@interface SMMatchRecordToolBar : UIView

@property (nonatomic,weak)id<SMMatchRecordToolBarDelegate> delegate;
- (void)setRecordBarWithButtonType:(SMMatchRecordToolBarType)type enabled:(BOOL)enabled;
@end
