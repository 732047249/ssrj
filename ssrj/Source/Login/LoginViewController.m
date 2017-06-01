
#import "LoginViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import <Foundation/Foundation.h>
#import "RegisterViewController.h"
#import "UMSocialSinaSSOHandler.h"
#import "BindTelephoneController.h"

#define LayoutWidth          SCREEN_WIDTH/320

@interface LoginViewController ()<UITextFieldDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) id  keyboardShowObserver;
@property (strong, nonatomic) id  keyboardHideObserver;

@property (strong, nonatomic) UIButton *weixinLoginBtn;
@property (strong, nonatomic) UIButton *qqLoginBtn;
@property (strong, nonatomic) UIButton *weiboLoginBtn;

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passWordTextField;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailViewTopConstraint;

@property (weak, nonatomic) IBOutlet UIButton *signinButton;

//用来取其Y值，以动态确定第三方登录的Y值
@property (weak, nonatomic) IBOutlet UILabel *thirdLoadButton;

@end

@implementation LoginViewController




-(void)viewDidLoad{
    [super viewDidLoad];
    
    /****************************************************/
    /**
     *  微信和qq没安装
     */
    BOOL isQQInstalled = [TencentOAuth iphoneQQInstalled];
    BOOL isWeiCatInstalled = [WXApi isWXAppInstalled];

    CGFloat Yposition = _thirdLoadButton.frame.origin.y + 21;
    
    CGFloat buttonSpacing = 55*SCREEN_WIDTH/320/2;
    
    if (DEVICE_IS_IPHONE6) {
        self.emailViewTopConstraint.constant +=10;
        Yposition+=10;
    }
    if (DEVICE_IS_IPHONE6Plus) {
        self.emailViewTopConstraint.constant+=15;
        Yposition+=15;
    }

    //sina登录
    self.weiboLoginBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, Yposition +35, 55, 55)];
    self.weiboLoginBtn.center = CGPointMake(self.view.center.x, self.weiboLoginBtn.center.y);
    [self.weiboLoginBtn setBackgroundImage:GetImage(@"weibo") forState:UIControlStateNormal];
    [self.weiboLoginBtn addTarget:self action:@selector(weiboLoginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_weiboLoginBtn];

    /**
     *  使用代码写登陆按钮
     */
    if (isQQInstalled) {
        
        self.qqLoginBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.weiboLoginBtn.xPosition - 40*LayoutWidth -55, self.weiboLoginBtn.yPosition, 55, 55)];
        [self.qqLoginBtn setBackgroundImage:GetImage(@"qq") forState:UIControlStateNormal];
        [self.qqLoginBtn addTarget:self action:@selector(qqLoginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_qqLoginBtn];
        
    }

    //微信登陆
    if (isWeiCatInstalled) {
        self.weixinLoginBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.weiboLoginBtn.xPosition + 40*LayoutWidth +55, self.weiboLoginBtn.yPosition, 55, 55)];
        [self.weixinLoginBtn setBackgroundImage:GetImage(@"weixin") forState:UIControlStateNormal];
        
        [self.weixinLoginBtn addTarget:self action:@selector(weixinLoginBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:_weixinLoginBtn];
        
        if (!isQQInstalled) {
            [self.weixinLoginBtn setOrigin:CGPointMake(self.weixinLoginBtn.origin.x - buttonSpacing -15*LayoutWidth, self.weixinLoginBtn.origin.y)];
            [self.weiboLoginBtn setOrigin:CGPointMake(self.weiboLoginBtn.origin.x - buttonSpacing -15*LayoutWidth, self.weiboLoginBtn.origin.y)];
        }
        
    }else{

        if (isQQInstalled) {
            [self.qqLoginBtn setOrigin:CGPointMake(self.qqLoginBtn.origin.x + buttonSpacing +15*LayoutWidth, self.qqLoginBtn.origin.y)];
            [self.weiboLoginBtn setOrigin:CGPointMake(self.weiboLoginBtn.origin.x + buttonSpacing +15*LayoutWidth, self.weiboLoginBtn.origin.y)];
        }else{
            
            self.weiboLoginBtn.center = CGPointMake(self.view.center.x, self.weiboLoginBtn.center.y);
            
        }
        
    }
    
    //登录按钮
    self.loginButton.layer.cornerRadius = 20.0f;
    self.loginButton.clipsToBounds = YES;
    //微信登录
    self.weixinLoginBtn.layer.cornerRadius = 27.5f;
    self.weixinLoginBtn.clipsToBounds = YES;
    //qq登录
    self.qqLoginBtn.layer.cornerRadius = 27.5f;
    self.qqLoginBtn.clipsToBounds = YES;
    //微博登录
    self.weiboLoginBtn.layer.cornerRadius = 27.5f;
    self.weiboLoginBtn.clipsToBounds = YES;
    
    self.scrollView.delegate = self;
    
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    if (self.emailTextField.isFirstResponder) {
        [self.emailTextField resignFirstResponder];
    }
    if (self.passWordTextField.isFirstResponder) {
        [self.passWordTextField resignFirstResponder];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (self.emailTextField.isFirstResponder) {
        [self.emailTextField resignFirstResponder];
    }
    if (self.passWordTextField.isFirstResponder) {
        [self.passWordTextField resignFirstResponder];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    UIScrollView *sv = self.scrollView;
    self.keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {

        CGRect keyBoardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat keyboardHeight = keyBoardFrame.size.height;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo [UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        sv.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        [UIView commitAnimations];
        
    }];
    
    self.keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo [UIKeyboardAnimationDurationUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        sv.contentInset = UIEdgeInsetsZero;
        [UIView commitAnimations];
    }];
    
    [MobClick beginLogPageView:@"登录页面"];
    [TalkingData trackPageBegin:@"登录页面"];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardHideObserver];
    
    self.keyboardShowObserver = nil;
    self.keyboardHideObserver = nil;
    
    [MobClick endLogPageView:@"登录页面"];
    [TalkingData trackPageEnd:@"登录页面"];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 100) {
        
        if (textField.text.length == 0) {
            [HTUIHelper addHUDToView:self.view withString:@"帐号还未填写" hideDelay:1];
            return NO;
        }
        
        [self.passWordTextField becomeFirstResponder];
    } else {
        
        if (textField.text.length == 0) {
            [HTUIHelper addHUDToView:self.view withString:@"密码还未填写" hideDelay:1];
            return NO;
        }
        
        [self.passWordTextField resignFirstResponder];
    }
    return YES;
}

- (IBAction)undoButtonAction:(id)sender {
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)forgetKeyButtonAction:(id)sender {
    
    //    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *forgerKeyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FindOutTheKeyRootViewController"];
    
    [self.navigationController pushViewController:forgerKeyVC animated:YES];
    
}

- (void)weixinLoginBtnAction:(id)sender {
    
    
    NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:UMSocialSnsTypeWechatSession];
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            UMSocialAccountEntity *snsAccount = [dict valueForKey:platformName];
            
            NSDictionary *parmas = @{@"access_token":snsAccount.accessToken ,@"openid":snsAccount.usid,@"unionid":snsAccount.usid,@"nickname":snsAccount.userName,@"avatar":snsAccount.iconURL,@"gender":@"1",@"country":@"",@"province":@"",@"token":@"",@"city":@"",@"clientType":@"ios"};
            
            ZHRequestInfo *requestInfo = [ZHRequestInfo new];
            
            requestInfo.URLString = @"/api/v5/login/thirdparty/weixinLoginPlugin.jhtml";
            
            [requestInfo.postParams setDictionary:parmas];
            [HTUIHelper addHUDToWindowWithString:@""];
            [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"%@",requestInfo.operation);
                if ([responseObject objectForKey:@"state"]) {
                    NSNumber *state = [responseObject objectForKey:@"state"];
                    if (state.boolValue == 0) {
                        NSDictionary *dic = responseObject[@"data"];
                        RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:dic error:nil];
                        if (model) {
                            
                            [HTUIHelper removeHUDToWindowWithEndString:@"登录成功" image:nil delyTime:1];
                            [[RJAccountManager sharedInstance]registerAccount:model];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
                            [self dismissViewControllerAnimated:YES completion:^{
                            }];
                        }
                        else {
                            
                            [HTUIHelper removeHUDToWindowWithEndString:@"登录失败" image:nil delyTime:1];
                        }
                        
                    }else{
                        
                        [HTUIHelper removeHUDToWindow];
                        [HTUIHelper alertMessage:responseObject[@"msg"]];
                    }
                }else{
                    
                    [HTUIHelper removeHUDToWindow];
                    [HTUIHelper alertMessage:@"登录失败,请稍后再试"];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [HTUIHelper removeHUDToWindow];
                NSLog(@"%@",requestInfo.operation);
                [HTUIHelper alertMessage:@"登录失败"];
            }];
            
            
        }
        
    });
    
    
    
}

- (void)qqLoginBtnAction:(id)sender {
    
    __weak typeof(&*self)weakSelf = self;
    
    NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:UMSocialSnsTypeMobileQQ];
    
    //UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];//也可
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    snsPlatform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity *response) {
        
        //获取帐号用户名, uid, token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:platformName];
            
            NSString *urlString = [NSString stringWithFormat:@"https://graph.qq.com/oauth2.0/me?access_token=%@&unionid=1", snsAccount.accessToken];
            
            AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
            
            mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
            mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
            
            [mgr GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if (responseObject) {
                    
                    NSData *responseData = (NSData *)responseObject;
                    
                    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                    
                    int cout = (int)responseString.length;
                    
                    responseString = [responseString substringToIndex:cout-3];
                    
                    responseString = [responseString substringFromIndex:9];
                    
                    NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    
                    //NSString *client_id = tempDic[@"client_id"];
                    NSString *openid = tempDic[@"openid"];
                    NSString *unionid = tempDic[@"unionid"];
                    
                    NSDictionary *parmas = @{@"access_token":snsAccount.accessToken ,@"openid":openid,@"unionid":unionid,@"nickname":snsAccount.userName,@"avatar":snsAccount.iconURL,@"gender":@"1",@"country":@"",@"province":@"",@"token":@"",@"city":@"",@"clientType":@"ios"};
                    
                    [weakSelf requestSSRJLoginDataWithParam:parmas];

                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [HTUIHelper alertMessage:@"登录失败,请稍后再试"];

            }];
            
        }
        
    });
    
}

- (void)requestSSRJLoginDataWithParam:(NSDictionary *)paramDic {
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"/api/v5/login/thirdparty/qqLoginPlugin.jhtml";
    
    [requestInfo.postParams setDictionary:paramDic];
    [HTUIHelper addHUDToWindowWithString:@""];
    
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.boolValue == 0) {
                NSDictionary *dic = responseObject[@"data"];
                RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:dic error:nil];
                if (model) {
                    
                    [HTUIHelper removeHUDToWindowWithEndString:@"登录成功" image:nil delyTime:1];
                    [[RJAccountManager sharedInstance]registerAccount:model];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                    
                }
                else {
                    
                    [HTUIHelper removeHUDToWindowWithEndString:@"登录失败" image:nil delyTime:1];
                }
                
            }else{
                
                [HTUIHelper removeHUDToWindow];
                [HTUIHelper alertMessage:responseObject[@"msg"]];
            }
        }else{
            
            [HTUIHelper removeHUDToWindow];
            [HTUIHelper alertMessage:@"登录失败,请稍后再试"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper removeHUDToWindow];
        [HTUIHelper alertMessage:@"登录失败"];
    }];

}



- (void)weiboLoginBtnAction:(id)sender {
    
    NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:UMSocialSnsTypeSina];
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        
        //获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            
            NSDictionary *dict = [UMSocialAccountManager socialAccountDictionary];
            UMSocialAccountEntity *snsAccount = [dict valueForKey:platformName];
            
            if (!snsAccount) {
                [HTUIHelper addHUDToView:self.view withString:@"获取信息失败，请稍后再试" hideDelay:1];
                return ;
            }
            
            //        /b82/api/v4/login/thirdparty/{pluginId}
            //            pluginId=weixinLoginPlugin|qqLoginPlugin|weiboLoginPlugin
            //            access_token=xx
            //            openid=XXX
            //            unionid=XXX
            //            nickname=XXX
            //            avatar=XXX
            //            gender=XXX
            //            country=XXX
            //            province=XXX
            //            city=XXX
            //            token=xxx

            
            NSDictionary *parmas = @{@"access_token":snsAccount.accessToken ,@"openid":snsAccount.usid,@"unionid":snsAccount.usid,@"nickname":snsAccount.userName,@"avatar":snsAccount.iconURL,@"gender":@"1",@"country":@"",@"province":@"",@"token":@"",@"city":@"",@"clientType":@"ios"};
            
            ZHRequestInfo *requestInfo = [ZHRequestInfo new];
            
            requestInfo.URLString = @"/api/v5/login/thirdparty/weiboLoginPlugin.jhtml";
            
            [requestInfo.postParams setDictionary:parmas];
            [HTUIHelper addHUDToWindowWithString:@""];
            
            [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject objectForKey:@"state"]) {
                    NSNumber *state = [responseObject objectForKey:@"state"];
                    if (state.boolValue == 0) {
                        NSDictionary *dic = responseObject[@"data"];
                        RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:dic error:nil];
                        if (model) {
                            
                            [HTUIHelper removeHUDToWindowWithEndString:@"登录成功" image:nil delyTime:1];
                            [[RJAccountManager sharedInstance]registerAccount:model];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess object:nil];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
                            [self dismissViewControllerAnimated:YES completion:^{
                            }];
                        }
                        else {
                            
                            [HTUIHelper removeHUDToWindowWithEndString:@"登录失败" image:nil delyTime:1];
                        }
                        
                    }else{
                        
                        [HTUIHelper removeHUDToWindow];
                        [HTUIHelper alertMessage:responseObject[@"msg"]];
                    }
                }else{
                    
                    [HTUIHelper removeHUDToWindow];
                    [HTUIHelper alertMessage:@"登录失败,请稍后再试"];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [HTUIHelper removeHUDToWindow];
                [HTUIHelper alertMessage:@"登录失败"];
            }];
            
            
        }});
    
    
    
}

- (IBAction)loginButtonAction:(id)sender {
    if (![self checkUserInfo]) {
        return;
    }
    [self.emailTextField resignFirstResponder];
    [self.passWordTextField resignFirstResponder];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    NSString *str = [NSString stringWithFormat:@"?username=%@&password=%@",_emailTextField.text,_passWordTextField.text];
    
    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/login.jhtml%@",str];

    [HTUIHelper addHUDToWindowWithString:@"登录中..."];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.boolValue == 0) {
                    NSDictionary *userDic = responseObject[@"data"];
                    NSError __autoreleasing *e = nil;
                    [HTUIHelper removeHUDToWindowWithEndString:@"登录成功" image:nil delyTime:1];
                    RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:userDic error:&e];
                    if (model) {
                        //登录成功后会发送登录成功的通知 kNotificationLoginSuccess
                        [[RJAccountManager sharedInstance]registerAccount:model];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLoginSuccess object:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
                        [self dismissViewControllerAnimated:YES completion:^{
                            
                        }];
                        
                    }else {
                        
                        [HTUIHelper alertMessage:@"登录失败"];
                        
                    }
                }
                else {
                    [HTUIHelper removeHUDToWindow];
                    [HTUIHelper alertMessage:responseObject[@"msg"]];
                }
                
                
            }else{
                [HTUIHelper removeHUDToWindow];
                [HTUIHelper alertMessage:@"登录失败，请稍后再试"];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [HTUIHelper removeHUDToWindow];
        [HTUIHelper alertMessage:@"登录失败"];
        
    }];
                        
                            
}

- (BOOL)checkUserInfo{
    if (!self.emailTextField.text.length) {
        [HTUIHelper alertMessage:@"用户名不能为空"];
        return NO;
    }
    if (self.passWordTextField.text.length<6) {
        [HTUIHelper alertMessage:@"密码不能小于6位"];
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}
@end



