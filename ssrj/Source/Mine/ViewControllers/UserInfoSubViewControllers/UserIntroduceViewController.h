//
//  UserIntroduceViewController.h
//  ssrj
//
//  Created by YiDarren on 16/7/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@protocol UserIntroduceViewControllerDelegate <NSObject>

//代理方法
- (void)reloadUserInfoData;

@end


@interface UserIntroduceViewController : RJBasicViewController

@property (weak, nonatomic) id<UserIntroduceViewControllerDelegate> delegate;

@end
