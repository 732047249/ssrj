//
//  RJHomeItemTypeFourModel.h
//  ssrj
//
//  Created by CC on 16/6/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#include "RJBasicMemberModel.h"
#import "RJCommentListModel.h"
#import "RJHomeItemTypeTwoModel.h"
#import "NSAttributedString+YYText.h"
@class RJHomeTypeFourMeneberModel;
@class RJHomeItemTypeFourShareModel;

@protocol RJHomeTypeFourCollectionModel;
/**
 *  主题带搭配Model
 */

@interface RJHomeItemTypeFourModel : JSONModel
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSNumber<Optional> * thumbsupCount;
@property (strong, nonatomic) NSNumber<Optional> * collocationCount;
@property (strong, nonatomic) RJHomeTypeFourMeneberModel * member;
@property (strong, nonatomic) NSArray<RJHomeTypeFourCollectionModel> * collocationList;
@property (strong, nonatomic) NSString<Optional> * path;

@property (strong, nonatomic) NSNumber<Optional> * isThumbsup;

//add 11.15 for 分享合辑详情
@property (strong, nonatomic) NSNumber<Optional> * themeItemId;
@property (strong, nonatomic) RJHomeItemTypeFourShareModel<Optional> * themeItemInfo;
/**
 *  用户发布界面 新增评论。。。。
 */
@property (nonatomic,strong) RJCommentListModel<Optional> * comment;


@property (nonatomic,strong) NSNumber<Ignore> *commentHeight;
@property (nonatomic,strong) NSNumber<Ignore> *commentOneHeight;
@property (nonatomic,strong) NSNumber<Ignore> *commentTwoHeight;
@property (nonatomic,strong) NSNumber<Ignore> *commentThreeHeight;
//@property (nonatomic,strong) NSNumber<Ignore> *descriptionHeight;

/**
 *  3.0.0
 */
@property (nonatomic,strong) NSNumber<Optional> *is_publish;

/**
 *  3.0.1 合辑创建或点赞时间
 */
@property (nonatomic,strong) NSString <Optional>* create_date;
//新增发布列表cell来源类型
@property (strong, nonatomic) NSNumber <Optional> * event;

/**
 *  3.1 标签显示
 */
@property (nonatomic, strong) NSArray<Optional,RJBaseGoodModel> *goodsInfo;
@property (nonatomic, strong) NSArray<Optional,HHPCCollocationPositionModel> *collocationImages;
@property (nonatomic, strong) NSString<Optional> *draft;

- (void)upDateLayout;


@end

//add 11.15 for 分享合辑详情 模型
@interface RJHomeItemTypeFourShareModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * title;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSString<Optional> * img;
@property (strong, nonatomic) NSString<Optional> * showUrl;
@property (strong, nonatomic) NSString<Optional> * shareUrl;
@end



@interface RJHomeTypeFourMeneberModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * mobile;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSString<Optional> * avatar;
@property (strong, nonatomic) NSString<Optional> * userid;
@end


@protocol RJHomeTypeFourCollectionModel <NSObject>

@end

@interface RJHomeTypeFourCollectionModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSNumber<Optional> * isNewProduct;
@property (strong, nonatomic) NSNumber<Optional> * isSpecialPrice;
@property (strong, nonatomic) NSString<Optional> * path;
@property (strong, nonatomic) NSString<Optional> * auter;
@property (strong, nonatomic) NSNumber<Optional> * isThumbsup;
/**
 *  2.2.0 新增member信息
 */
@property (nonatomic,strong) RJBasicMemberModel<Optional> * memberPO;

@end
