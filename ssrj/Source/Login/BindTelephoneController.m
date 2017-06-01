//
//  BindTelephoneController.m
//  ssrj
//
//  Created by LiHaoFeng on 16/9/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "BindTelephoneController.h"
@interface BindTelephoneController()<UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;

@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;

@property (weak, nonatomic) IBOutlet UITextField *checkTextFiled;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@end

@implementation BindTelephoneController


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        CGRect keyBoardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat keyboardHeight = keyBoardFrame.size.height;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo [UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        [UIView commitAnimations];
    }];
    
    
    [[NSNotificationCenter defaultCenter]addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
       
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo [UIKeyboardAnimationDurationUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        _scrollView.contentInset = UIEdgeInsetsZero;
        [UIView commitAnimations];
    }];
    
    [MobClick beginLogPageView:@"绑定手机号页面"];
    [TalkingData trackPageBegin:@"绑定手机号页面"];
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
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}


- (void)viewDidLoad{
    [self addBackButton];
    self.title = @"账户绑定";
    
    
    _userIcon.layer.cornerRadius = 30;
    _userIcon.layer.masksToBounds = YES;
    [_userIcon sd_setImageWithURL:[NSURL URLWithString:self.userIconURL] placeholderImage:GetImage(@"default_1x1")];
    _userName.text = self.userNickName;
    
    _doneBtn.layer.borderWidth = 0.5;
    _doneBtn.layer.cornerRadius = 20;
    _doneBtn.layer.borderColor = [UIColor colorWithHexString:@"424446"].CGColor;

    
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillHideNotification];
    [[NSNotificationCenter defaultCenter]removeObserver:UIKeyboardWillShowNotification];
    
    [MobClick endLogPageView:@"绑定手机页面"];
    [TalkingData trackPageEnd:@"绑定手机页面"];

}


- (IBAction)getCheckNumber:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"" message:[NSString stringWithFormat:@"确认向\"%@\"发送验证码?",_phoneTextField.text] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alertView.tag = 100;
    [alertView show];

}


#pragma mark -- alertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100 && buttonIndex == 1) {
        if (buttonIndex==1&&alertView.tag == 100) {
            /**
             *  获取短信验证码
             */
            ZHRequestInfo *requesrInfo = [ZHRequestInfo new];
            
            NSString *str = [NSString stringWithFormat:@"?mobile=%@&type=ios&smsType=bind",self.phoneTextField.text];
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
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
                //            NSLog(@"%@",error);
            }];
        }
    }
}



- (IBAction)clickDoneBtn:(id)sender {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    if (_phoneTextField.text.length<7) {
        [HTUIHelper alertMessage:@"请输入正确的手机号"];
        return ;
    }
    if (_checkTextFiled.text.length<6) {
        [HTUIHelper alertMessage:@"请输入正确的验证码"];
        return;
    }
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/member/bindle.jhtml";
    
    NSDictionary *parmas = @{@"clientType":@"ios", @"mobile":_phoneTextField.text, @"messageCode":_checkTextFiled.text};
    
    [requestInfo.postParams setDictionary:parmas];
    
    [HTUIHelper addHUDToWindowWithString:@""];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.boolValue == 0) {
                NSDictionary *userDic = responseObject[@"data"];
                NSError __autoreleasing *e = nil;
                
                [HTUIHelper removeHUDToWindowWithEndString:@"绑定成功" image:nil delyTime:2];
                
                RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:userDic error:&e];
                if (model) {
                    [[RJAccountManager sharedInstance]registerAccount:model];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationLoginSuccess object:nil];
                    [self dismissViewControllerAnimated:YES completion:^{
                    }];
                    [self.parentViewController dismissViewControllerAnimated:NO completion:^{
                        
                    }];
                    
                }else {
                    [HTUIHelper removeHUDToWindow];
                    [HTUIHelper alertMessage:@"绑定失败,请稍后再试"];
                    
                }
            }else{
                [HTUIHelper removeHUDToWindow];
                [HTUIHelper alertMessage:responseObject[@"msg"]];
            }
        }else{
            
            [HTUIHelper removeHUDToWindow];
            [HTUIHelper alertMessage:@"绑定失败,请稍后再试"];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper removeHUDToWindow];
        [HTUIHelper alertMessage:@"绑定失败"];
    }];
    
}


- (IBAction)backBtnAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -- textField Delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [textField becomeFirstResponder];
    textField.keyboardType = UIKeyboardTypePhonePad;
}


- (void)textFieldDidEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    return YES;
}

@end
