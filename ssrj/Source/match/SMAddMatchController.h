//
//  SMAddMatchController.h
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"

@interface SMAddMatchController : UIViewController
/** 点击导航条的上下滚动按钮 */
@property (nonatomic,copy) void (^switchBlock)();
@property (nonatomic,strong)UIButton *switchBtn;

@property (nonatomic,strong)HMSegmentedControl *segmentedControl;
@end
