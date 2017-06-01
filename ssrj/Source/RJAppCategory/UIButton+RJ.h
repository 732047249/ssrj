//
//  UIButton+RJ.h
//  ViewTest
//
//  Created by CC on 16/12/27.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+RJ.h"
#import "RJLabel.h"
@interface UIButton (RJ)
@property (nonatomic, strong) RJLabel * numView;
- (void)showLabel;
- (void)removeLabel;
@end
