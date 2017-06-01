//
//  RJAppManager.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCAppVersionModel.h"
#import "LaunchAnimationModel.h"
#import "ReportStatisticalDataModel.h"


static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";
static NSString * const kNotificationAppShouldUpdate = @"appShouldUpdate";
static NSString *const UDkUpdateIgnoredVersion = @"Update Ignored Version";

static NSString *const kGetAPNSMessageNotification = @"kGetAPNSMessageNotification";
/**
 *  上报服务器的用户标识符 生产规则是当前时间加随机数
 */
static NSString *const RJCustomerDeviceIDKey = @"RJCustomerDeviceIDKey";

/**
 *  第一次进入界面 新手引导界面
 */
static NSString *const RJFirstInGouYiZhuShou = @"RJFirstInGouYiZhuShou";
static NSString *const RJFirstInZuoTi = @"RJFirstInZuoTi";
static NSString *const RJFirstInDaPei = @"RJFirstInDaPei";
static NSString *const RJFirstInHome = @"RJFirstInHome";
static NSString *const RJFirstInChuanDa = @"RJFirstInChuanDa";

static NSString *const CCLuanchADDataKey = @"CCLuanchADDataKey";
//有新客服消息
static NSString * const kStatusNewKeFuMessageNotification = @"statusNewKeFuMessageNotification";
static NSString *const  RJFirstInGoodList = @"RJFirstInGoodList";

@interface RJAppManager : NSObject
+ (instancetype)sharedInstance;
//应用更新信息
@property (strong, nonatomic) CCAppVersionModel *versionInfo;
/// 新版本是否已忽略
@property (readwrite, nonatomic) BOOL versionIgnored;
/// 是否强制用户升级
@property (readwrite, nonatomic) BOOL needsForceUpdate;
/**
 *  是否有新版本
 */
@property (readwrite, nonatomic) BOOL hasNewVersion;
/**
 *  2.2.0 点击首页品牌要去分类页面 并且品牌界面要选中
 */
@property (nonatomic, assign) BOOL didClickHomeBrand;
@property (nonatomic,strong) NSString * IDFA;
/**
 *  统计模块的debug 开关
 */

@property (nonatomic, assign) BOOL trackingDebug;

//统计上报时用于接收加入和移除的模型对象 add 12.16
@property (strong, nonatomic) NSMutableArray *statisticalModelArr;


/**
 *  客服是否有新消息 红点亮不亮
 */
@property (nonatomic,assign) BOOL isNewKeFuMessage;


- (void)configureApp;
- (void)cheackAppVersion;

// 检查应用版本
- (void)checkAppVersionIsInitiative:(BOOL)flag;
- (UIViewController*)currentViewController;
- (NSString*)currentViewControllerName;

- (void)showTokenDisableLoginVc;
- (void)showTokenDisableLoginVcWithMessage:(NSString *)msg;
- (UINavigationController *)getLoginViewController;

- (NSString *)nowTimeString;
- (NSString *)nowTimeFullString;

- (NSDate *)localNowDate;
- (void)checkAppLaunchAdData;
- (void)displayLaunchAnimationWithModel:(LaunchAnimationModel *)model;

//上报统计数据 add 12.16
- (void)reportStatisticalDataWithModel:(ReportStatisticalDataModel *)model mutableArr:(NSMutableArray *)arr;
//- (NSNumber *)getCustomerIdWithView:(UIView *)view rootView:(UIView *   )rootView TagId:(NSInteger)tag;
//- (NSString *)getCustomerIdentiferWihtView:(UIView *)viewOne;


- (void)trackingWithTrackingId:(NSString *)trackingId;

/**
 *  便利统计model数据库 生成json串上报给服务器
 */
- (void)uploapTrackingDataWithSql;
/**
 *  json串上报失败的存进数据库 下次启动便利 然后上传
 */
- (void)uploapTrackingJsonStingWithSql;


/**
 *  debug 模式下 查看统计事件
 */
- (BOOL)scanAllViewWithView:(UIView *)view;
//- (BOOL)scanAllTableCellWithView:(UIView *)view;
//- (BOOL)scanAllCollectionCellWithView:(UIView *)view;
//- (void)upLoadTrackingDataWithView:(UIView *)view;


@end





