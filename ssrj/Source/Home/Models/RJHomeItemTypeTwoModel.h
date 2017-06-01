//
//  RJHomeItemTypeTwoModel.h
//  ssrj
//
//  Created by CC on 16/6/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RJBaseGoodModel.h"
#import "RJCommentListModel.h"
#import "YYLabelLayoutModel.h"
@class RJHomeItemTypeTwoShareModel;
@class RJHomeTypeTwoMemberModel;
@class RecommendCollectionsModel;
@protocol ThemeItemListModel;
@protocol HHPCCollocationPositionModel;

@interface RJHomeItemTypeTwoModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * path;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSNumber<Optional> * thumbsupCount;
@property (strong, nonatomic) NSArray<RJBaseGoodModel> * goodsList;
@property (strong, nonatomic) RJHomeTypeTwoMemberModel * member;
/**
 *  新增的分享信息
 */
@property (strong, nonatomic) RJHomeItemTypeTwoShareModel<Optional> *inform;

/**
 *  新加属性 在搭配List
 */
@property (strong, nonatomic) NSNumber<Optional> * isJingxuan;
@property (strong, nonatomic) NSNumber<Optional> * favoriteCount;
@property (strong, nonatomic) NSNumber<Optional> * isThumbsup;
/**
 *  2.2.0 新增首页也要现实所属的标签
 */
@property (nonatomic,strong) NSArray<Optional,ThemeItemListModel> *themeTagList;


/**
 *  3.0.1 创建或点赞时间
 */
@property (nonatomic,strong) NSString <Optional> * create_date;
//新增发布列表cell来源类型
@property (strong, nonatomic) NSNumber <Optional> * event;


/**
 *  3.3.0 在用不发布界面新增评论展示
 */
@property (nonatomic,strong) RJCommentListModel<Optional> * comment;


@property (nonatomic,strong) NSNumber<Ignore> *commentHeight;
@property (nonatomic,strong) NSNumber<Ignore> *commentOneHeight;
@property (nonatomic,strong) NSNumber<Ignore> *commentTwoHeight;
@property (nonatomic,strong) NSNumber<Ignore> *commentThreeHeight;
//@property (nonatomic,strong) NSNumber<Ignore> *descriptionHeight;

/**
 3.1.0 增加单品位置信息字段，来添加标签。
 */
@property (nonatomic, strong) NSArray<Optional,HHPCCollocationPositionModel> *collocationImages;
/**
  3.1.0增加单品位置信息字段，来添加标签。
 */
@property (nonatomic, strong) NSString<Optional> *draft;
/**
 搭配类型
 */
@property (nonatomic, strong) NSNumber<Optional> *status;
@property (nonatomic, strong) NSArray<Optional,RJBaseGoodModel> *goodsInfo;
- (void)upDateLayout;

@end

@interface RJHomeTypeTwoMemberModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * mobile;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *avatar;
@property (strong, nonatomic) NSString<Optional> *userid;


@end



//搭配详情分享shareModel
@interface RJHomeItemTypeTwoShareModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * title;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSString<Optional> * img;
@property (strong, nonatomic) NSString<Optional> * showUrl;
@property (strong, nonatomic) NSString<Optional> * shareUrl;
@end

//搭配详情单品位置信息（pc端上传的搭配）
@interface HHPCCollocationPositionModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * top;
@property (strong, nonatomic) NSString<Optional> * height;
@property (strong, nonatomic) NSString<Optional> * zindex;
@property (strong, nonatomic) NSString<Optional> * left;
@property (strong, nonatomic) NSString<Optional> * width;
@property (nonatomic, strong) NSString *goodsId;
@end
