//
//  EmailViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "EmailViewController.h"

@interface EmailViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailText;

@property (strong, nonatomic) NSString *email;

@end

@implementation EmailViewController
//设置初始值
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        RJAccountModel *account = [[RJAccountManager sharedInstance] account];
        _emailText.text = account.email;
        
    } else {
        
        _emailText.text = @"";
    }
    
    [MobClick beginLogPageView:@"个人编辑－修改邮箱页面"];
    [TalkingData trackPageBegin:@"个人编辑－修改邮箱页面"];

    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"个人编辑－修改邮箱页面"];
    [TalkingData trackPageEnd:@"个人编辑－修改邮箱页面"];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    self.title = @"邮箱";
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked)];
    
    self.navigationItem.rightBarButtonItem = done;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancelButtonClicked)];
    
    self.navigationItem.leftBarButtonItem = cancel;
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)doneButtonClicked {
    
    //保存用户邮箱
    _email = _emailText.text;
    
    if ([_email isEqualToString:@""]) {
        
        return;
    }
    __weak typeof(&*self)weakSelf = self;

//    NSLog(@"%d", [weakSelf validateEmail:_email]);
    
    //校验邮箱是否有效
    if ([weakSelf validateEmail:_email]) {
       
        [weakSelf sendData];

    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"邮箱错误" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
}

//邮箱
- (BOOL)validateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


- (void)sendData {
    
    [_emailText resignFirstResponder];
    _email = _emailText.text;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    NSString *baseUrlString = [NSString stringWithFormat:@"/api/v5/member/updateEmail.jhtml?email=%@", _email];
    
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
                    
                //请求成功
                [self.navigationController popViewControllerAnimated:YES];
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


- (void)cancelButtonClicked {
    
    [self.navigationController popViewControllerAnimated:YES];
}



-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    if ([_emailText isFirstResponder]) {
        
        [_emailText resignFirstResponder];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
