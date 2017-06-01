//
//  NickNameViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "NickNameViewController.h"
#import "RJAccountModel.h"

@interface NickNameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nickNameText;

@property (strong, nonatomic) NSString *nickName;


@end

@implementation NickNameViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        RJAccountModel *account = [[RJAccountManager sharedInstance] account];
        _nickNameText.text = account.nickname;

    }
    else {
        _nickNameText.text = @"";
    }
    
    [MobClick beginLogPageView:@"个人编辑－修改昵称页面"];
    [TalkingData trackPageBegin:@"个人编辑－修改昵称页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"个人编辑－修改昵称页面"];
    [TalkingData trackPageEnd:@"个人编辑－修改昵称页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self addBackButton];
    
    self.title = @"昵称";
    
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

    if ([_nickNameText isFirstResponder]) {
        [_nickNameText resignFirstResponder];
    }
    
}

- (void)doneButtonClicked {
    
    [_nickNameText resignFirstResponder];
    
    _nickName = _nickNameText.text;
    _nickName = [_nickName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    RJAccountModel *acct = [[RJAccountManager sharedInstance] account];
    
    if ([_nickName isEqualToString:acct.nickname]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //取token
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    
    //预留参数的网址 NSString *baseUrlString = @"http://lolbox.duowan.com/phone/apiCheckUser.php?action=getPlayersInfo&serverName=%@&target=%@";
    //NSString *paramServer = @"电信十四";
    //NSString *paramName = @"蛋壳儿";
    //合成新的网址 NSString *urlString = [NSString stringWithFormat:baseUrlString,paramServer,paramName];
    //将网址转化为UTF8编码
    //NSString *urlStringUTF8 = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    
    NSString *baseUrlString = [NSString stringWithFormat:@"/api/v5/member/updateNickname.jhtml?nickname=%@",_nickName];
    
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
                    
                //放在此处修改nickName后返回上一页nickname实时改变，因为此处数据保存先于返回
                [self.navigationController popViewControllerAnimated:YES];

            }else if (state.intValue == 1) {
                    
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }

        }
        else{
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];

        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper removeHUDToWindow];
        [HTUIHelper alertMessage:[error localizedDescription]];
        
    }];

//    放在此处修改nickName后返回上一页nickname并没有实时改变，因为此处返回先于数据保存
//    [self.navigationController popViewControllerAnimated:YES];


}

- (void)updateUserInfoAction{
    
    if ([_delegate respondsToSelector:@selector(reloadUserInfoData)]) {
        [_delegate reloadUserInfoData];
    }
    
}




- (void)cancelButtonClicked {
    
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
