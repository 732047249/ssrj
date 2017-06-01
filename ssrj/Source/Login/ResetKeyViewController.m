//
//  ResetKeyViewController.m
//  ssrj
//
//  Created by YiDarren on 16/5/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ResetKeyViewController.h"

@interface ResetKeyViewController ()<UITextFieldDelegate, UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@property (weak, nonatomic) IBOutlet UITextField *conformKeyText;


@property (weak, nonatomic) IBOutlet UIButton *commitButton;


//@property (strong, nonatomic) NSTimer *timer;
//@property (assign, nonatomic) NSInteger timeCount;

@end

@implementation ResetKeyViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"重置密码页面"];
    [TalkingData trackPageBegin:@"重置密码页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"重置密码页面"];
    [TalkingData trackPageEnd:@"重置密码页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"重置密码";
    
    _commitButton.layer.cornerRadius = 20.0f;
    _commitButton.clipsToBounds = YES;
    
    _inputNewKeyText.delegate = self;
    _conformKeyText.delegate = self;
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


#pragma mark --UIAlertViewDelegate -- 重置密码确认提交
- (IBAction)commitButtonAction:(id)sender {
    
    if (_inputNewKeyText.text.length == 0) {
        
        [HTUIHelper addHUDToWindowWithString:@"请输入新密码" hideDelay:2.0f];
        return;
    }
    
    if ([_conformKeyText.text isEqualToString:@""]) {
        
        [HTUIHelper addHUDToWindowWithString:@"请输入密码" hideDelay:2.0f];
        return;
    }
    
    if ([_conformKeyText.text isEqualToString:_inputNewKeyText.text]) {
        
        [_conformKeyText resignFirstResponder];
    }

    if (!_keyForReset) {
        
        _keyForReset = @" ";
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
//  判断是修改手机密码还是修改邮箱密码
    NSString *str = @"";

    //手机密码修改情况
    if (_phoneOrEmailStyle == [NSNumber numberWithInt:0]) {
        
        str = [NSString stringWithFormat:@"/api/v5/password/resetPwd.jhtml"];
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"type":@"0",@"value":_phone,@"password":_conformKeyText.text,@"key":_keyForReset}];
        
    }
    //邮箱密码修改情况
    else {
        
        str = [NSString stringWithFormat:@"/api/v5/password/resetPwd.jhtml"];
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"type":@"1",@"value":_phone,@"password":_conformKeyText.text,@"key":_keyForReset}];
        
    }
    
    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = str;
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:4];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                });
                
                
            } else {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:4];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];

    }];
    
}







#pragma mark --UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if (textField == _conformKeyText) {
        
        if (_inputNewKeyText.text.length == 0) {
            
            [HTUIHelper addHUDToWindowWithString:@"请输入新密码" hideDelay:2.0f];

        }
        
        if ([_conformKeyText.text isEqualToString:@""]) {
            
            [HTUIHelper addHUDToWindowWithString:@"请输入密码" hideDelay:2.0f];
        }
        
        if ([_conformKeyText.text isEqualToString:_inputNewKeyText.text]) {
            
            [_conformKeyText resignFirstResponder];
            
            return YES;
        }
        
        if (![_conformKeyText.text isEqualToString:_inputNewKeyText.text]) {
            
            [HTUIHelper addHUDToWindowWithString:@"密码输入有误" hideDelay:2.0f];

        }
        
        return NO;
        
    } else {
        
        if ([_inputNewKeyText.text isEqualToString:@""]) {
            
            [HTUIHelper addHUDToWindowWithString:@"请输入新密码" hideDelay:2.0f];
            return NO;

        }
        [_inputNewKeyText resignFirstResponder];
        
        return YES;
    }
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
      return YES;
}



//#pragma mark --手机号输入是否合法
//- (BOOL)isPhoneNumTextLegal{
//    
//    if ([_phoneNumText.text isEqualToString:@""]) {
//        
//        [HTUIHelper addHUDToWindowWithString:@"亲,请输入手机号码" hideDelay:2.0f];
//        
//        return NO;
//    }
//    else if (_phoneNumText.text.length!=11) {
//        
//        _phoneNumText.text = @"";
//        [HTUIHelper addHUDToWindowWithString:@"您输入的手机号码格式不正确" hideDelay:2.0f];
//        return NO;
//    }
//    
//    if ([self validateMobile:self.phoneNumText.text]) {
//        [HTUIHelper alertMessage:@"手机号无效，请重新输入"];
//        self.phoneNumText.text = @"";
//        return NO;
//    }
//    //合法
//    //_phoneNumText.text.length == 11
//    [_phoneNumText resignFirstResponder];
//    [_conformKeyText becomeFirstResponder];
//    
//    return YES;
//}




//手机号码验证
- (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}


-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    if (_inputNewKeyText.isFirstResponder) {
        [_inputNewKeyText resignFirstResponder];
    }
    if (_conformKeyText.isFirstResponder) {
        [_conformKeyText resignFirstResponder];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
