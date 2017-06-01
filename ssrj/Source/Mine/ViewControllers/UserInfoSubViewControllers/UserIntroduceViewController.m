//
//  UserIntroduceViewController.m
//  ssrj
//
//  Created by YiDarren on 16/7/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UserIntroduceViewController.h"
#import "RJAccountModel.h"
@interface UserIntroduceViewController ()

@property (weak, nonatomic) IBOutlet UITextField *introduceText;

@property (strong, nonatomic) NSString *describe;

@end

@implementation UserIntroduceViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"个人编辑－修改个人介绍页面"];
    [TalkingData trackPageBegin:@"个人编辑－修改个人介绍页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"个人编辑－修改个人介绍页面"];
    [TalkingData trackPageEnd:@"个人编辑－修改个人介绍页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"个人签名";
    
    RJAccountModel *account = [[RJAccountManager sharedInstance] account];
    
    if (account.introduction.length == 0) {
        
        _introduceText.text = @"";
    } else {
        
        _introduceText.text = account.introduction;
    }
    
    
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


-(void)keyboardHide:(UITapGestureRecognizer*)tap{

    if ([_introduceText isFirstResponder]) {
        [_introduceText resignFirstResponder];
    }
    
}
//保存按钮
- (void)doneButtonClicked {
    
    [_introduceText resignFirstResponder];
    
    _describe = _introduceText.text;
    
    if (_describe.length == 0) {
        
        [HTUIHelper addHUDToView:self.view withString:@"介绍尚未填写" hideDelay:2];
        return;
    }
    
    _describe = [_describe stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    RJAccountModel *account = [[RJAccountManager sharedInstance] account];
    //此处应用新增的个人介绍字段，暂未给出故临时取用nickname替代
    if ([_describe isEqualToString:account.nickname]) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //取token
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    //TODO:个人介绍的链接
    ///api/v3/member/updateIntroduction.jhtml?appVersion=版本号&token=&introduction=简介
    NSString *baseUrlString = [NSString stringWithFormat:@"/api/v5/member/updateIntroduction.jhtml?introduction=%@", _describe];
    
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
                    
                //通知上级UI更新网络数据
                [self updateUserInfoAction];
                    
                //放在此处修改describe后返回上一页describe实时改变，因为此处数据保存先于返回(block)
                   dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                    [self.navigationController popViewControllerAnimated:YES];
                });
                    
            } else if(state.intValue == 1) {
                    
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        }
        else {
                
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //提示语
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

    }];
}

//取消按钮 
- (void)cancelButtonClicked {
    
    [self.navigationController popViewControllerAnimated:YES];
}

//通知上级UI更新网络数据
- (void)updateUserInfoAction {
    
    if ([_delegate respondsToSelector:@selector(reloadUserInfoData)]) {
        
        [_delegate reloadUserInfoData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
