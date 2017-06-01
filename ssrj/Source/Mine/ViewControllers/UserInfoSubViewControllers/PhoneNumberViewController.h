//
//  PhoneNumberViewController.h
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol PhoneNumberViewControllerDelegate <NSObject>

//代理方法
- (void)reloadUserInfoData;

@end


@interface PhoneNumberViewController : RJBasicViewController

@property (weak, nonatomic) id<PhoneNumberViewControllerDelegate> delegate;

@end
