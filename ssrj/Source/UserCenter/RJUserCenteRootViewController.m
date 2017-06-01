
#import "RJUserCenteRootViewController.h"
#import "RJUserCentePublishTableViewController.h"
#import "RJUserRecommendViewController.h"

#import "SwipeTableView.h"
#import "CustomSegmentControl.h"
#import "UIImage+New.h"
#import "RJUserFollowListViewController.h"
#import "RJUserFansListViewController.h"
#import "RJUserCenterHeaderView.h"

#import "RJUserFansListViewController.h"
#import "RJUserFollowListViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface RJUserCenteRootViewController ()<SwipeTableViewDataSource,SwipeTableViewDelegate,UIGestureRecognizerDelegate,UIViewControllerTransitioningDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (strong, nonatomic) SwipeTableView  *swipeTableView;

@property (nonatomic, strong) CustomSegmentControl * segmentBar;
@property (strong, nonatomic) RJUserCentePublishTableViewController  * userPublishVc;
@property (strong, nonatomic) RJUserRecommendViewController *userRecommendVc;
@property (strong, nonatomic) RJUserCenterHeaderView * tableViewHeaderView;
@property (strong, nonatomic) RJUserCenterHeaderModel * headerModel;
//判断是不是用户头像（yes为替换头像 no为替换背景图）
@property (assign, nonatomic) BOOL isUserIcon;

//设置毛玻璃效果
@property (strong, nonatomic) UIToolbar *toolbar;




@end

@implementation RJUserCenteRootViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self addBackButton];
    [self setTitle:@"用户主页" tappable:NO];
    if (self.userName) {
        [self setTitle:self.userName tappable:NO];
    }
    self.swipeTableView = [[SwipeTableView alloc]initWithFrame:self.view.bounds];
    self.swipeTableView.backgroundColor = [UIColor  whiteColor];
    self.swipeTableView.parentViewController = self;
    self.swipeTableView.navTitleStr = self.userName;
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _toolbar.alpha = 0.7;
    [self.tableViewHeaderView.bigImageView addSubview:_toolbar];
    [self.tableViewHeaderView.backBtn addTarget:self action:@selector(backBtnClickedAction) forControlEvents:UIControlEventTouchUpInside];
    [self.swipeTableView.backButton addTarget:self action:@selector(backBtnClickedAction) forControlEvents:UIControlEventTouchUpInside];
//    self.swipeTableView.swipeHeaderTopInset = 0;
    
    /**
     * 3.0.1
     */
    self.swipeTableView.isNavHidden = YES;
    
    self.swipeTableView.delegate = self;
    self.swipeTableView.dataSource = self;
    self.swipeTableView.shouldAdjustContentSize = YES;
    self.swipeTableView.swipeHeaderView = self.tableViewHeaderView;
//    _swipeTableView.swipeHeaderBar = self.segmentBar;
    [self.view addSubview:_swipeTableView];
    [_swipeTableView.contentView.panGestureRecognizer requireGestureRecognizerToFail:self.screenEdgePanGestureRecognizer];
    _swipeTableView.swipeHeaderBar = self.segmentBar;
    
//    放到发布里面 在发布的下拉刷新中 会调用getUserHeaderData方法
//    [self getUserHeaderData];

    
    
}
- (void)getUserHeaderData{
    if (self.userId) {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        requestInfo.URLString = @"/b180/api/v1/content/user_info/";
        //#warning debug
        //        self.userId = @66;
        __weak __typeof(&*self)weakSelf = self;
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.userId}];
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSNumber *state = responseObject[@"state"];
            if (state&&state.boolValue == 0) {
                NSDictionary *dic = responseObject[@"data"];
                RJUserCenterHeaderModel *model = [[RJUserCenterHeaderModel alloc]initWithDictionary:dic error:nil];
                if (model) {
                    weakSelf.headerModel = model;
                    
                    [weakSelf upLoadHederView];
                }
            }else{
                [HTUIHelper addHUDToView:weakSelf.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [HTUIHelper addHUDToView:self.view withString:@"error" hideDelay:1];
        }];
    }
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - back
- (void)backBtnClickedAction {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)upLoadHederView{
    self.tableViewHeaderView.nameLabel.text = self.headerModel.memberName?:@"尚未设置";
    self.tableViewHeaderView.memoLabel.text = self.headerModel.introduction;
    self.tableViewHeaderView.fansCountLabel.text = self.headerModel.fansCount.stringValue;
    self.tableViewHeaderView.followCountLabel.text = self.headerModel.subscribeCount.stringValue;
    self.tableViewHeaderView.followButton.selected = self.headerModel.isSubscribe.boolValue;
    self.userName = self.headerModel.memberName;
    /**
     *  3.0.1
     */
    if (self.userName) {
        self.swipeTableView.navTitleStr = self.userName;
    }
    
    
    [self.tableViewHeaderView.bigImageView sd_setImageWithURL:[NSURL URLWithString:self.headerModel.attributeValue1?:self.headerModel.avatar] placeholderImage:GetImage(@"default_1x1")];
    
    [self.tableViewHeaderView.avatorImageView sd_setImageWithURL:[NSURL URLWithString:self.headerModel.avatar] placeholderImage:GetImage(@"default_1x1")];
    
    self.tableViewHeaderView.followButton.hidden = NO;
    [self setTitle:self.headerModel.memberName tappable:NO];
    if (self.headerModel.isSelf.boolValue) {
        self.tableViewHeaderView.followButton.hidden = YES;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTap:)];
        tapGesture.delegate = self;
        self.tableViewHeaderView.bigImageView.userInteractionEnabled = YES;
        [self.tableViewHeaderView.bigImageView addGestureRecognizer:tapGesture];
        
        
        UITapGestureRecognizer *userIconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserIconTap:)];
        
        self.tableViewHeaderView.avatorImageView.userInteractionEnabled = YES;
        [self.tableViewHeaderView.avatorImageView addGestureRecognizer:userIconTapGesture];
        
    }
    [self.tableViewHeaderView.followButton addTarget:self action:@selector(followButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString * publishStr = [NSString stringWithFormat:@"发布 (%@)",self.headerModel.releaseCount?:@""];
    
    NSString *recommendStr = [NSString stringWithFormat:@"推荐单品 (%@)",self.headerModel.recommendationCount?:@""];
    
    NSArray *array = @[publishStr, recommendStr];
    
    [self.segmentBar reloadSegmentBarItemsDataWithArray:array];
}

#pragma mark-替换头像
- (void)handleUserIconTap:(UITapGestureRecognizer *)recoginzer {
    _isUserIcon = YES;
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"更改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册上传", nil];
    
    menu.delegate = self;
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
}

#pragma mark-换背景图片
- (void)handleBackgroundTap:(UITapGestureRecognizer *)recoginzer {
    _isUserIcon = NO;
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"更改背景图" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册上传", nil];
    
    menu.delegate = self;
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
    
}

#pragma mark-相册选择相关
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
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    
    if (_isUserIcon) {
        
        requestInfo.URLString = [NSString stringWithFormat:@"api/v5/member/updateAvatar.jhtml"];
    }
    else {
        
        requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/updateBackgroudImage.jhtml"];
    }
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
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
                
                if (_isUserIcon) {
                    
                    [weakSelf.tableViewHeaderView.avatorImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:GetImage(@"default_1x1")];
                    
                } else {
                    
                    [weakSelf.tableViewHeaderView.bigImageView sd_setImageWithURL:[NSURL URLWithString:model.attributeValue1?:self.headerModel.avatar] placeholderImage:GetImage(@"default_1x1")];
                }
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"修改失败,请稍后再试" image:nil];
            }
        }else if (state.intValue == 1){
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"修改失败,请稍后再试" image:nil];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}



- (void)followButtonAction:(id)sender{
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UINavigationController * nav =[[RJAccountManager sharedInstance]getLoginVc];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/member/subscribe/subscribeUser.jhtml";
    [requestInfo.postParams addEntriesFromDictionary:@{@"id":self.userId}];
    
    [HTUIHelper addHUDToWindowWithString:@"加载中"];
    
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state  = responseObject[@"state"];
        if (state.boolValue == 0) {
            NSNumber *data = responseObject[@"data"];
            NSNumber *fansCount = responseObject[@"fansCount"];
            self.headerModel.fansCount = fansCount;
            self.headerModel.isSubscribe = data;
            [self upLoadHederView];
            if (data.boolValue == 1) {
                //关注了
                [HTUIHelper removeHUDToWindowWithEndString:@"关注成功" image:nil delyTime:1.5];
                self.tableViewHeaderView.followButton.selected = YES;
            }else{
                [HTUIHelper removeHUDToWindowWithEndString:@"取消关注成功" image:nil delyTime:1.5];
                self.tableViewHeaderView.followButton.selected = NO;
            }
        }else{
            [HTUIHelper removeHUDToWindowWithEndString:@"请求失败，请稍后再试" image:nil delyTime:1.5];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper removeHUDToWindowWithEndString:@"请求失败，请稍后再试" image:nil delyTime:1.5];
    }];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];

    [MobClick beginLogPageView:@"用户中心界面"];
    [TalkingData trackPageBegin:@"用户中心界面"];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        if ([_userId isEqualToNumber:[RJAccountManager sharedInstance].account.id]) {
            
            self.tableViewHeaderView.followButton.hidden = YES;
        }
    }


    [MobClick endLogPageView:@"用户中心界面"];
    [TalkingData trackPageEnd:@"用户中心界面"];

    self.navigationController.interactivePopGestureRecognizer.delegate = self;
}
- (RJUserCenterHeaderView *)tableViewHeaderView{
    if (_tableViewHeaderView == nil) {
        NSArray *arr = [[NSBundle mainBundle]loadNibNamed:@"RJUserCenterHeaderView" owner:nil options:nil];
        if (arr.count) {
            _tableViewHeaderView = arr.firstObject;
            _tableViewHeaderView.size = CGSizeMake(SCREEN_WIDTH, 210);
            [_tableViewHeaderView.goFansListButton addTarget:self action:@selector(goFansListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_tableViewHeaderView.goFollowListButton addTarget:self action:@selector(goFollowListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_tableViewHeaderView layoutSubviews];
            _tableViewHeaderView.goFansListButton.trackingId = [NSString stringWithFormat:@"%@&goFansListButton",NSStringFromClass([self class])];
            _tableViewHeaderView.goFollowListButton.trackingId = [NSString stringWithFormat:@"%@&goFollowListButton",NSStringFromClass([self class])];
        }
    }
    return _tableViewHeaderView;
}

- (CustomSegmentControl * )segmentBar {
    if (nil == _segmentBar) {
        _segmentBar = [[CustomSegmentControl alloc]initWithItems:@[@"发布",@"推荐单品"]];
        _segmentBar.parentVcName = NSStringFromClass(self.class);
        _segmentBar.parentVcID = self.userId;
        _segmentBar.size = CGSizeMake(SCREEN_WIDTH, 40);
        _segmentBar.font = [UIFont systemFontOfSize:15];
        _segmentBar.textColor = [UIColor blackColor];
        _segmentBar.selectedTextColor = [UIColor colorWithHexString:@"#6225de"];
        _segmentBar.backgroundColor = [UIColor whiteColor];
        _segmentBar.selectionIndicatorColor = [UIColor clearColor];
        _segmentBar.selectedSegmentIndex = _swipeTableView.currentItemIndex;
        [_segmentBar addTarget:self action:@selector(changeSwipeViewIndex:) forControlEvents:UIControlEventValueChanged];
        _segmentBar.IndexChangeBlock = ^(NSInteger index){

        };
    }

    return _segmentBar;
}
- (void)changeSwipeViewIndex:(UISegmentedControl *)seg {
    [_swipeTableView scrollToItemAtIndex:seg.selectedSegmentIndex animated:NO];
    // request data at current index
    //    [self getDataAtIndex:seg.selectedSegmentIndex];
}
- (void)goFansListButtonAction:(id)sender{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserFansListViewController *fansVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserFansListViewController"];
    fansVc.userId  = self.userId;
    fansVc.type = RJFansListUser;
    [self.navigationController pushViewController:fansVc animated:YES];
}
- (void)goFollowListButtonAction:(id)sender{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserFollowListViewController *followVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserFollowListViewController"];
    followVc.userId = self.userId;
    followVc.type = RJFollowListUser;
    [self.navigationController pushViewController:followVc animated:YES];
}

#pragma mark - SwipeTableView M
- (NSInteger)numberOfItemsInSwipeTableView:(SwipeTableView *)swipeView {
    return 2;
}
- (UIScrollView *)swipeTableView:(SwipeTableView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIScrollView *)view {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];

    if(index == 0){
        if (!self.userPublishVc) {
            self.userPublishVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCentePublishTableViewController"];
            self.userPublishVc.fatherViewController = self;
            if (self.userId) {
                self.userPublishVc.userId = self.userId;
                
            }
        }
        view = self.userPublishVc.tableView;
     
        
    }
    
//    else if(index == 1){
//        if (!self.usertThumbVc) {
//            self.usertThumbVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteThumbTableViewController"];
//            self.usertThumbVc.fatherViewController = self;
//            if (self.userId) {
//                self.usertThumbVc.userId = self.userId;
//                
//            
//            }
//        }
//        view = self.usertThumbVc.tableView;
//
//  }
    else if (index == 1) {
        if (!self.userRecommendVc) {
            self.userRecommendVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserRecommendViewController"];
            
            self.userRecommendVc.fatherViewController = self;
            
            if (self.userId) {
                self.userRecommendVc.userId = self.userId;
            }
//            [self addChildViewController:self.userRecommendVc];
        }
        view = self.userRecommendVc.collectionView;
    }
    
    return view;
}
- (void)swipeTableView:(SwipeTableView *)swipeView didSelectItemAtIndex:(NSInteger)index{
    NSLog(@"%ld",(long)index);
}
- (CGFloat)swipeTableView:(SwipeTableView *)swipeTableView heightForRefreshHeaderAtIndex:(NSInteger)index {
    
    return 54;
    
}

- (BOOL)swipeTableView:(SwipeTableView *)swipeTableView shouldPullToRefreshAtIndex:(NSInteger)index {
    return YES;
}

// swipetableView index变化，改变seg的index
- (void)swipeTableViewCurrentItemIndexDidChange:(SwipeTableView *)swipeView {
    _segmentBar.selectedSegmentIndex = swipeView.currentItemIndex;
}
- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer {
    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
    if (self.navigationController.view.gestureRecognizers.count > 0) {
        for (UIGestureRecognizer *recognizer in self.navigationController.view.gestureRecognizers) {
            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
                break;
            }
        }
    }
    return screenEdgePanGestureRecognizer;
}

@end




@implementation RJUserCenterHeaderModel



@end
