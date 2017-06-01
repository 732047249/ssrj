//
//  UserInfoChangeViewController.m
//  ssrj
//
//  Created by app on 16/6/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UserInfoChangeViewController.h"
#import "NickNameViewController.h"
#import "UserIntroduceViewController.h"
#import "SexViewController.h"
#import "PhoneNumberViewController.h"
#import "EmailViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
@interface UserInfoChangeViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, NickNameViewControllerDelegate,UserIntroduceViewControllerDelegate, SexViewControllerDelegate, PhoneNumberViewControllerDelegate, EmailViewControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *userIcon;

@property (weak, nonatomic) IBOutlet UILabel *nikNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *introduceLabel;

@property (weak, nonatomic) IBOutlet UILabel *sexLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;

@property (weak, nonatomic) IBOutlet UILabel *emailStateLabel;

@end

@implementation UserInfoChangeViewController


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"NickNameViewController"]) {
        
        NickNameViewController *nickVC = segue.destinationViewController;
        nickVC.delegate = self;
        
    }
    //userDescribe
    if ([segue.identifier isEqualToString:@"userDescribe"]) {
        
        UserIntroduceViewController *introduceVC = segue.destinationViewController;
        introduceVC.delegate = self;
        
    }
    
    
    if ([segue.identifier isEqualToString:@"SexViewController"]) {
        
        SexViewController *sexVC = segue.destinationViewController;
        sexVC.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"PhoneNumberViewController"]) {
        
        PhoneNumberViewController *phoneVC = segue.destinationViewController;
        phoneVC.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"EmailViewController"]) {
        
        EmailViewController *emailVC = segue.destinationViewController;
        emailVC.delegate = self;
        
    }
    
}


/**
 *  NickNameViewControllerDelegate 代理方法
 */
- (void)reloadUserInfoData{
    
    [self getData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];

    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
//    RJAccountModel *account = [RJAccountManager sharedInstance].account;
//    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:account.avatar]];
//    
//    if (account.nickname.length == 0) {
//        self.nikNameLabel.text = @"无";
//    }
//    self.nikNameLabel.text = account.nickname;
//    
//    if (account.introduction.length == 0) {
//        self.introduceLabel.text = @"未填写";
//    } else {
//        self.introduceLabel.text = account.introduction;
//    }
//    
//    if (account.mobile.length == 0) {
//        self.phoneNumLabel.text = @"未绑定";
//    } else {
//        self.phoneNumLabel.text = account.mobile;
//    }
//    
//    if (account.email.length == 0) {
//        self.emailStateLabel.text = @"未绑定";
//    } else {
//        self.emailStateLabel.text = account.email;
//    }
//    
//    if (account.gender.length == 0) {
//        self.sexLabel.text = @"未知";
//    } else {
//        self.sexLabel.text = account.gender;
//    }

    [MobClick beginLogPageView:@"个人资料编辑页面"];
    [TalkingData trackPageBegin:@"个人资料编辑页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"个人资料编辑页面"];
    [TalkingData trackPageEnd:@"个人资料编辑页面"];

}


- (void)getData {
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    //获取此UI所需属性
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //取token
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"api/v5/member/index.jhtml?timeString=%@", timeString];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject objectForKey:@"state"]) {
                
                NSNumber *state = [responseObject objectForKey:@"state"];
                
                if (state.intValue == 0) {
                
                    NSDictionary *dataDic = [responseObject objectForKey:@"data"];
                    RJAccountModel *accountModel = [[RJAccountModel alloc] initWithDictionary:dataDic error:nil];
                    #pragma mark --获取的数据存本地
                    [[RJAccountManager sharedInstance] registerAccount:accountModel];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];

                    //----------用户属性设置----------
                    //用户头像
                    NSString *imageStr = accountModel.avatar;
                    NSURL *imageUrl = [NSURL URLWithString:imageStr];
                    [_userIcon sd_setImageWithURL:imageUrl];
                
                    //昵称
                    if (accountModel.nickname.length == 0) {
                        
                        _nikNameLabel.text = @"无";
                    }
                    _nikNameLabel.text = accountModel.nickname;
                    
                    //个人介绍
                    if (accountModel.introduction.length == 0) {
                        
                        _introduceLabel.text = @"未填写";
                    } else {
                        _introduceLabel.text = accountModel.introduction;
                    }
                
                    //性别
                    if (accountModel.gender.length == 0) {
                        _sexLabel.text = @"未知";
                    } else {
                        _sexLabel.text = accountModel.gender;
                    }
                
                    //手机号
                    if (accountModel.mobile.length == 0) {
                        _phoneNumLabel.text = @"未绑定";
                    } else {
                        _phoneNumLabel.text = accountModel.mobile;
                    }
                
                    //邮箱
                    if (accountModel.email.length == 0) {
                        _emailStateLabel.text = @"未绑定";
                    } else {
                        _emailStateLabel.text = accountModel.email;
                    }
                
                    //账户管理//暂时不要
        
                }
                else if (state.intValue == 1) {
                    
                    [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];

                }
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    _userIcon.layer.cornerRadius = 25.0f;
    _userIcon.clipsToBounds = YES;
    
    RJAccountModel *account = [RJAccountManager sharedInstance].account;
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:account.avatar]];
    
    if (account.nickname.length == 0) {
        self.nikNameLabel.text = @"无";
    }
    self.nikNameLabel.text = account.nickname;
    
    if (account.introduction.length == 0) {
        self.introduceLabel.text = @"未填写";
    } else {
        self.introduceLabel.text = account.introduction;
    }
    
    if (account.mobile.length == 0) {
        self.phoneNumLabel.text = @"未绑定";
    } else {
        self.phoneNumLabel.text = account.mobile;
    }
    
    if (account.email.length == 0) {
        self.emailStateLabel.text = @"未绑定";
    } else {
        self.emailStateLabel.text = account.email;
    }
    
    if (account.gender.length == 0) {
        self.sexLabel.text = @"未知";
    } else {
        self.sexLabel.text = account.gender;
    }

    self.tableView.tableHeaderView = nil;

    __weak __typeof(&*self)weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];

//    [self.tableView.mj_header beginRefreshing];
}

- (void)addBackButton{
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImg = GetImage(@"back_icon");
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+20, buttonImg.size.height);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button setImage:buttonImg forState:0];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
}

- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}



//头像修改功能
- (IBAction)userIconChangeButtonAction:(id)sender {
    
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"更改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册上传", nil];
    
    menu.delegate = self;
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //0 takePhoto    1 pics
    if (buttonIndex == 0) {
        if ([self checkOutCameraStatus]) {
            [self takePicture];
        }

    } else if (buttonIndex == 1) {
        if ([self checkOuthStatusForPhotolib]) {
            
            [self choosePicture];
        }
    }
    
}
- (BOOL)checkOutCameraStatus{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
        [HTUIHelper alertMessage:@"应用相机权限受限,请在设置中启用"];
        return NO;
    }
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self takePicture];
            }else{
                
                [HTUIHelper alertMessage:@"应用相机权限受限,请在设置中启用"];

            }
        }];
        
        return NO;
        
    }
    return YES;
}
- (BOOL)checkOuthStatusForPhotolib {
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    
    if (status == ALAuthorizationStatusNotDetermined) {
        
        __block BOOL accessBool;
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            accessBool = YES;
        } failureBlock:^(NSError *error) {
            accessBool = NO;
        }];
        return accessBool;
        
    } else if (status == ALAuthorizationStatusAuthorized) {
        
        return YES;
        
    } else {
        
        [HTUIHelper alertMessage:@"相册无使用权限"];
        return NO;
    }
    
    return YES;
}


- (void)takePicture {
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.showsCameraControls = YES;
        imagePickerController.allowsEditing = YES;
        imagePickerController.delegate = self;
        //        self.wantsFullScreenLayout =YES;
        [self presentViewController:imagePickerController animated:YES completion:^{
            
            
        }];
    } else{
        DDLogDebug(@"NoCameraMsg");
    }
}

- (void)choosePicture {
    
    UIImagePickerController *albumPicker = [[UIImagePickerController alloc] init];
    albumPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    albumPicker.delegate = self;
    albumPicker.allowsEditing = YES;
    [self presentViewController:albumPicker animated:YES completion:^{
        
    }];
}

#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    UIImage *image= [info objectForKey:UIImagePickerControllerEditedImage];
    UIImage *newimage = [HTUIHelper imageWithImage:image scaledToSize:CGSizeMake(200.0, 200.0)];
    NSData *imagedata = UIImageJPEGRepresentation(newimage, 0.5);
    
    NSString *base64Str = [imagedata base64EncodedStringWithOptions:0];
    
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];

    requestInfo.URLString = [NSString stringWithFormat:@"api/v5/member/updateAvatar.jhtml"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    [requestInfo.postParams setDictionary:@{@"filename":@"test",@"file":base64Str}];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *state = responseObject[@"state"];
        if (state.intValue == 0) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"修改成功" image:nil];
            RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:responseObject[@"data"] error:nil];
            if (model) {
                [[RJAccountManager sharedInstance]registerAccount:model];
                [_userIcon sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
 
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"修改失败,请稍后再试" image:nil];

            }

        }else if (state.intValue == 1){
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        
        return 1;
        
    } else {
        
        return 5;//账号管理暂去除

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
