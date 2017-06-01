//
//  CreatNewThemeViewController.m
//  ssrj
//
//  Created by YiDarren on 16/7/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CreatNewThemeViewController.h"
#import "SMPublishMatchController.h"

//创建新合辑（不关联搭配）
static NSString * CreateUrl = @"/b180/api/v1/collocationupload/createtheme/";
//static NSString * CreateUrl = @"http://192.168.1.54:8000/api/v1/collocationupload/createtheme/";
@interface CreatNewThemeViewController ()<UITextFieldDelegate>


@end

@implementation CreatNewThemeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"创建新合辑页面"];
    [TalkingData trackPageBegin:@"创建新合辑页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建新合辑页面"];
    [TalkingData trackPageEnd:@"创建新合辑页面"];

}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"创建新合辑";
    
    [_switchKey setOn:YES];
    _buttonOn = @1;
    [_switchKey addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    _themeTitleText.text = _themeName;
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];


}




- (void)switchAction:(id)sender{
    
    UISwitch *switchButton = (UISwitch *)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        _buttonOn = @1;
    } else {
        _buttonOn = @0;
    }
    
}

#pragma mark --touches
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    [_themeTitleText resignFirstResponder];
    [_themeDescribeText resignFirstResponder];
}

//-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    
//    [_themeTitleText resignFirstResponder];
//    [_themeDescribeText resignFirstResponder];
//}


- (IBAction)creatButtonAction:(id)sender {
    
    [self.view endEditing:YES];
    if (_themeTitleText.text.length == 0 || _themeDescribeText.text.length == 0) {
        
        [HTUIHelper addHUDToView:self.view withString:@"您还有信息尚未填写" hideDelay:2];
        return ;
    }

    if (self.isFromCreateCollection == YES) {
        [self yf_createCollocation];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlString = @"/b180/api/v1/collocationupload/createtheme";
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    requestInfo.URLString = urlString;
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"title":_themeTitleText.text,@"brief":_themeDescribeText.text,@"publish":[_buttonOn stringValue]}];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }

    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
                        
            NSNumber *state = [responseObject objectForKey:@"state"];
            NSDictionary *tempDic = [responseObject objectForKey:@"data"];
            if (state.intValue == 0) {
                
                //通知上级UI更新网络数据
                NSDictionary *dic = @{@"name":_themeTitleText.text, @"describe":_themeDescribeText.text, @"isPublish":_buttonOn.stringValue, @"id":[tempDic objectForKey:@"id"]};
                
                [self updatePreciouUIActionWithDic:dic];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    for (UIViewController *vc in self.navigationController.viewControllers) {
                        
                        NSString *vcClass = NSStringFromClass([vc class]);
                        
                        if ([vcClass isEqualToString:@"GetToThemeViewController"]) {
                            
                            [self.navigationController popToViewController:vc animated:YES];
                            return ;

                        }
                    }
                    
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:YES];
                                        
                });
                        
            }else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        }else{
           
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        [[HTUIHelper shareInstance] removeHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance] removeHUD];
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
    }];
    
}
- (void)yf_createCollocation {
    
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = CreateUrl;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:_themeTitleText.text forKey:@"title"];
    [dict setValue:_themeDescribeText.text forKey:@"brief"];
    [dict setValue:_buttonOn forKey:@"publish"];
    requestInfo.postParams = dict;
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
//            NSLog(@"%@",responseObject);
            
            NSDictionary *dict = responseObject[@"data"];
            for (UIViewController *vc in self.navigationController.viewControllers) {
                if ([vc isKindOfClass:[SMPublishMatchController class]]) {
                    SMPublishMatchController *publish = (SMPublishMatchController *)vc;
                    [publish addWLabelDataWithDict:dict];
                    [self.navigationController popToViewController:publish animated:YES];
                }
            }
            
        }else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        [[HTUIHelper shareInstance] removeHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance] removeHUD];
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
    }];

}
//未用上，UI层级有调整
- (void)updatePreciouUIActionWithDic:(NSDictionary *)dic {
    
    if ([self.delegate respondsToSelector:@selector(reloadExitedThemeDataWithDic:)]) {
        [self.delegate reloadExitedThemeDataWithDic:dic];
    }
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}



@end
