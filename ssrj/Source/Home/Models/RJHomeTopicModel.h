//
//  RJHomeTopicModel.h
//  ssrj
//
//  Created by CC on 16/7/20.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RJHomeItemTypeTwoModel.h"
@class RJHomeTopicShareModel;
@interface RJHomeTopicModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString * path;
@property (strong, nonatomic) NSString<Optional> * paramValue1;
@property (strong, nonatomic) NSNumber<Optional> * informId;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSNumber<Optional> * hits;
@property (strong, nonatomic) NSNumber<Optional> * thumbsupCount;
@property (strong, nonatomic) NSNumber<Optional> * isThumbsup;
@property (strong, nonatomic) RJHomeTypeTwoMemberModel * member;
@property (strong, nonatomic) RJHomeTopicShareModel * inform;
/**
 *  2.2.0 新增咨询专题
 */
@property (nonatomic,strong) NSNumber<Optional> * categoryId;
@property (nonatomic,strong) NSString<Optional> * categoryName;

/*
 * 3.0.1 添加时间标签 只在用户中心发布列表的资讯cell中显示
 */
@property (strong, nonatomic) NSString <Optional> * create_date;
//新增发布列表cell来源类型
@property (strong, nonatomic) NSNumber <Optional> * event;

@end

@interface RJHomeTopicShareModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * title;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSString<Optional> * img;
@property (strong, nonatomic) NSString<Optional> * showUrl;
@property (strong, nonatomic) NSString<Optional> * shareUrl;
@end