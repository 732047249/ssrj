//
//  DiscoveryThemeModel.h
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RecommendCollectionsModel.h"
#import "RJHomeItemTypeTwoModel.h"
#import "RJShareBasicModel.h"
//主题搭配内(cell内)的用户个人信息
@protocol memberInfoData <NSObject>
@end
@interface memberInfoData : JSONModel
@property (strong,nonatomic)NSNumber<Optional> *memberId;
@property (strong,nonatomic)NSString<Optional> *mobile;
@property (strong,nonatomic)NSString<Optional> *name;
@property (strong,nonatomic)NSString<Optional> *avatar;
@property (strong,nonatomic)NSString<Optional> *userid;
@end


//主题集合
@protocol ThemeCollocationList <NSObject>
@end
@interface ThemeCollocationList : JSONModel
@property (nonatomic,strong)NSNumber<Optional> *collocationId;
@property (nonatomic,strong)NSString<Optional> *memo;
@property (nonatomic,strong)NSString<Optional> *name;
@property (nonatomic,strong)NSString<Optional> *picture;
@property (nonatomic,strong)NSString<Optional> *userName;
@property (nonatomic,strong)NSNumber<Optional> *isNewProduct;
@property (nonatomic,strong)NSNumber<Optional> *isSpecialPrice;
@property (nonatomic,assign)BOOL isThumbsup;
@property (nonatomic,strong)memberInfoData<Optional> *memberPO;
//3.1.0 添加标签 使用
@property (nonatomic, strong) NSNumber<Optional> *status;
@property (nonatomic, strong) NSString<Optional> *draft;
//合辑详情，连兵说已经有collocationImages这个字段了，所以单独处理，用了另一个字段
@property (nonatomic, strong) NSArray<Optional,HHPCCollocationPositionModel> *collocationImagesList;
@property (nonatomic, strong) NSArray<Optional,HHPCCollocationPositionModel> *collocationImages;
@property (strong, nonatomic) NSArray<RJBaseGoodModel> * goodsList;
@end




//对主题关注或点赞、收藏过的粉丝
@protocol fansMemberList <NSObject>
@end
@interface fansMemberList : JSONModel
@property (strong,nonatomic)NSNumber<Optional> *fansMemberListId;
@property (strong,nonatomic)NSString<Optional> *mobile;
@property (strong,nonatomic)NSString<Optional> *name;
@property (strong,nonatomic)NSString<Optional> *avatar;
@property (strong,nonatomic)NSString<Optional> *userid;
@end



//主题大json字段
@interface ThemeData: JSONModel
@property (nonatomic,strong)NSNumber<Optional> *themeCollectionId;
@property (nonatomic,strong)NSString<Optional> *memo;
@property (nonatomic,strong)NSString<Optional> *name;
@property (nonatomic,strong)NSString<Optional> *picture;
@property (nonatomic,strong)NSNumber<Optional> *member;
@property (nonatomic,strong)NSNumber<Optional> *thumbsupCount;
@property (nonatomic,strong)NSString<Optional> *avatar;
@property (nonatomic,strong)NSString<Optional> *userName;
@property (nonatomic,strong)CommentModel *comment;
//搭配数
@property (nonatomic, strong)NSNumber<Optional> *countCollocation;
//是否点过赞
@property (nonatomic, assign)BOOL thumbsup;
//对主题关注或点赞、收藏过的用户 （Json串中暂没有该字段，打开data==nil）
@property (nonatomic,strong)NSArray<Optional> *memberList;
//该主题搭配集合
@property (nonatomic,strong)NSArray<Optional,ThemeCollocationList> *collocationList;
/**
 *  新增字段：合辑详情评论数  9.26
 */
@property (strong, nonatomic)NSNumber<Optional> *countComment;
/**
 *  新增分享信息 2.2.0
 */
@property (nonatomic,strong) RJShareBasicModel<Optional> * shareInfo;

@end



@interface ThemeDetailModel : JSONModel
@property (nonatomic,strong)NSNumber<Optional> *state;
@property (nonatomic,strong)NSString<Optional> *msg;
@property (nonatomic,strong)ThemeData<Optional> *data;
@property (nonatomic,strong)NSString<Optional> *token;
@end
