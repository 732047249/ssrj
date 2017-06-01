//
//  RJAccountManager.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJAccountModel.h"
static NSString * const kAccountToken = @"CurrentAccountToken";
static NSString * const kAccount = @"CurrentAccount";
static NSString * const kNotificationLoginSuccess = @"Loginsuccess";
static NSString * const kNotificationRegistSuccess = @"Registsuccess";
static NSString * const kNotificationLogoutSuccess = @"Logoutsuccess";

static NSString * const kNotificationCartNumberChanged = @"CartNumberChanged";

static NSString * const isAccountHasZuoTiKey = @"isAccountHasZuoTiKey";

@interface RJAccountManager : NSObject
@property (strong, nonatomic) RJAccountModel * account;
@property (strong, nonatomic) NSString * token;
@property (nonatomic, strong) NSString *userDocumentPath;
/**
 *  2.2.0 Add token失效机制  7天未登录过后台会删除token创建新的  每次启动调用接口激活下token
 */
@property (nonatomic, assign) BOOL isCheckTokenAvaiable;
+ (instancetype)sharedInstance;

- (void)setup;
// 是否有账户登录
- (BOOL)hasAccountLogin;
// 注销账户
- (void)unregisterAccountWithHud:(BOOL)flag;
//注册
- (void)registerAccount:(RJAccountModel *)account;

/**
 *  请求购物车最新信息
 */
- (void)reloadCartNumber;
//获取登录的Nav
- (UINavigationController *)getLoginVc;

@end
