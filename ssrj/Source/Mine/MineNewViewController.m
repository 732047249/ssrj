//
//  MineNewViewController.m
//  ssrj
//
//  Created by YiDarren on 16/5/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MineNewViewController.h"
#import "HongBaoViewController.h"
#import "YuEViewController.h"
#import "JiFenViewController.h"
#import "SetTableViewController.h"
//Li's
#import "MFDMineOrdersViewController.h"
#import "CartViewController.h"

#import "MineFavoriteGoodsViewController.h"
#import "MineTopicsViewController.h"
#import "MineSingleViewController.h"
#import "MineThumbupedCollectionsViewController.h"
#import "MessageCenterViewController.h"

#import "SSClientViewController.h"

#import "RJTopicListViewController.h"
#import "RJDiscoveryMatchViewController.h"
#import "RJDiscoveryThemeViewController.h"

//关注&粉丝入口
#import "RJUserCenteRootViewController.h"
#import "RJUserFansListViewController.h"
#import "RJUserFollowListViewController.h"

#import "RJAnswerOneViewController.h"
#import "HHYiStoreMyGoodsController.h"

#import "GuideView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>

@interface MineNewViewController ()<UIAlertViewDelegate, UIGestureRecognizerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UMSocialUIDelegate>

//头像背景图片
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
//用户头像
@property (nonatomic, weak) IBOutlet UIImageView *userIconImageView;
//用户名称
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
//会员级别 (暂未使用)
@property (weak, nonatomic) UILabel *vipNameLabel;
//会员徽章
@property (weak, nonatomic) IBOutlet UIImageView *vipImageView;
//用户
@property (weak, nonatomic) IBOutlet UILabel *userDescribLabel;
//发布数
@property (weak, nonatomic) IBOutlet UILabel *releaseNumLabel;
//粉丝数
@property (weak, nonatomic) IBOutlet UILabel *fansNumLabel;
//关注数
@property (weak, nonatomic) IBOutlet UILabel *followersNumLabel;
//购物袋右上角数字
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
//积分数目
@property (weak, nonatomic) IBOutlet UILabel *jiFenLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewLeftContrains;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emptyViewRightContrains;


//设置毛玻璃效果
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIToolbar *toolbarBottom;


@property (weak, nonatomic) IBOutlet UIButton *fabuButton;
@property (weak, nonatomic) IBOutlet UIButton *guanzhuButton;
@property (weak, nonatomic) IBOutlet UIButton *fensiButton;
@property (weak, nonatomic) IBOutlet UIButton *cartButton;
@property (weak, nonatomic) IBOutlet UIButton *bianjiButton;
@property (weak, nonatomic) IBOutlet UIButton *jifenButton;

@property (weak, nonatomic) IBOutlet UIButton *dingdanButton;
@property (weak, nonatomic) IBOutlet UIButton *hongbaoButton;
@property (weak, nonatomic) IBOutlet UIButton *zhushouButton;
@property (weak, nonatomic) IBOutlet UIButton *yuErButton;
@property (weak, nonatomic) IBOutlet UIButton *kefuButton;
@property (weak, nonatomic) IBOutlet UIImageView *kefuRedicon;


@property (nonatomic,strong) RJShareBasicModel * shareModel;


@property (weak, nonatomic) IBOutlet UIView *shezhiCell;

@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UIButton *singleGoodsButton;
@property (weak, nonatomic) IBOutlet UIButton *collocationOfCollectionButton;
@property (weak, nonatomic) IBOutlet UIButton *collectionsOfCollectionButton;
@property (weak, nonatomic) IBOutlet UIButton *topicOfCollectionButton;
@property (weak, nonatomic) IBOutlet UIButton *storeOfYiStoreButton;
@property (weak, nonatomic) IBOutlet UIButton *goodsOfYiStoreButton;
@property (weak, nonatomic) IBOutlet UIButton *clientOfYiStoreButton;
@property (weak, nonatomic) IBOutlet UIButton *shareOfYiStoreButton;

@end


@implementation MineNewViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //当购物车内的商品数量有变动时，监听变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCartItemNumber) name:kNotificationCartNumberChanged object:nil];

    _userIconImageView.layer.cornerRadius = self.userIconImageView.height/2;
    _userIconImageView.clipsToBounds = YES;
    _userIconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _userIconImageView.layer.borderWidth = 2;
    _numLabel.layer.cornerRadius = 7.0f;
    _numLabel.clipsToBounds = YES;
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, _bgImageView.frame.origin.y, SCREEN_WIDTH, 214)];
    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _toolbar.alpha = 0.7;
    [_bgImageView addSubview:_toolbar];
    //超出画面裁剪
    _bgImageView.clipsToBounds = YES;
    
//    3.1.0
//    画曲面背景
    [self draw];
    
    _toolbarBottom = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 163, SCREEN_WIDTH, 52)];
    _toolbarBottom.barStyle = UIBarStyleBlackTranslucent;
    _toolbarBottom.alpha = 0.3;
//    [_bgImageView addSubview:_toolbarBottom];
    //超出画面裁剪
    _bgImageView.clipsToBounds = YES;

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBgImageViewTap:)];
    tapGesture.delegate = self;
    _bgImageView.userInteractionEnabled = YES;
    [_bgImageView addGestureRecognizer:tapGesture];
    
    
    
    //点击头像进入个人用户中心
    UITapGestureRecognizer *userIconTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserIconTap:)];
    userIconTapGesture.delegate = self;
    _userIconImageView.userInteractionEnabled = YES;
    [_userIconImageView addGestureRecognizer:userIconTapGesture];
    

    
    self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    __weak __typeof(&*self)weakSelf = self;
    //下拉刷新
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    
    //进入UI刷新
    [self.tableView.mj_header beginRefreshing];
    /**
     *  统计ID
     */
    _bgImageView.trackingId = [NSString stringWithFormat:@"%@&bgImageView",NSStringFromClass(self.class)];
    _userIconImageView.trackingId = [NSString stringWithFormat:@"%@&userIconImageView",NSStringFromClass(self.class)];
    self.fabuButton.trackingId = [NSString stringWithFormat:@"%@&fabuButton",NSStringFromClass(self.class)];

    self.guanzhuButton.trackingId = [NSString stringWithFormat:@"%@&guanzhuButton",NSStringFromClass(self.class)];
    self.fensiButton.trackingId = [NSString stringWithFormat:@"%@&fensiButton",NSStringFromClass(self.class)];
    self.cartButton.trackingId = [NSString stringWithFormat:@"%@&cartButton",NSStringFromClass(self.class)];
    self.bianjiButton.trackingId = [NSString stringWithFormat:@"%@&bianjiButton",NSStringFromClass(self.class)];
    self.jifenButton.trackingId = [NSString stringWithFormat:@"%@&jifenButton",NSStringFromClass(self.class)];
    self.dingdanButton.trackingId = [NSString stringWithFormat:@"%@&dingdanButton",NSStringFromClass(self.class)];
    self.hongbaoButton.trackingId = [NSString stringWithFormat:@"%@&hongbaoButton",NSStringFromClass(self.class)];
    self.zhushouButton.trackingId = [NSString stringWithFormat:@"%@&zhushouButton",NSStringFromClass(self.class)];
    self.yuErButton.trackingId = [NSString stringWithFormat:@"%@&yuErButton",NSStringFromClass(self.class)];
    self.kefuButton.trackingId = [NSString stringWithFormat:@"%@&kefuButton",NSStringFromClass(self.class)];
    self.shezhiCell.trackingId = [NSString stringWithFormat:@"%@&shezhiCell",NSStringFromClass(self.class)];
    self.messageButton.trackingId = [NSString stringWithFormat:@"%@&messageButton",NSStringFromClass(self.class)];
    self.singleGoodsButton.trackingId = [NSString stringWithFormat:@"%@&singleGoodsButton",NSStringFromClass(self.class)];
    self.collectionsOfCollectionButton.trackingId = [NSString stringWithFormat:@"%@&collectionsOfCollectionButton",NSStringFromClass(self.class)];
    self.collocationOfCollectionButton.trackingId = [NSString stringWithFormat:@"%@&collocationOfCollectionButton",NSStringFromClass(self.class)];
    self.topicOfCollectionButton.trackingId = [NSString stringWithFormat:@"%@&topicOfCollectionButton",NSStringFromClass(self.class)];
    self.storeOfYiStoreButton.trackingId = [NSString stringWithFormat:@"%@&storeOfYiStoreButton",NSStringFromClass(self.class)];
    self.goodsOfYiStoreButton.trackingId = [NSString stringWithFormat:@"%@&goodsOfYiStoreButton",NSStringFromClass(self.class)];
    self.clientOfYiStoreButton.trackingId = [NSString stringWithFormat:@"%@&clientOfYiStoreButton",NSStringFromClass(self.class)];
    self.shareOfYiStoreButton.trackingId = [NSString stringWithFormat:@"%@&shareOfYiStoreButton",NSStringFromClass(self.class)];
}

//背景曲线图
- (void)draw {
    CGSize finalSize = CGSizeMake(SCREEN_WIDTH, _bgImageView.frame.size.height);
    CGFloat layerHeight = finalSize.height/100*92;
    CAShapeLayer *layer = [CAShapeLayer layer];
    UIBezierPath *path = [UIBezierPath bezierPath];
    /** 左上点 */
    [path moveToPoint:CGPointMake(0, finalSize.height - layerHeight)];
    /** 左下点 */
    [path addLineToPoint:CGPointMake(0, finalSize.height + 1)];
    /** 右下点 */
    [path addLineToPoint:CGPointMake(finalSize.width, finalSize.height + 1)];
    /** 右上点 */
    [path addLineToPoint:CGPointMake(finalSize.width, layerHeight)];
    /** 圆弧 */
    [path addQuadCurveToPoint:CGPointMake(0, layerHeight) controlPoint:CGPointMake(SCREEN_WIDTH/2, layerHeight + 30)];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    [self.view.layer addSublayer:layer];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = NO;

    //状态栏隐藏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //进入UI刷新
    __weak __typeof(&*self)weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 耗时的操作
        [weakSelf mineNumberSetting];
        [weakSelf getShareModelNetData];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //更新界面
            RJAccountModel *account = [RJAccountManager sharedInstance].account;
            
            [_bgImageView sd_setImageWithURL:[NSURL URLWithString:account.attributeValue1] placeholderImage:[UIImage imageNamed:@"bg"]];
            
            [weakSelf setUserInfoDataActionWithAccountModel:account];
        });
    });
    
    [MobClick beginLogPageView:@"我的页面"];
    [TalkingData trackPageBegin:@"我的页面"];

    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newKeFuMessage) name:kStatusNewKeFuMessageNotification object:nil];

    self.kefuRedicon.hidden = YES;
    if ([RJAppManager sharedInstance].isNewKeFuMessage) {
        self.kefuRedicon.hidden = NO;
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusNewKeFuMessageNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"我的页面"];
    [TalkingData trackPageEnd:@"我的页面"];
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
}

#pragma mark -去往用户个人信息列表
- (IBAction)userInfoButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    UIViewController *userInfomationVC = [story instantiateViewControllerWithIdentifier:@"userInfomationVC"];
    
    [self.navigationController pushViewController:userInfomationVC animated:YES];
    
}


- (void)addGuideView{

    if (![[NSUserDefaults standardUserDefaults] boolForKey:RJFirstInGouYiZhuShou]) {
        GuideView *guidView = [[GuideView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        guidView.identifier = RJFirstInGouYiZhuShou;
        if (DEVICE_IS_IPHONE4) {
            guidView.localImage = @"zhushou_4";
        }
        if (DEVICE_IS_IPHONE5) {
            guidView.localImage = @"zhushou_5";
        }
        if (DEVICE_IS_IPHONE6) {
            guidView.localImage = @"zhushou_6";
        }
        if (DEVICE_IS_IPHONE6Plus) {
            guidView.localImage = @"zhushou_6p";
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:guidView];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RJFirstInGouYiZhuShou];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }
}
#pragma mark -- 背景替换图片
- (void)handleBgImageViewTap:(UITapGestureRecognizer *)recognizer {
        
    UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:@"更改背景图" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册上传", nil];
    
    menu.delegate = self;
    menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [menu showInView:self.view];
    if (recognizer.view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:recognizer.view.trackingId];
    }
    
}

#pragma mark -点击用户头像进入个人用户中心（同点击发布）
- (void)handleUserIconTap:(UITapGestureRecognizer *)recognizer {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    
    rootVc.userId = [NSNumber numberWithInteger:[[RJAccountManager sharedInstance].account.id integerValue]];
    rootVc.userName = [RJAccountManager sharedInstance].account.nickname;
    
    [self.navigationController pushViewController:rootVc animated:YES];
    if (recognizer.view.trackingId) {
        
        [[RJAppManager sharedInstance]trackingWithTrackingId:recognizer.view.trackingId];
    }
    
}


- (void)setUserInfoDataActionWithAccountModel:(RJAccountModel *) account{
    
    //----------------用户属性设置----------------
    //用户头像
    _userNameLabel.text = account.username;
    
    NSString *imageStr = account.avatar;
    NSURL *imageUrl = [NSURL URLWithString:imageStr];
    [_userIconImageView sd_setImageWithURL:imageUrl];
    
    //用户昵称
    _userNameLabel.text = account.memberName;

    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:account.attributeValue1] placeholderImage:[UIImage imageNamed:@"bg"]];

    //会员等级（_vipNameLabel 暂未用到）
    if ([account.memberRank intValue] == 1) {
        
        _vipNameLabel.text = @"铜牌会员";
        _vipImageView.image = [UIImage imageNamed:@"Bronze_icon"];
    }
    if ([account.memberRank intValue] == 2) {
        
        _vipNameLabel.text = @"银牌会员";
        _vipImageView.image = [UIImage imageNamed:@"Silver_icon"];

    }
    if ([account.memberRank intValue] == 3) {
        
        _vipNameLabel.text = @"金牌会员";
        _vipImageView.image = [UIImage imageNamed:@"Gold_icon"];

    }
    
    //个人介绍信息
    if (account.introduction.length == 0) {
    
        _userDescribLabel.text = @"快来完善你的个人签名吧!";
    
    } else {
    
        _userDescribLabel.text = account.introduction;
    }
    
    //粉丝数
    if (!account.fansCount) {
        _fansNumLabel.text = @"0";
    }
    else {
        _fansNumLabel.text = [account.fansCount stringValue];
    }
    
    //关注数
    if (!account.subscribeCount) {
        _followersNumLabel.text = @"0";
    }
    else {
        _followersNumLabel.text = [account.subscribeCount stringValue];
    }
    
    //发布数
    if (!account.releaseCount) {
        
        _releaseNumLabel.text = @"0";
    }
    else {
        _releaseNumLabel.text = [account.releaseCount stringValue];
    }
    
    //设置购物袋订单数量
    _numLabel.text = [account.cartProductQuantity stringValue];
    
    
    //设置积分数 add 12.8
    _jiFenLabel.text = [NSString stringWithFormat:@"时尚币：%@",account.point];
    
//    因数据源不同后台接口不统一
//    [self mineNumberSetting];
    

    
}

#pragma mark -- 新版未用
//下拉刷新我的收藏对应的三个Label数值也刷新
- (void)mineNumberSetting{
    __weak typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //token=227a1368bd09faa8f94d9181710ba533
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/index.jhtml?timeString=%@", timeString];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *state = responseObject[@"state"];
        if (state.intValue == 0) {
            //请求成功，后续模型赋值操作
            
            NSDictionary *dic = [responseObject objectForKey:@"data"];
            RJAccountModel *accountModel = [[RJAccountModel alloc] initWithDictionary:dic error:nil];
            [[RJAccountManager sharedInstance]registerAccount:accountModel];
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
            [weakSelf setUserInfoDataActionWithAccountModel:accountModel];
            
        }
        else if(state.intValue == 1) {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
        //token失效 需要重新登录
        else if(state.intValue == 2 ){
            //                if ([RJAccountManager sharedInstance].token) {
            //                    [[RJAppManager sharedInstance]showTokenDisableLoginVc];
            //                }
            [self.tabBarController setSelectedIndex:0];
            
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
    
}


- (void)getShareModelNetData {
    
    __weak typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    NSString *urlStr = @"/b180/api/v1/member/eshop/share/link/";
    
    requestInfo.URLString = urlStr;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *state = responseObject[@"state"];
        if (state.intValue == 0) {
            
            NSDictionary *dic = responseObject[@"data"];
            
            weakSelf.shareModel = [[RJShareBasicModel alloc] initWithDictionary:dic error:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}


- (void)getNetData {
    
        __weak typeof(&*self)weakSelf = self;
    
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        
        //token=227a1368bd09faa8f94d9181710ba533
        //时间戳
        NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
        NSTimeInterval timeIntrl = [timesp timeIntervalSince1970];
        NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    
        NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/index.jhtml?timeString=%@", timeString];
    
        requestInfo.URLString = urlStr;
    
        [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSNumber *state = responseObject[@"state"];
            if (state.intValue == 0) {
                    //请求成功，后续模型赋值操作
                    [self addGuideView];

                    NSDictionary *dic = [responseObject objectForKey:@"data"];
                    RJAccountModel *accountModel = [[RJAccountModel alloc] initWithDictionary:dic error:nil];
                    [[RJAccountManager sharedInstance]registerAccount:accountModel];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
                    [weakSelf setUserInfoDataActionWithAccountModel:accountModel];
                    
            }
            else if(state.intValue == 1) {
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
            
            //token失效 需要重新登录
            else if(state.intValue == 2 ){
//                if ([RJAccountManager sharedInstance].token) {
//                    [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                }
                [self.tabBarController setSelectedIndex:0];

            }
            
            [weakSelf.tableView.mj_header endRefreshing];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:2];
            [weakSelf.tableView.mj_header endRefreshing];
            
        }];   
    
}

#pragma mark -消息提醒button点击事件
- (IBAction)messageButtonAction:(id)sender {
    
    [HTUIHelper addHUDToView:self.view withString:@"消息" hideDelay:1];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    MessageCenterViewController *msgVC = [story instantiateViewControllerWithIdentifier:@"MessageCenterViewController"];
    
    [self.navigationController pushViewController:msgVC animated:YES];
    
}

#pragma mark --粉丝buttonAction
- (IBAction)fansButtonAction:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserFansListViewController *fansVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserFansListViewController"];
    NSNumber *userID = [[RJAccountManager sharedInstance] account].id;
    fansVc.userId = userID;
    fansVc.type = RJFansListUser;
    [self.navigationController pushViewController:fansVc animated:YES];

}


#pragma mark --关注buttonAction
- (IBAction)followedButtonAction:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserFollowListViewController *followVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserFollowListViewController"];
    NSNumber *userID = [[RJAccountManager sharedInstance] account].id;
    followVc.userId = userID;
    followVc.type = RJFollowListUserSelf;
    [self.navigationController pushViewController:followVc animated:YES];

}



#pragma mark --我的账户
#pragma mark --查看全部订单
- (IBAction)checkAllOrdersButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    
    MFDMineOrdersViewController *topPageVC = [story instantiateViewControllerWithIdentifier:@"MFDMineOrdersViewController"];
    
    [self.navigationController pushViewController:topPageVC animated:YES];
}


#pragma mark --红包buttonAction
- (IBAction)hongBaoButtonAction:(id)sender {
    
    HongBaoViewController *hongBaoVC = [[HongBaoViewController alloc] init];
    
    [self.navigationController pushViewController:hongBaoVC animated:YES];
    
}

#pragma mark --助手buttonAction
- (IBAction)buyerHelperButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RJAnswerOneViewController * answerVC = [story instantiateViewControllerWithIdentifier:@"RJAnswerOneViewController"];

    [self.navigationController pushViewController:answerVC animated:YES];
    
}

#pragma mark --余额buttonAction
- (IBAction)yuEButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    YuEViewController *yuEVC = [story instantiateViewControllerWithIdentifier:@"YuEViewController"];
    
    [self.navigationController pushViewController:yuEVC animated:YES];

}

#pragma mark --积分buttonAction
- (IBAction)jiFenButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    JiFenViewController *jiFenVC = [story instantiateViewControllerWithIdentifier:@"JiFenViewController"];
    
    [self.navigationController pushViewController:jiFenVC animated:YES];

}


#pragma mark --客服buttonAction
- (IBAction)serverForClientButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    UITableViewController *serverVC = [story instantiateViewControllerWithIdentifier:@"mineClientServerID" ];
    [self.navigationController pushViewController:serverVC animated:YES];
}

#pragma mark --我的收藏
#pragma mark --单品
- (IBAction)singleGoodsBtnAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];

    MineSingleViewController *mineSingleVC = [story instantiateViewControllerWithIdentifier:@"MineSingleViewController"];
    mineSingleVC.titleLabelNumString = _numLabel.text;
    
    [self.navigationController pushViewController:mineSingleVC animated:YES];

}

#pragma mark --搭配
- (IBAction)collocationBtnAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    MineThumbupedCollectionsViewController *MineThumbupedCollectionsVC = [story instantiateViewControllerWithIdentifier:@"MineThumbupedCollectionsViewController"];
    
    [self.navigationController pushViewController:MineThumbupedCollectionsVC animated:YES];

}

#pragma mark --合辑
- (IBAction)themeBtnAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    MineFavoriteGoodsViewController *mineFavoriteVC = [story instantiateViewControllerWithIdentifier:@"MineFavoriteGoodsViewController"];
    mineFavoriteVC.titleNumString = _numLabel.text;
    
    [self.navigationController pushViewController:mineFavoriteVC animated:YES];

}

#pragma mark --客服
- (IBAction)topicBtnAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    MineTopicsViewController *topicListVC = [story instantiateViewControllerWithIdentifier:@"MineTopicsViewController"];
    topicListVC.titleNumString = _numLabel.text;
    
    [self.navigationController pushViewController:topicListVC animated:YES];

}


#pragma mark --我的微店
#pragma mark --微店
- (IBAction)smallShopBtnAction:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    
    rootVc.userId = [NSNumber numberWithInteger:[[RJAccountManager sharedInstance].account.id integerValue]];
    rootVc.userName = [RJAccountManager sharedInstance].account.nickname;
    
    [self.navigationController pushViewController:rootVc animated:YES];


}

#pragma mark --商品
- (IBAction)goodsBtnAction:(id)sender {
    
    HHYiStoreMyGoodsController *goodsVc = [[HHYiStoreMyGoodsController alloc] init];
    goodsVc.userId = [RJAccountManager sharedInstance].account.id;
    [self.navigationController pushViewController:goodsVc animated:YES];
    

}

#pragma mark --客户
- (IBAction)customerBtnAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    [HTUIHelper addHUDToView:self.view withString:@"客户" hideDelay:1];
    
    SSClientViewController *SSClientVC = [story instantiateViewControllerWithIdentifier:@"SSClientViewController"];
    
    [self.navigationController pushViewController:SSClientVC animated:YES];

}

#pragma mark --分享给好友
- (IBAction)shareBtnAction:(id)sender {
    
    NSArray *shareType = [NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,nil];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToWechatTimeline]];
    NSString *imageUrl = self.shareModel.img?:[RJAccountManager sharedInstance].account.avatar;
    NSString *comment = self.shareModel.memo.length?self.shareModel.memo:@"欢迎来的我的微店！ 我的生活，我的风格，我的时尚日记";
    NSString *shareUrl = self.shareModel.shareUrl.length?self.shareModel.shareUrl:@"http://www.ssrj.com";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
    [UMSocialData defaultData].extConfig.wechatSessionData.title = self.shareModel.title?:[NSString stringWithFormat:@"欢迎来到%@的Yi店",[RJAccountManager sharedInstance].account.username];
    
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qqData.title = self.shareModel.title;
    
    [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
    [UMSocialData defaultData].extConfig.qzoneData.title = self.shareModel.title;
    
    [UMSocialData defaultData].extConfig.sinaData.shareText =[NSString stringWithFormat:@"%@%@",comment,shareUrl];
    
    //调用快速分享接口
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UmengAppkey
                                      shareText:comment
                                     shareImage:nil
                                shareToSnsNames:shareType
                                       delegate:self];
    
}


#pragma mark -- 下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        }];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        
        return 215;
    }
    else if (indexPath.row == 2 || indexPath.row == 4) {

        return 64;
    }
    else if (indexPath.row == 6 || indexPath.row == 5) {

        if ([RJAccountManager sharedInstance].account.isSmallShopOpen.boolValue) {
            
            return 64;
        }
        return 0;
    }
    else if (indexPath.row == 7) {
        
        return 84;
    }
    
    return 54;
  
}

#pragma mark --设置
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
    if (indexPath.row == 7) {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        SetTableViewController *SetVC = [story instantiateViewControllerWithIdentifier:@"SetTableViewController"];
        
        [self.navigationController pushViewController:SetVC animated:YES];

    }
    
}

#pragma mark --购物袋buttonAction
- (IBAction)cartButtonAction:(id)sender {
    
    //登录了 就去购物车
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CartViewController *vc = [story instantiateViewControllerWithIdentifier:@"CartViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark -- 发布buttonAction
- (IBAction)mineReleaseButtonAction:(id)sender {
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    
    rootVc.userId = [NSNumber numberWithInteger:[[RJAccountManager sharedInstance].account.id integerValue]];
    rootVc.userName = [RJAccountManager sharedInstance].account.nickname;
    
    [self.navigationController pushViewController:rootVc animated:YES];
    
}

- (void)reloadCartItemNumber{
    if ([RJAccountManager sharedInstance].hasAccountLogin) {
        if ([RJAccountManager sharedInstance].account.cartProductQuantity) {
            _numLabel.text = [RJAccountManager sharedInstance].account.cartProductQuantity.stringValue;
        }
    }else{
        _numLabel.text = @"";
    }
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

    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/updateBackgroudImage.jhtml"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    __weak __typeof(self)weakSelf = self;
    [requestInfo.postParams setDictionary:@{@"filename":@"test",@"file":base64Str}];
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *state = responseObject[@"state"];
        if (state.intValue == 0) {
            RJAccountModel *model = [[RJAccountModel alloc]initWithDictionary:responseObject[@"data"] error:nil];
            if (model) {
                [[RJAccountManager sharedInstance]registerAccount:model];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:model.attributeValue1] placeholderImage:[UIImage imageNamed:@"bg"]];
                    
                    [weakSelf setUserInfoDataActionWithAccountModel:model];
                    
                });
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"修改成功" image:nil];

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


- (void)dealloc {
    
    //移除购物袋数量变动的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCartNumberChanged object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self];

}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
    
}
- (void)newKeFuMessage{
    self.kefuRedicon.hidden = NO;
}
@end







