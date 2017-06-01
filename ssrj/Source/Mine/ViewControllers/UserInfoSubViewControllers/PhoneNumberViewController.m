//
//  PhoneNumberViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "PhoneNumberViewController.h"

@interface PhoneNumberViewController ()<UITextFieldDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *phoneNumText;

@property (weak, nonatomic) IBOutlet UITextField *smsIDText;

@property (weak, nonatomic) IBOutlet UIButton *timerButton;

@property (weak, nonatomic) IBOutlet UIButton *doneButton;
//验证码验证通过标志
@property (strong, nonatomic) NSString *fixState;//yes   no

@property (strong, nonatomic) NSTimer *timer;

@property (assign, nonatomic) NSInteger timeCount;
//验证码
@property (copy, nonatomic) NSString *userPhoneNum;
@property (strong, nonatomic)UIButton *sender;//用来保存获取验证码的button的属性，用以在计时器递减时不让getSMSNumButton交互


@end

@implementation PhoneNumberViewController


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"个人编辑－修改电话号码页面"];
    [TalkingData trackPageBegin:@"个人编辑－修改电话号码页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"个人编辑－修改电话号码页面"];
    [TalkingData trackPageEnd:@"个人编辑－修改电话号码页面"];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    self.title = @"手机号";
    _doneButton.layer.cornerRadius = 20.0f;
    _doneButton.clipsToBounds = YES;
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


- (IBAction)getSmsIDButton:(id)sender {
    
    if (self.phoneNumText.text.length<7) {

        [HTUIHelper alertMessage:@"手机号无效，请重新输入"];
        self.phoneNumText.text = @"";
        return;
    }
    
    [self.phoneNumText resignFirstResponder];
    [self.timerButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"确认向\"%@\"发送验证码?",_phoneNumText.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertView.tag = 100;
    [alertView show];
    
}


#pragma mark --UIAlertViewDelegate -- 确认发送验证码后
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1&&alertView.tag == 100) {
        /**
         *  获取短信验证码
         */
        
        self.timeCount = 60;
        //获取验证码button不能再交互
        _timerButton.userInteractionEnabled = NO;
        
        __weak __typeof(&*self) weakSelf = self;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:weakSelf selector:@selector(reduceTime:) userInfo:_timerButton repeats:YES];
        
        ZHRequestInfo *requesrInfo = [ZHRequestInfo new];
        
        NSString *str = [NSString stringWithFormat:@"?mobile=%@&type=ios&smsType=updateMobile",self.phoneNumText.text];
        requesrInfo.URLString =[NSString stringWithFormat:@"/api/v5/sms/sendSMSCode.jhtml%@",str];

//        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"正在发送验证码" xOffset:0 yOffset:0];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requesrInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([responseObject objectForKey:@"state"]){
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    [HTUIHelper alertMessage:@"验证码已发送到您手机，请注意查收"];
//                    [[HTUIHelper shareInstance]removeHUD];
                    
                }else{
                    [HTUIHelper alertMessage:responseObject[@"msg"]];//已被注册
                    [[HTUIHelper shareInstance]removeHUD];
                    [_timer invalidate];
                    _timerButton.userInteractionEnabled = YES;
                    
                }
                
            }else{

                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
        }];
    }
    
#pragma mark --验证通过,弹窗提示修改手机号成功
    if (alertView.tag == 110) {
        if (buttonIndex == 0) {
//            NSLog(@"0");
            //验证通过，状态记录
            _fixState = @"yes";
            
        }
        
        if (buttonIndex == 1) {
//            NSLog(@"1");
            
            
        }
    }
    
    
}

- (void)reduceTime:(NSTimer *)codeTimer {
    
    self.timeCount--;
    if (self.timeCount == 0) {
        [_timerButton setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [_timerButton setTitle:@"重新获取验证码" forState:UIControlStateSelected];

        
        [_timerButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        
        UIButton *info = codeTimer.userInfo;
        info.enabled = YES;
        
        //打开getSMSNumButton交互
        _timerButton.userInteractionEnabled = YES;
        
        [self.timer invalidate];
        
    }
    else {
        NSString *str = [NSString stringWithFormat:@"%lus", self.timeCount];
        [_timerButton setTitle:str forState:UIControlStateNormal];
        _timerButton.userInteractionEnabled = NO;
        
    }
    
    
}

- (IBAction)doneButtonAction:(id)sender {
    
    if ([_smsIDText.text isEqualToString:@""]) {
        [HTUIHelper addHUDToWindowWithString:@"还未填写验证码" hideDelay:1.0f];
        return;
        
    }
    else if (_smsIDText.text.length < 6) {
        
        [HTUIHelper addHUDToWindowWithString:@"验证码输入有误，请重新输入" hideDelay:1.0f];
        return;
    }
    
    //发送数据至后台匹配账号与电话号码
    __weak __typeof(&*self)weakSelf = self;
    [weakSelf sendPhoneNumToServer];
    _timerButton.selected = NO;
    [_timerButton setTitle:@"获取验证码" forState:UIControlStateNormal];
    [_timerButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.timer invalidate];

    //打开交互
    _timerButton.userInteractionEnabled = YES;
    //让验证码失效
//    _phoneNumText.text = @"";
    _smsIDText.text = @"";
        
    #pragma mark --验证通过自动返回上级UI
    if ([_fixState isEqualToString:@"yes"]) {
            
        [UIView animateWithDuration:1.5f animations:^{
                
            [self.navigationController popViewControllerAnimated:YES];
                
        } completion:^(BOOL finished) {
                
        }];
    }
    
}

#pragma mark --修改电话号码发送验证后的号码至服务器
- (void)sendPhoneNumToServer{
    
        ///api/v3/member/updateMobile.jhtml?appVersion=xx&token=xx&mobile=xx&smsValite=xx&clientType=ios&smsType=updateMobile
    
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
//        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
        NSString *baseUrlString = [NSString stringWithFormat:@"/api/v5/member/updateMobile.jhtml?mobile=%@&smsValite=%@&clientType=ios&smsType=updateMobile",_phoneNumText.text, _smsIDText.text];

    
        NSString *urlStringUTF8 = [baseUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        requestInfo.URLString = urlStringUTF8;
    
        [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([responseObject objectForKey:@"state"]) {
                    
                //请求成功
                    
                NSNumber *state = [responseObject objectForKey:@"state"];
                    
                if (state.intValue == 0) {
                    
                    NSDictionary *dataDic = [responseObject objectForKey:@"data"];
                        
                    RJAccountModel *accountModel = [[RJAccountModel alloc] initWithDictionary:dataDic error:nil];
                        
                    [[RJAccountManager sharedInstance] registerAccount:accountModel];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];

                    //通知上级UI更新网络数据
                    [self updateUserInfoAction];
                        
                    //验证正确，提示修改成功，弹窗
                    [HTUIHelper addHUDToView:self.view withString:@"修改成功" hideDelay:1];
                        
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                        [self.navigationController popToRootViewControllerAnimated:YES];
                            
                    });
                }
                else if (state.intValue == 1){
                        
                    [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
                }
            }
            else {
                    
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

            [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        }];
}


- (void)updateUserInfoAction{
    
    if ([_delegate respondsToSelector:@selector(reloadUserInfoData)]) {
        [_delegate reloadUserInfoData];
    }
    
}



#pragma mark --UITextFieldDelegate
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    if ([_phoneNumText isFirstResponder]) {
        [_phoneNumText resignFirstResponder];
    }
    if ([_smsIDText isFirstResponder]) {
        [_smsIDText resignFirstResponder];
    }
}


//手机号码验证  未用
- (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


//未用
- (BOOL)checkUserInfo{
    if (!self.phoneNumText.text.length||![self validateMobile:self.phoneNumText.text]) {
        [HTUIHelper alertMessage:@"手机号无效，请重新输入"];
        self.phoneNumText.text = @"";
        return NO;
        
    }
    
   
    if (!self.smsIDText.text.length) {
        [HTUIHelper alertMessage:@"短信验证码不能为空"];
        return NO;
    }
    return YES;
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
