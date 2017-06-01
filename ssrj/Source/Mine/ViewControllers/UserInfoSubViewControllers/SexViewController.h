//
//  SexViewController.h
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol SexViewControllerDelegate <NSObject>

//代理方法
- (void)reloadUserInfoData;

@end

@interface SexViewController : RJBasicViewController

@property (weak, nonatomic) id<SexViewControllerDelegate> delegate;

@end
