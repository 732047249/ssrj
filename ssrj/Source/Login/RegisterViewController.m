//
//  RegisterViewController.m
//  ssrj
//
//  Created by YiDarren on 16/5/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//
#import "RJAccountModel.h"
#import "RegisterViewController.h"
@interface RegisterViewController ()<UITextFieldDelegate,UIAlertViewDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) id  keyboardShowObserver;
@property (strong, nonatomic) id  keyboardHideObserver;



@property (strong, nonatomic) IBOutlet UIView *baseView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *bgView;

//手机号text
@property (weak, nonatomic) IBOutlet UITextField *phoneNumText;
//密码text
@property (weak, nonatomic) IBOutlet UITextField *keyText;
//确认密码text
@property (weak, nonatomic) IBOutlet UITextField *conformText;
//短信验证码text
@property (weak, nonatomic) IBOutlet UITextField *conformSMSText;


//获取验证码button
@property (weak, nonatomic) IBOutlet UIButton *getConformNumButton;
//确认注册button
@property (weak, nonatomic) IBOutlet UIButton *registerButton;



@end

@implementation RegisterViewController

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    UIScrollView *sv = self.scrollView;
    
    self.keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        CGRect keyBoardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat keyboardHeight = keyBoardFrame.size.height;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        //界面拉长键盘弹出高度改变
        sv.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight + 50, 0);
        [UIView commitAnimations];
    }];
    
    self.keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        //add
//        CGRect keyBoardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
//        CGFloat keyboardHeight = keyBoardFrame.size.height;
        sv.contentInset = UIEdgeInsetsZero;

        [UIView commitAnimations];
    }];

    [MobClick beginLogPageView:@"大陆注册页面"];
    [TalkingData trackPageBegin:@"大陆注册页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    _getConformNumButton.layer.cornerRadius = 5.0f;
    _registerButton.layer.cornerRadius = 20.0f;
    _getConformNumButton.clipsToBounds = YES;
    _registerButton.clipsToBounds = YES;

    _phoneNumText.delegate = self;
    _keyText.delegate = self;
    _conformText.delegate = self;
    _conformSMSText.delegate = self;
    
    _baseView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed: @"zhuce-bj"]];
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT*1.3);
    _scrollView.delegate = self;
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardHideObserver];
    self.keyboardShowObserver = nil;
    self.keyboardHideObserver = nil;
    
    [MobClick endLogPageView:@"大陆注册页面"];
    [TalkingData trackPageEnd:@"大陆注册页面"];

}


- (IBAction)anotherRegistButtonAction:(id)sender {
    
}

//获取验证码 button
- (IBAction)getSMSButtonAction:(id)sender {
    
    if (!self.phoneNumText.text.length) {
        [HTUIHelper alertMessage:@"手机号无效，请重新输入"];
        self.phoneNumText.text = @"";
        return;
        
    }
    
    if (!self.keyText.text.length||self.keyText.text.length<6) {
        [HTUIHelper alertMessage:@"密码不能少于6位"];
        self.keyText.text = @"";
        self.conformText.text = @"";
        return;
    }
    if (![self.keyText.text isEqualToString:self.conformText.text]) {
        [HTUIHelper alertMessage:@"两次密码输入不一致，请重新输入"];
        self.keyText.text = @"";
        self.conformText.text = @"";
        return;
    }
    
    [self.phoneNumText resignFirstResponder];
    [self.keyText resignFirstResponder];
    [self.conformText resignFirstResponder];
    [self.conformSMSText resignFirstResponder];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"确认向\"%@\"发送验证码?",_phoneNumText.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertView.tag = 100;
    [alertView show];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1&&alertView.tag == 100) {
        /**
         *  获取短信验证码
         */
        
        ZHRequestInfo *requesrInfo = [ZHRequestInfo new];
        
        if ([_phoneNumText isFirstResponder]) {
            [_phoneNumText resignFirstResponder];
        }
        
        NSString *str = [NSString stringWithFormat:@"?mobile=%@&type=ios&smsType=register",self.phoneNumText.text];
        requesrInfo.URLString =[NSString stringWithFormat:@"/api/v5/sms/sendSMSCode.jhtml%@",str];
        
        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"正在发送验证码" xOffset:0 yOffset:0];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requesrInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"state"]){
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.boolValue == 0) {
                    [HTUIHelper alertMessage:@"验证码已发送到您手机，请注意查收"];
                    [[HTUIHelper shareInstance]removeHUD];
                }else{
                    [HTUIHelper alertMessage:responseObject[@"msg"]];
                    [[HTUIHelper shareInstance]removeHUD];
                }
                
            }else{
                [[HTUIHelper shareInstance]removeHUD];
                [HTUIHelper alertMessage:@"Error，请稍后再试"];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[HTUIHelper shareInstance]removeHUD];
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
//            NSLog(@"%@",error);
        }];
    }
}
- (IBAction)siginButtonAction:(id)sender {
//    BOOL debug = NO;
//    //debug
//    if (debug) {
//        NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:kAccount];
//        
//        RJAccountModel *model = [[RJAccountModel alloc]initWithString:str error:nil];
//        [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationRegistSuccess object:model];
//        [RJAccountManager sharedInstance].account = model;
//        
//        [HTUIHelper addHUDToWindowWithString:@"注册成功" hideDelay:2];
//        [self dismissViewControllerAnimated:YES completion:^{
//        
//        }];
//        return;
//    }
    
    if (![self checkUserInfo]) {
        return;
    }
    [self.phoneNumText resignFirstResponder];
    [self.keyText resignFirstResponder];
    [self.conformText resignFirstResponder];
    [self.conformSMSText resignFirstResponder];

    
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    NSString *str = [NSString stringWithFormat:@"?username=%@&password=%@&clientType=ios&smsValite=%@&mobile=%@",_phoneNumText.text,_keyText.text,_conformSMSText.text,_phoneNumText.text];
    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/register.jhtml%@",str];
    [HTUIHelper addHUDToWindowWithString:@"注册中..."];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.boolValue == 0) {
                NSDictionary *userDic = responseObject[@"data"];
                NSError __autoreleasing *e = nil;
                
                RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:userDic error:&e];
                if (model) {
                    [HTUIHelper removeHUDToWindowWithEndString:@"注册成功" image:nil delyTime:2];

                    [[RJAccountManager sharedInstance]registerAccount:model];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationLoginSuccess object:nil];
                    [self dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                    
                }else {
                    [HTUIHelper removeHUDToWindow];
                    [HTUIHelper alertMessage:@"注册失败,请稍后再试"];
                    
                }
            }else{
                [HTUIHelper removeHUDToWindow];
                [HTUIHelper alertMessage:responseObject[@"msg"]];
            }
        }else{
            
            [HTUIHelper removeHUDToWindow];
            [HTUIHelper alertMessage:@"注册失败,请稍后再试"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper removeHUDToWindow];
        [HTUIHelper alertMessage:@"注册失败"];
    }];
    
}
- (BOOL)checkUserInfo{
    if (self.phoneNumText.text.length<7) {
        [HTUIHelper alertMessage:@"手机号无效，请重新输入"];
        self.phoneNumText.text = @"";
        return NO;
        
    }
    if (!self.keyText.text.length||self.keyText.text.length<6) {
        [HTUIHelper alertMessage:@"密码不能少于6位"];
        self.keyText.text = @"";
        self.conformText.text = @"";
        return NO;
    }
    if (![self.keyText.text isEqualToString:self.conformText.text]) {
        [HTUIHelper alertMessage:@"两次密码输入不一致，请重新输入"];
        self.keyText.text = @"";
        self.conformText.text = @"";
        return NO;
    }
    if (!self.conformSMSText.text.length) {
        [HTUIHelper alertMessage:@"短信验证码不能为空"];
        return NO;
    }
    return YES;
}
#pragma mark -- UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField{


}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField==self.phoneNumText) {
        [self.keyText becomeFirstResponder];
    }
    if (textField ==  self.keyText) {
        [self.conformText becomeFirstResponder];
        
    }
    if (textField == self.conformText) {
        [self.conformText resignFirstResponder];
        
    }
    if (textField == self.conformSMSText ) {
        [self.conformSMSText resignFirstResponder];
    }
  
    
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    return YES;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    if (_phoneNumText.isFirstResponder) {
        
        [_phoneNumText resignFirstResponder];
        
    }
    if (_keyText.isFirstResponder) {
        
        [_keyText resignFirstResponder];
    }
    if (_conformText.isFirstResponder) {
        
        [_conformText resignFirstResponder];
    }
    if (_conformSMSText.isFirstResponder) {
        
        [_conformSMSText resignFirstResponder];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (_phoneNumText.isFirstResponder) {
        
        [_phoneNumText resignFirstResponder];
        
    }
    if (_keyText.isFirstResponder) {
        
        [_keyText resignFirstResponder];
    }
    if (_conformText.isFirstResponder) {
        
        [_conformText resignFirstResponder];
    }
    if (_conformSMSText.isFirstResponder) {
        
        [_conformSMSText resignFirstResponder];
    }
}
//邮箱
- (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


//手机号码验证
- (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13,15,17,18开头，八个 \d 数字字符, 新加17段
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|7[01678]|8[0-9])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobile];

}

- (IBAction)backBtnAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}



@end





