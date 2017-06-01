//
//  AppDelegate.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EaseMob.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,IChatManagerDelegate>
@property (strong, nonatomic) UIWindow *window;
+ (instancetype)shareInstance;


@end

