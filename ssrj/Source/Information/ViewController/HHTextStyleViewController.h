//
//  HHTextStyleViewController.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LMTextStyle.h"

@protocol HHTextStyleViewControllerDelegate <NSObject>

- (void)yf_didChangedTextStyle:(LMTextStyle *)textStyle;

@end

@interface HHTextStyleViewController : UIViewController


@property (nonatomic, weak) id<HHTextStyleViewControllerDelegate> delegate;
@property (nonatomic, strong) LMTextStyle *textStyle;

- (void)reload;

@end
