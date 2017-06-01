//
//  AskForTransSMSViewController.m
//  ssrj
//
//  Created by YiDarren on 16/9/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AskForTransSMSViewController.h"
#import "AskForTransSuessesViewController.h"

@interface AskForTransSMSViewController ()<UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *phoneNumberBg;
@property (weak, nonatomic) IBOutlet UIView *SMSNumberBg;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumber;
@property (weak, nonatomic) IBOutlet UITextField *SMSNumber;
@property (weak, nonatomic) IBOutlet UIButton *nextStep;

@property (strong, nonatomic) id keyboardShowObserver;
@property (strong, nonatomic) id keyboardHideObserver;
@property (weak, nonatomic) IBOutlet UIButton *getSMSNumButton;

@property (assign, nonatomic) NSInteger timeCount;
@property (strong, nonatomic) NSTimer *timer;



@end

@implementation AskForTransSMSViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackButton];
    self.title = @"申请提现";
    _nextStep.layer.cornerRadius = 20;
    _nextStep.layer.masksToBounds = YES;
    [_nextStep addTarget:self action:@selector(nextStepButtonAction) forControlEvents:UIControlEventTouchUpInside];
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIScrollView *sv = self.scrollView;
    
    self.keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
       
        CGRect keyboardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardHeight = keyboardFrame.size.height;
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

    [MobClick beginLogPageView:@"申请提现－验证码页面"];
    [TalkingData trackPageBegin:@"申请提现－验证码页面"];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardHideObserver];
    
    self.keyboardHideObserver = nil;
    self.keyboardShowObserver = nil;
    
    [MobClick endLogPageView:@"申请提现－验证码页面"];
    [TalkingData trackPageEnd:@"申请提现－验证码页面"];

}

#pragma mark -- 获取验证码button点击事件
- (IBAction)getSMNumber:(id)sender {
        
    if (!_phoneNumber.text.length) {
            
        [HTUIHelper addHUDToView:self.view withString:@"请输入已绑定的账号" hideDelay:1];
        return;
    }
    else if (_phoneNumber.text.length < 7) {
        
        //手机号注册
        if (_isTelephoneRegistered) {
         
            if ([_phoneNumber isFirstResponder]) {
                [_phoneNumber resignFirstResponder];
            }
            [HTUIHelper addHUDToWindowWithString:@"您输入的手机号码格式不正确" hideDelay:2.0f];
            return;
        }
        else {
            //邮箱注册 暂不考虑校验
        }
    }
    
    [_phoneNumber resignFirstResponder];
    [_SMSNumber resignFirstResponder];
    
    //TODO:获取验证码
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"确认向\"%@\"发送验证码?", _phoneNumber.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    [alertView show];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 100) {
        
        if (!textField.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入已绑定的账号" hideDelay:1];
            return NO;
        }
        else if (textField.text.length < 7) {
            
            if (_isTelephoneRegistered) {
                
                if ([_phoneNumber isFirstResponder]) {
                    [_phoneNumber resignFirstResponder];
                }
                [HTUIHelper addHUDToWindowWithString:@"您输入的手机号码格式不正确" hideDelay:2.0f];
                return NO;
            }
            else {
                //邮箱注册 暂不考虑校验
            }
         }
        
        [_SMSNumber becomeFirstResponder];
    }
    else if (textField.tag == 101) {
        
        if (!textField.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入验证码" hideDelay:1];
            return NO;
        }
        
        [_SMSNumber resignFirstResponder];
    }
    return YES;
}



#pragma mark --UIAlertViewDelegate -- 确认发送验证码
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==1) {
        
        //秒数递减
        self.timeCount = 60;
        
        //获取验证码button不能再交互
        _getSMSNumButton.userInteractionEnabled = NO;
        //锁死界面，不让滚动，导致计时器暂停，影响即时显示效果(暂停-->加快变化)
        //        self.scrollView.userInteractionEnabled = NO;
        
        if ([_phoneNumber isFirstResponder]) {
            [_phoneNumber resignFirstResponder];
        }
        
        __weak AskForTransSMSViewController *weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(reduceTimeAction:) userInfo:_getSMSNumButton repeats:YES];
        
        //获取验证码
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        NSString *str = @"";
        //手机号
        if (_isTelephoneRegistered) {
            
            str = [NSString stringWithFormat:@"?mobile=%@&type=ios&smsType=cash", self.phoneNumber.text];
        }
        //邮箱
        else {
        
            str = [NSString stringWithFormat:@"?email=%@&type=ios&smsType=cash", self.phoneNumber.text];
        }
        
        str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/sms/sendSMSCode.jhtml%@", str];
        
        [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {
                
                NSNumber *state = [responseObject objectForKey:@"state"];
                
                if (state.intValue == 0) {
                    
                    if (_isTelephoneRegistered) {
                        
                        [HTUIHelper alertMessage:@"验证码已经发送到您的手机，请注意查收"];
                    }
                    else {
                    
                        [HTUIHelper alertMessage:@"验证码已经发送到您的邮箱，请注意查收"];
                    }
                    
                } else {
                    
                    /**
                     *  若将timeCount设置为0，由于异步请求数据缘故延时会至倒计时数据飚到巨大,失控，需注意
                     */
                    weakSelf.timeCount = 1;
                    //获取验证码失败button打开交互
                    _getSMSNumButton.userInteractionEnabled = YES;
                    [HTUIHelper alertMessage:[responseObject objectForKey:@"msg"]];
                    
                }
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            
        }];
    }
}

#pragma mark --下一步button点击事件
- (void)nextStepButtonAction {
    
    __weak  __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *str = @"";
    
    if (_isTelephoneRegistered) {
        
        ///api/v5/sms/validSMSCode.jhtml?appVersion=xx&token=&mobile=&smsValite=&clientType=&smsType=cash
        
        str = [NSString stringWithFormat:@"/api/v5/sms/validSMSCode.jhtml?mobile=%@&smsValite=%@&clientType=ios&smsType=cash", self.phoneNumber.text, self.SMSNumber.text];
    }
    else {
        
        ///api/v5/mail/validEmailCode.jhtml?appVersion=xx&token=&email=&smsValite=&clientType=&smsType=cash
        
        str = [NSString stringWithFormat:@"/api/v5/mail/validEmailCode.jhtml?email=%@&smsValite=%@&clientType=ios&smsType=cash", self.phoneNumber.text, self.SMSNumber.text];
    }
    
    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    requestInfo.URLString = str;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                [_getSMSNumButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                [_getSMSNumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [weakSelf.timer invalidate];
                //打开交互
                _getSMSNumButton.userInteractionEnabled = YES;
                
                //短信校验成功，给后台发送申请提现请求
                [weakSelf sendApplyToNetAction];
                
            } else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];

            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        
    }];

}

#pragma mark -将申请请求发往后台
- (void)sendApplyToNetAction {
    
    ///b82/api/v5/user/addcase?account=收款账号&convertAmount=兑换金额&convertPonint=兑换积分&type=支付类型（0 微信，1支付宝）&mobile=手机号&realName=姓名&token=da83e19a50a084522343d96746f0d889&appVersion=2.0
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = _urlString;
    
    requestInfo.postParams = _paramDictionary;
    
    if (_isTelephoneRegistered) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"mobile":_phoneNumber.text}];
    }
    else {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"email":_phoneNumber.text}];
    }
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                //跳转
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                AskForTransSuessesViewController *sueccessVC = [story instantiateViewControllerWithIdentifier:@"AskForTransSuessesViewController"];
                [self.navigationController pushViewController:sueccessVC animated:YES];
                
                
            } else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];

}



- (void)reduceTimeAction:(NSTimer *)codeTimer {
    
    self.timeCount--;
    
    if (self.timeCount == 0) {
        [_getSMSNumButton setTitle:@"重新获取" forState:UIControlStateNormal];
        
        [_getSMSNumButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        UIButton *info = codeTimer.userInfo;
        info.enabled = YES;
        
        //打开getSMSNumButton交互
        _getSMSNumButton.userInteractionEnabled = YES;
        
        [self.timer invalidate];
        
    }
    else {
        NSString *str = [NSString stringWithFormat:@"%lu秒 ", self.timeCount];
        [_getSMSNumButton setTitle:str forState:UIControlStateNormal];
        _getSMSNumButton.userInteractionEnabled = NO;
    }
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{

    if ([_phoneNumber isFirstResponder]) {
        [_phoneNumber resignFirstResponder];
    }
    if ([_SMSNumber isFirstResponder]) {
        [_SMSNumber resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
