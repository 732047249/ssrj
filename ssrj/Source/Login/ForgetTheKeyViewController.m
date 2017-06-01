//
//  ForgetTheKeyViewController.m
//  ssrj
//
//  Created by YiDarren on 16/5/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ForgetTheKeyViewController.h"
#import "ResetKeyViewController.h"
@interface ForgetTheKeyViewController ()<UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *getSMSNumButton;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@property (weak, nonatomic) IBOutlet UITextField *phoneNumText;

@property (weak, nonatomic) IBOutlet UITextField *SMSNumText;

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) NSInteger timeCount;
//验证码
@property (copy, nonatomic) NSString *smsId;//保存请求返回的手机验证码
@property (copy, nonatomic) NSString *keyForReset;//通过手机号获得Key值，用于找回密码
@property (copy, nonatomic) NSString *userPhoneNum;
@property (strong, nonatomic)UIButton *sender;//用来保存获取验证码的button的属性，用以在计时器递减时不让getSMSNumButton交互 （其实没用上）


@end

@implementation ForgetTheKeyViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"找回手机密码页面"];
    [TalkingData trackPageBegin:@"找回手机密码页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"找回手机密码页面"];
    [TalkingData trackPageEnd:@"找回手机密码页面"];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    _getSMSNumButton.layer.cornerRadius = 5.0f;
    _commitButton.layer.cornerRadius = 20.0f;
    _getSMSNumButton.clipsToBounds = YES;
    _commitButton.clipsToBounds = YES;
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

//获取验证码button
- (IBAction)getSMSNumButtonAction:(UIButton *)sender {
    
    [_getSMSNumButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

    if ([_phoneNumText.text isEqualToString:@""]) {
        
        if ([_phoneNumText isFirstResponder]) {
            
            [_phoneNumText resignFirstResponder];
        }
        [HTUIHelper addHUDToWindowWithString:@"亲,请输入手机号码" hideDelay:2.0f];
        return;
    }
    else if (_phoneNumText.text.length < 7) {
        
        if ([_phoneNumText isFirstResponder]) {
            [_phoneNumText resignFirstResponder];
        }
        [HTUIHelper addHUDToWindowWithString:@"您输入的手机号码格式不正确" hideDelay:2.0f];
        return;
    }
    else if (_phoneNumText.text.length >=7) {
    
//        if (![self validateMobile:self.phoneNumText.text]) {
//            [HTUIHelper alertMessage:@"手机号无效，请重新输入"];
//            self.phoneNumText.text = @"";
//            return;
//        }
        
        [_phoneNumText resignFirstResponder];
        [_SMSNumText resignFirstResponder];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"确认向\"%@\"发送验证码?", _phoneNumText.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 100;
        [alertView show];
        
    }
    else {
        
    }

}

#pragma mark --UIAlertViewDelegate -- 确认发送验证码后
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex==1 && alertView.tag==100) {
        
        //秒数递减
        self.timeCount = 60;
        
        //获取验证码button不能再交互
        _getSMSNumButton.userInteractionEnabled = NO;
        //锁死界面，不让滚动，导致计时器暂停，影响即时显示效果(暂停-->加快变化)
//        self.scrollView.userInteractionEnabled = NO;
        
        if ([_phoneNumText isFirstResponder]) {
            [_phoneNumText resignFirstResponder];
        }
        
        __weak ForgetTheKeyViewController *weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(reduceTime:) userInfo:_getSMSNumButton repeats:YES];
        
        //获取验证码
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        NSString *str = [NSString stringWithFormat:@"?mobile=%@&type=ios&smsType=findpassword", self.phoneNumText.text];
        str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/sms/sendSMSCode.jhtml%@", str];
        
        [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if (responseObject) {

                NSNumber *state = [responseObject objectForKey:@"state"];
                
                if (state.intValue == 0) {
                    [HTUIHelper alertMessage:@"验证码已经发送到您手机，请注意查收"];
                    
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

////通过手机号获得Key值，用于找回密码
//- (void)getKeyToResetThemima {
//    
//    
//    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
//    NSString *str = [NSString stringWithFormat:@"?mobile=%@&code=%@", self.phoneNumText.text, self.SMSNumText.text];
//    
//    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    requestInfo.URLString = [NSString stringWithFormat:@"/api/v2/password/find.jhtml%@", str];
//    
//    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                
//        if (responseObject) {
//            
//            NSNumber *state = [responseObject objectForKey:@"state"];
//            
//            if (state.intValue == 0) {
//                
//                _keyForReset = [responseObject objectForKey:@"data"];
//                
//                
//            } else {
//                
//                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:4];
//                
//            }
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
//
//    }];
//
//}



//手机号码验证
- (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13,15,17,18开头，八个 \d 数字字符, 新加17段
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|7[01678]|8[0-9])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobile];
}


- (void) reduceTime:(NSTimer *)codeTimer {
    
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

#pragma mark -- 找回密码－提交动作
- (IBAction)submitButtonAction:(UIButton *)sender {
    

    if ([_SMSNumText.text isEqualToString:@""]) {
        [HTUIHelper addHUDToWindowWithString:@"还未填写验证码" hideDelay:1.0f];
        return;
    }
    else if (_SMSNumText.text.length < 6) {
        
        [HTUIHelper addHUDToWindowWithString:@"验证码输入有误，请重新输入" hideDelay:1.0f];
        return;
    }
    
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    NSString *str = [NSString stringWithFormat:@"?mobile=%@&code=%@&clientType=ios", self.phoneNumText.text, self.SMSNumText.text];
    
    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //TODO: V3版本
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/password/find.jhtml%@", str];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                _keyForReset = [responseObject objectForKey:@"data"];
                
                
                UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                ResetKeyViewController *resetTheKeyVC = [story instantiateViewControllerWithIdentifier:@"ResetTheKey"];
                
                resetTheKeyVC.phone = _phoneNumText.text;
                
                resetTheKeyVC.keyForReset = _keyForReset;
                
                //style = 0 为phone
                resetTheKeyVC.phoneOrEmailStyle = [NSNumber numberWithInt:0];
                
                [self.navigationController pushViewController:resetTheKeyVC animated:YES];
                
                [_getSMSNumButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                [_getSMSNumButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.timer invalidate];
                //打开交互
                _getSMSNumButton.userInteractionEnabled = YES;
                //让验证码失效
                _smsId = @"";
                _SMSNumText.text = @"";

                
                
            } else {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:4];
                
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        
    }];

}


#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{

    if (textField == _phoneNumText) {
        
        if (textField.text.length == 0) {
            
            return NO;
        }
        else if (textField.text.length < 7) {
            
            [_phoneNumText resignFirstResponder];
            [HTUIHelper addHUDToView:self.view withString:@"手机格式不对，请重新输入" hideDelay:1];
            _phoneNumText.text = @"";
            return NO;
        }
        else {
//            //手机号校验无效
//            if (![self validateMobile:textField.text]) {
//                
//                [_phoneNumText resignFirstResponder];
//                [HTUIHelper addHUDToView:self.view withString:@"手机格式不对，请重新输入" hideDelay:1];
//                return NO;
//            }
//            //手机号校验有效
//            else {
//                
//                [_phoneNumText resignFirstResponder];
//                return YES;
//            }
            
            return YES;
        }
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
}



-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    if (_phoneNumText.isFirstResponder) {
        [_phoneNumText resignFirstResponder];
    }
    if (_SMSNumText.isFirstResponder) {
        [_SMSNumText resignFirstResponder];
    }
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
