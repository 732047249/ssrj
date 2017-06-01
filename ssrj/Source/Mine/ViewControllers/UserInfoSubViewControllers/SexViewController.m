//
//  SexViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SexViewController.h"

@interface SexViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *femaleImageView;

@property (weak, nonatomic) IBOutlet UIImageView *maleImageView;

@property (strong, nonatomic) NSString *sex;

@end

@implementation SexViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        RJAccountModel *accountModel = [[RJAccountManager sharedInstance] account];
        if ([accountModel.gender isEqualToString:@"男"]) {
            _sex = @"男";
            _femaleImageView.image = [UIImage imageNamed:@"gouxuan_none"];
            _maleImageView.image = [UIImage imageNamed:@"gouxuan"];

        } else {
          
            _sex = @"女";
            _femaleImageView.image = [UIImage imageNamed:@"gouxuan"];
            _maleImageView.image = [UIImage imageNamed:@"gouxuan_none"];
            
        }
    }
    
    [MobClick beginLogPageView:@"个人编辑－修改性别页面"];
    [TalkingData trackPageBegin:@"个人编辑－修改性别页面"];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"性别";
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    //发送数据给后台，并本地保存
    __weak __typeof(&*self)weakSelf = self;
    [weakSelf sendData];
    
    [MobClick endLogPageView:@"个人编辑－修改性别页面"];
    [TalkingData trackPageEnd:@"个人编辑－修改性别页面"];


}

- (void)sendData {
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    //token: 227a1368bd09faa8f94d9181710ba533
    
    NSString *baseUrlString = [NSString stringWithFormat:@"/api/v5/member/updateGender.jhtml?gender=%@", _sex];
    
    NSString *urlStringUTF8 = [baseUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStringUTF8;
    
//    NSLog(@"sex=%@", _sex);
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        if ([responseObject objectForKey:@"state"]) {
                
            NSNumber *state = [responseObject objectForKey:@"state"];
                
            if (state.intValue == 0) {
                    
                NSDictionary *dataDic = [responseObject objectForKey:@"data"];
                    
                RJAccountModel *accountModel = [[RJAccountModel alloc] initWithDictionary:dataDic error:nil];
                    
                [[RJAccountManager sharedInstance] registerAccount:accountModel];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];

                    
                //通知上级UI更新网络数据
                [self updateUserInfoAction];

            } else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];

        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper alertMessage:[error localizedDescription]];
        
    }];
    
//    [HTUIHelper removeHUDToWindow];
}


- (void)updateUserInfoAction{
    
    if ([_delegate respondsToSelector:@selector(reloadUserInfoData)]) {
        [_delegate reloadUserInfoData];
    }
    
}



- (IBAction)femaleButtonAction:(id)sender {
    
    _femaleImageView.image = [UIImage imageNamed:@"gouxuan"];
    _maleImageView.image = [UIImage imageNamed:@"gouxuan_none"];
    _sex = @"女";
}

- (IBAction)maleButtonAction:(id)sender {
    _femaleImageView.image = [UIImage imageNamed:@"gouxuan_none"];
    _maleImageView.image = [UIImage imageNamed:@"gouxuan"];
    _sex = @"男";
    
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
