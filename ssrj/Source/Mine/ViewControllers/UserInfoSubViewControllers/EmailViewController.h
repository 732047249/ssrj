//
//  EmailViewController.h
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol EmailViewControllerDelegate <NSObject>

//代理方法
- (void)reloadUserInfoData;

@end


@interface EmailViewController : RJBasicViewController

@property (weak, nonatomic) id<EmailViewControllerDelegate> delegate;

@end
