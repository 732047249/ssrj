//
//  CartViewController.h
//  ssrj
//
//  Created by CC on 16/5/31.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
@interface CartViewController : RJBasicViewController
/**
 *  1.跳转到支付页 ->支付后直接home然后回App 或返回App
    2.支付成功或失败->去订单详情界面 ->返回按钮 回到购物车 需要重新刷新请求
 */
@property (assign, nonatomic) BOOL  shouldReloadView;
@end
