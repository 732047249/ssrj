
#import "RJAccountManager.h"
#import "JPUSHService.h"
#import "EaseMob.h"
#import "EMIMHelper.h"
@interface RJAccountManager ()

@end

@implementation RJAccountManager


+ (instancetype)sharedInstance {
	static RJAccountManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
   
    });
	return sharedInstance;
}
- (void)setup
{
    // 获取当前账号
    [self getCurAccount];
    //注册成功登录通知
    [[NSNotificationCenter defaultCenter] addObserver:[RJAccountManager sharedInstance] selector:@selector(loginAction:) name:kNotificationLoginSuccess object:nil];
    //注册退出登录通知
    [[NSNotificationCenter defaultCenter] addObserver:[RJAccountManager sharedInstance] selector:@selector(logoutAction:) name:kNotificationLogoutSuccess object:nil];
    
    //    [self registerAccount:_account];
}
- (void)getCurAccount{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:kAccount];
    if (str) {
        RJAccountModel *model = [[RJAccountModel alloc]initWithString:str error:nil];
        if (model) {
            self.account = nil;
            self.account = model;
        }
    }else{
        self.account = nil;
    }
}
-(NSString *)token{
    if (self.account) {
        return self.account.token;
    }
    return nil;
}
-(void)setAccount:(RJAccountModel *)account{
    _account = nil;
    _account = account;
}
- (BOOL)hasAccountLogin{
    if (_account && ![_account.userid isEqualToString:@"0"]) {
        return YES;
    }
    return NO;
}
- (void)registerAccount:(RJAccountModel *)account{
    if (account == nil) {
        return;
    }
    self.account = account;
    //发送通知
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRegistSuccess object:account];
    NSString *str = [account toJSONString];
    [[NSUserDefaults standardUserDefaults]setObject:str forKey:kAccount];
    [[NSUserDefaults standardUserDefaults]synchronize];
    //更改用户文件路径什么的
}
- (void)unregisterAccountWithHud:(BOOL)flag{
    //TODO: 消除用户一些个人信息 比如搜索记录等等
    if (flag) {
        [HTUIHelper addHUDToWindowWithString:@"正在退出..."];
    }
    self.account = nil;

    NSUserDefaults *userDefatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefatluts dictionaryRepresentation];
    for (NSString *key in [dic allKeys]) {
        /**
         *  一些信息没必要删除
         */
        if ([key isEqualToString:@"CCFirstInVersionKey"] || [key isEqualToString:RJFirstInZuoTi]|| [key isEqualToString:RJFirstInDaPei] || [key isEqualToString:RJFirstInGouYiZhuShou]||[key isEqualToString:RJCustomerDeviceIDKey]||[key isEqualToString:CCLuanchADDataKey]||[key isEqualToString:RJFirstInHome]||[key isEqualToString:RJFirstInChuanDa]||[key isEqualToString:RJFirstInGoodList]) {
            continue;
        }
        
        [userDefatluts removeObjectForKey:key];
        [userDefatluts synchronize];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLogoutSuccess object:nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
    if (flag) {
        [HTUIHelper removeHUDToWindowWithEndString:@"退出成功" image:nil delyTime:2.0];
    }
}

- (void)reloadCartNumber{
    if ([self hasAccountLogin]) {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/cart/getCartQuantity.jhtml"];
        
//        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
        
        [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    NSNumber *titleNumber = [responseObject objectForKey:@"data"];
                    if (titleNumber) {
                        [RJAccountManager sharedInstance].account.cartProductQuantity = titleNumber;
                        [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
                    }
                }
                else {
                    //                    [self setTitle:@"" forState:UIControlStateNormal];
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
        }];
    }
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLoginSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationLogoutSuccess object:nil];
}
- (void)loginAction:(NSNotification *)sender{
    if (self.account.userid) {
        [JPUSHService setTags:nil alias:[RJAccountManager sharedInstance].account.userid fetchCompletionHandle:^(int iResCode, NSSet *iTags, NSString *iAlias) {
            NSLog(@"============rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, iTags , iAlias);
        }];
        /**
         *  环信登录
         */
        [[EMIMHelper defaultHelper] loginEasemobSDK];

    }
}
- (void)logoutAction:(NSNotification *)sender{
    if (!self.account.userid) {
        [JPUSHService setAlias:@"" callbackSelector:nil object:nil];
    }
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:NO];
//    [EMIMHelper defaultHelper].username = nil;
//    [EMIMHelper defaultHelper].password = nil;
    [[EMIMHelper defaultHelper]refreshHelperData];
}
- (UINavigationController *)getLoginVc{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
    return loginNav;
}
@end
