//
//  AskForTransPayWayViewController.h
//  ssrj
//
//  Created by YiDarren on 16/9/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@interface AskForTransPayWayViewController : RJBasicViewController
//可提现积分
@property (strong, nonatomic) NSString *totalPoints;
//积分对应的金额
@property (strong, nonatomic) NSString *maxAmount;
//最多提现金额(提示)
@property (strong, nonatomic) NSString *topAmount;

@end
