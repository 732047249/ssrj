//
//  ChangeMimaViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ChangeMimaViewController.h"

@interface ChangeMimaViewController ()<UITextFieldDelegate, UIScrollViewDelegate>


@property (strong, nonatomic) id keyboardShowObserver;
@property (strong, nonatomic) id keyboardHideObserver;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollerView;
//输入旧密码
@property (weak, nonatomic) IBOutlet UITextField *InputOldKeyText;
//输入新密码
@property (weak, nonatomic) IBOutlet UITextField *InputNewKeyText;
//重新输入新密码
@property (weak, nonatomic) IBOutlet UITextField *InputNewKeyAgainText;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@end

@implementation ChangeMimaViewController

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    UIScrollView *sv = self.scrollerView;
    self.scrollerView.delegate = self;

    self.keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        CGRect keyBoardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat keyboardHeight = keyBoardFrame.size.height;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        //界面拉长键盘弹出高度改变
        sv.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        [UIView commitAnimations];
    }];
    
    self.keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        sv.contentInset = UIEdgeInsetsZero;
        
        [UIView commitAnimations];
    }];
    
    [MobClick beginLogPageView:@"我的->设置->修改密码页面"];
    [TalkingData trackPageBegin:@"我的->设置->修改密码页面"];
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
    
    [MobClick endLogPageView:@"我的->设置->修改密码页面"];
    [TalkingData trackPageEnd:@"我的->设置->修改密码页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    self.title = @"修改密码";
    _commitButton.layer.cornerRadius = 20.0f;
    _commitButton.clipsToBounds = YES;
    
    _InputOldKeyText.delegate = self;
    _InputNewKeyText.delegate = self;
    _InputNewKeyAgainText.delegate = self;
    
}


- (IBAction)commitButtonAction:(id)sender {
    
    //判断新密码是否合法
    //---------------------
    
    if ([self.InputOldKeyText isFirstResponder]) {
        
        if (self.InputOldKeyText.text.length == 0) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入旧密码" hideDelay:2];
            return ;
        }
        if (self.InputOldKeyText.text.length < 6) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入6位以上密码" hideDelay:2];
        }
        
        [self.InputNewKeyText becomeFirstResponder];
    }
    if ([self.InputNewKeyText isFirstResponder]) {
        
        if (self.InputNewKeyText.text.length < 6) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入6位以上密码" hideDelay:2];
            return ;
        }
        
        [self.InputNewKeyAgainText becomeFirstResponder];
        
    }
    if ([self.InputNewKeyAgainText isFirstResponder]) {
        if (self.InputNewKeyText.text.length == 0) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入新密码" hideDelay:2];
            self.InputNewKeyAgainText.text = @"";
            [self.InputNewKeyText becomeFirstResponder];
            return ;
        }
        if (self.InputNewKeyText.text.length < 6) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入6位以上新密码" hideDelay:2];
            self.InputNewKeyAgainText.text = @"";
            [self.InputNewKeyText becomeFirstResponder];
            return ;
        }
        if (self.InputNewKeyAgainText.text.length == 0) {
            [HTUIHelper addHUDToView:self.view withString:@"请重新输入新密码" hideDelay:2];
            return ;
        }
        if (![self.InputNewKeyAgainText.text isEqualToString:self.InputNewKeyText.text]) {
            
            [HTUIHelper addHUDToView:self.view withString:@"密码确认有误,请重新输入" hideDelay:2];
            self.InputNewKeyText.text = @"";
            self.InputNewKeyAgainText.text = @"";
            [self.InputNewKeyText becomeFirstResponder];
            return ;
        }
        
        [self.InputNewKeyAgainText resignFirstResponder];
        
    }

    
    //---------------------
    
    //收回键盘
    if ([_InputOldKeyText isFirstResponder]) {
        
        [_InputOldKeyText resignFirstResponder];
    } else if([_InputNewKeyText isFirstResponder]) {
        
        [_InputNewKeyText resignFirstResponder];
    } else if([_InputNewKeyAgainText isFirstResponder]){
        
        [_InputNewKeyAgainText resignFirstResponder];
    }

    //提交修改后的新密码操作
    [self setNewKey];
    
}

-(void)setNewKey {
    
//    __weak typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //http://www.ssrj.com/api/v2/member/updatePassword.jhtml?token=xxx&currentPassword=旧密码&password=新密码
   
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/updatePassword.jhtml?currentPassword=%@&password=%@", _InputOldKeyText.text, _InputNewKeyText.text];
    urlStr= [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    requestInfo.URLString = urlStr;
    
    //token
//    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
//        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        if ([responseObject objectForKey:@"state"]) {
                
            NSNumber *state = [responseObject objectForKey:@"state"];
                
            if ([state intValue] == 0) {
                //请求成功
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];

                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                    [self.navigationController popViewControllerAnimated:YES];
                        
                });

            } else if (state.intValue == 1){
                    
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
                self.InputNewKeyText.text = @"";
                self.InputNewKeyAgainText.text = @"";

            }
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
    }];
}


#pragma mark -- UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField == self.InputOldKeyText) {
        
        if (self.InputOldKeyText.text.length == 0) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入旧密码" hideDelay:2];
            return NO;
        }
        
        [self.InputNewKeyText becomeFirstResponder];
    }
    if (textField == self.InputNewKeyText) {
        
        if (self.InputNewKeyText.text.length < 6) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入6位以上密码" hideDelay:2];
            return NO;
        }
        
        [self.InputNewKeyAgainText becomeFirstResponder];
        
    }
    if (textField == self.InputNewKeyAgainText) {
        if (self.InputNewKeyText.text.length == 0) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入新密码" hideDelay:2];
            self.InputNewKeyAgainText.text = @"";
            [self.InputNewKeyText becomeFirstResponder];
            return NO;
        }
        if (self.InputNewKeyText.text.length < 6) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入6位以上新密码" hideDelay:2];
            self.InputNewKeyAgainText.text = @"";
            [self.InputNewKeyText becomeFirstResponder];
            return NO;
        }
        if (self.InputNewKeyAgainText.text.length == 0) {
            [HTUIHelper addHUDToView:self.view withString:@"请重新输入新密码" hideDelay:2];
            return NO;
        }
        if (![self.InputNewKeyAgainText.text isEqualToString:self.InputNewKeyText.text]) {
            
            [HTUIHelper addHUDToView:self.view withString:@"密码确认有误,请重新输入" hideDelay:2];
            self.InputNewKeyText.text = @"";
            self.InputNewKeyAgainText.text = @"";
            [self.InputNewKeyText becomeFirstResponder];
            return NO;
        }
        
        [self.InputNewKeyAgainText resignFirstResponder];
        
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    return YES;
}


#pragma mark --touchesBagan
-(void)keyboardHide:(UITapGestureRecognizer*)tap{

    if ([_InputOldKeyText isFirstResponder]) {
        
        [_InputOldKeyText resignFirstResponder];
    } else if([_InputNewKeyText isFirstResponder]) {
        
        [_InputNewKeyText resignFirstResponder];
    } else {
        
        [_InputNewKeyAgainText resignFirstResponder];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if ([_InputOldKeyText isFirstResponder]) {
        
        [_InputOldKeyText resignFirstResponder];
    } else if([_InputNewKeyText isFirstResponder]) {
        
        [_InputNewKeyText resignFirstResponder];
    } else {
        
        [_InputNewKeyAgainText resignFirstResponder];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}




@end
