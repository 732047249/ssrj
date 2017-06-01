//
//  EditPublishThemeViewController.m
//  ssrj
//
//  Created by YiDarren on 16/12/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "EditPublishThemeViewController.h"


@interface EditPublishThemeViewController ()<UITextFieldDelegate>


@end

@implementation EditPublishThemeViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [MobClick beginLogPageView:@"编辑合辑页面"];
    [TalkingData trackPageBegin:@"编辑合辑页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"编辑合辑页面"];
    [TalkingData trackPageEnd:@"编辑合辑页面"];

}

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"编辑合辑";
    
    [_switchKey setOn:YES];
    _buttonOn = @1;
    
    //完成按钮
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(navBarButtonAction)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    [_switchKey addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

    _themeTitleText.text = _themeName;
    _themeDescribeText.text = _themeDescribe;
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


//- (IBAction)cancelButtonAction:(id)sender {
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self dismissViewControllerAnimated:YES completion:^{
//            
//        }];
//    });
//    
//}

- (void)navBarButtonAction {
    
    if (_themeTitleText.text.length == 0 || _themeDescribeText.text.length == 0) {
        
        [HTUIHelper addHUDToView:self.view withString:@"您还有信息尚未填写" hideDelay:1];
        return ;
    }
    
    if ([_themeDescribeText isFirstResponder]) {
        [_themeDescribeText resignFirstResponder];
    }
    
    if ([_themeTitleText isFirstResponder]) {
        [_themeTitleText resignFirstResponder];
        
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //https://ssrj.com/b180/api/v1/content/publish/theme_item/detail/id/
    
    NSString *urlString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/detail/%@/",_creatThemeID];
    
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"name":_themeTitleText.text,@"memo":_themeDescribeText.text,@"is_publish":[_buttonOn stringValue]}];
    
    requestInfo.URLString = urlString;
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:weakSelf.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                
                if ([weakSelf.delegate isKindOfClass:NSClassFromString(@"RJUserCentePublishTableViewController")]) {
                    
                    //通知上级UI更新网络数据
                    [self updatePreciouUIAction];
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else{
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        }else{
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
    }];

}


#pragma mark -代理刷新上级UI
- (void)updatePreciouUIAction{
    
    if ([self.delegate isKindOfClass:NSClassFromString(@"RJUserCentePublishTableViewController")]) {
        
        if ([self.delegate respondsToSelector:@selector(reloadEditedThemeDataWithDic:)]) {
            
            NSDictionary *dic = @{@"name":_themeTitleText.text, @"describe":_themeDescribeText.text, @"isPublish":_buttonOn.stringValue };
            //上级UI(个人用户中心的发布标签)刷新取数据时字段要对应
            [self.delegate reloadEditedThemeDataWithDic:dic];
        }
    }
    else if ([self.delegate isKindOfClass:NSClassFromString(@"ThemeDetailVC")]) {
        
        if ([self.delegate respondsToSelector:@selector(reloadThemeDetailData)]) {
            
            //合辑详情UI刷新数据
            [self.delegate reloadThemeDetailData];
        }
    }
    
    
}



//- (IBAction)creatButtonAction:(id)sender {
//    
//    if (_themeTitleText.text.length == 0 || _themeDescribeText.text.length == 0) {
//        
//        [HTUIHelper addHUDToView:self.view withString:@"您还有信息尚未填写" hideDelay:2];
//        return ;
//    }
//    
//    if ([_themeDescribeText isFirstResponder]) {
//        [_themeDescribeText resignFirstResponder];
//    }
//    
//    if ([_themeTitleText isFirstResponder]) {
//        [_themeTitleText resignFirstResponder];
//    
//    }
//    
//    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
//    NSString *urlString = [NSString stringWithFormat:@"https://b82.ssrj.com/api/v3/goods/addthemeitem?name=%@&memo=%@&isOpen=%@&collocationId=%@",_themeTitleText.text, _themeDescribeText.text, [_buttonOn stringValue], [_creatThemeID stringValue]];
//    
//    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//    requestInfo.URLString = urlString;
//    
//    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
//    
//    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        if (responseObject) {
//                        
//            NSNumber *state = [responseObject objectForKey:@"state"];
//            
//            if (state.intValue == 0) {
//           
//                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
//                
//                //通知上级UI更新网络数据
//                [self updatePreciouUIAction];
//                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    
//                    [self dismissViewControllerAnimated:YES completion:^{
//                        
//                    }];
//                });
//                        
//            }else{
//                
//                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
//            }
//        }else{
//           
//            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//       
//        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
//    }];
//    
//}



- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}



@end
