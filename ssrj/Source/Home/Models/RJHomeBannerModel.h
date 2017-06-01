//
//  RJHomeBannerModel.h
//  ssrj
//
//  Created by CC on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol RJHomeBannerModel <NSObject>

@end

@class RJHomeBannerItemModel;
/**
 *  首页Banner图Model
 */
@interface RJHomeBannerModel : JSONModel
@property (strong, nonatomic) NSNumber * type;
@property (strong, nonatomic) RJHomeBannerItemModel * data;
@end


@interface RJHomeBannerItemModel : JSONModel
@property (strong, nonatomic) NSNumber  * id;
@property (strong, nonatomic) NSString<Optional> * path;
/**
 *  后期活动时候可能打开是一个Url
 */
@property (strong, nonatomic) NSString<Optional> * url;
@property (strong, nonatomic) NSString<Optional> * paramValue;

/**
 *  新加字段 有些活动分享要登录
 */
@property (strong, nonatomic) NSString<Optional> * share_url;
@property (strong, nonatomic) NSNumber<Optional> * isLogin;
/**
 *  普通活动 分享链接是固定的 同首页咨询的分享Model
 */
@property (strong, nonatomic) RJShareBasicModel<Optional> * inform;
@property (strong, nonatomic) NSString<Optional> * shareType;
/**
 *  2.2.0 新增title 在type0 type 2 里面使用 统计用
 */
@property (nonatomic,strong) NSString<Optional> * title;
@end
