//
//  RJAccountModel.h
//  ssrj
//
//  Created by CC on 16/5/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
/**
 *  {
 "message": {
 "type": "success",
 "content": "恭喜您，账号注册成功！"
 },
 "data": {
 "userid": "MFD2016052632926",
 "attributeValue7": null,
 "attributeValue6": null,
 "attributeValue5": null,
 "avatar": "{\"mediumPath\":\"http://www.ssrj.com/upload/image/default_avatar_medium.jpg\",\"thumbnailPath\":\"http://www.ssrj.com/upload/image/default_avatar_thumbnail.jpg\",\"largePath\":\"http://www.ssrj.com/upload/image/default_avatar_large.jpg\"}",
 "password": "e10adc3949ba59abbe56e057f20f883e",
 "isEnabled": true,
 "registerIp": "192.168.1.192",
 "isLocked": false,
 "id": 16457,
 "amount": 0,
 "point": 0,
 "wxopenid": null,
 "balance": 0,
 "username": "13556567876",
 "attributeValue1": "http://www.ssrj.com/upload/image/201511/aa5b0f63-15b0-4a99-89b9-b5cced29ed4d.gif",
 "loginIp": "192.168.1.192",
 "attributeValue2": null,
 "address": null,
 "email": null,
 "wxnickname": null,
 "zipCode": null,
 "loginFailureCount": 0,
 "mobile": "13556567876"
 }
 }
 */
@protocol RJAccountAvatar <NSObject>



@end


@interface RJAccountAvatar : JSONModel
@property (strong, nonatomic) NSString<Optional> * mediumPath;
@property (strong, nonatomic) NSString<Optional> * thumbnailPath;
@property (strong, nonatomic) NSString<Optional> * largePath;

@end



@interface RJAccountModel : JSONModel

@property (strong, nonatomic) NSString * userid;
@property (strong, nonatomic) NSString * token;
@property (strong, nonatomic) NSString<Optional> * attributeValue7;
@property (strong, nonatomic) NSString<Optional> * attributeValue6;
@property (strong, nonatomic) NSString<Optional> * attributeValue5;

@property (strong, nonatomic) NSString<Optional> * avatar;

@property (strong, nonatomic) NSString<Optional> * password;
@property (strong, nonatomic) NSString<Optional> * isEnabled;
@property (strong, nonatomic) NSString<Optional> * registerIp;
@property (strong, nonatomic) NSNumber<Optional> * isLocked;
@property (strong, nonatomic) NSNumber<Optional> * id;
@property (strong, nonatomic) NSNumber<Optional> * amount;
@property (strong, nonatomic) NSNumber<Optional> * point;
@property (strong, nonatomic) NSString<Optional> * wxopenid;
@property (strong, nonatomic) NSNumber<Optional> * balance;
@property (strong, nonatomic) NSString<Optional> * username;
@property (strong, nonatomic) NSString<Optional> * attributeValue1;
@property (strong, nonatomic) NSString<Optional> * loginIp;
@property (strong, nonatomic) NSString<Optional> * attributeValue2;
@property (strong, nonatomic) NSString<Optional> * address;
@property (strong, nonatomic) NSString<Optional> * email;
@property (strong, nonatomic) NSString<Optional> * wxnickname;
@property (strong, nonatomic) NSString<Optional> * zipCode;
@property (strong, nonatomic) NSNumber<Optional> * loginFailureCount;
@property (strong, nonatomic) NSString<Optional> * mobile;
@property (strong, nonatomic) NSString<Optional> * gender;//add by 6.28
@property (strong, nonatomic) NSString<Optional> * nickname;//add by 6.29
@property (strong, nonatomic) NSNumber<Optional> * memberRank;//add by 7.1
@property (strong, nonatomic) NSString<Optional> * introduction;//个人介绍
@property (strong, nonatomic) NSNumber<Optional> * cartQuantity;//购物车订单数量（同一商品n件记为一件）
@property (strong, nonatomic) NSNumber<Optional> * cartProductQuantity;//购物车订单数量（按商品数量来，重复则累加）
@property (strong, nonatomic) NSNumber<Optional> * favoriteGoods;//收藏的单品
@property (strong, nonatomic) NSNumber<Optional> * favoriteInforms;//收藏的资讯
@property (strong, nonatomic) NSNumber<Optional> * favoriteThemeItems;//收藏的主题
@property (strong, nonatomic) NSNumber<Optional> * favoriteCollocations;//收藏的搭配数量
@property (strong, nonatomic) NSNumber<Optional> * isBinding;//三方登录是否绑定手机号
@property (strong, nonatomic) NSString<Optional> * memberName;//add 9.29
/**
 *  8.4日 新增穿衣助手是否答过题的字段
 */
@property (strong, nonatomic) NSNumber<Optional> * isSurvey;

//新增字段 10.8
@property (strong, nonatomic) NSNumber<Optional> * subscribeCount;//关注数 10.8
@property (strong, nonatomic) NSNumber<Optional> * fansCount;//粉丝数 10.8
@property (strong, nonatomic) NSNumber<Optional> * releaseCount;//发布数 11.17
//v3.0.1
@property (strong, nonatomic) NSNumber<Optional> * isSmallShopOpen;//是否开了微店2.20


@end

