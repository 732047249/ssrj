//
//  RecommendCollectionsModel.h
//  ssrj
//
//  Created by MFD on 16/6/17.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicGoodModel.h"
#import "AddToNewThemeModel.h"
#import "RJBaseGoodModel.h"
#import "RJHomeItemTypeTwoModel.h"

//(cell内)的用户个人信息
@protocol MemberData <NSObject>
@end
@interface MemberData : JSONModel
@property (strong,nonatomic)NSNumber<Optional> *memberId;
@property (strong,nonatomic)NSString<Optional> *mobile;
@property (strong,nonatomic)NSString<Optional> *name;
@property (strong,nonatomic)NSString<Optional> *avatar;
@property (strong,nonatomic)NSNumber<Optional> *userid;
@end

//评论模型
@protocol CommentListModel<NSObject>

@end
@interface CommentListModel : JSONModel
@property (strong,nonatomic)MemberData<Optional>* replyMember;
@property (strong,nonatomic)MemberData<Optional>* member;
@property (strong,nonatomic)NSNumber<Optional>* isActiveUser;
@property (strong,nonatomic)NSString<Optional>* comment;
@property (strong,nonatomic)NSString<Optional>* createDate;
@property (strong,nonatomic)NSNumber<Optional>* commentId;
@end



@protocol  CommentModel<NSObject>
@end
@interface CommentModel : JSONModel
@property (nonatomic,strong)NSNumber<Optional>* id;
@property (nonatomic,strong)NSNumber<Optional>* countComment;
@property (nonatomic,strong)NSArray<Optional,CommentListModel>* commentList;
@end




//@interface AvatarModel : JSONModel
//@property (nonatomic,strong)NSString <Optional>*mediumPath;
//@property (nonatomic,strong)NSString <Optional>*thumbnailPath;
//@property (nonatomic,strong)NSString <Optional>*largePath;
//@end


//tag模型
/*"id":804,
"isThumbsup":false,
"collocationCount":0,
"path":"http://www.ssrj.cn/static/upload/image/2016/6/24/5ed8dc4f-ed6d-44a0-b26b-0fc6a9cdba04.jpg",
"name":"修饰腿型开叉裙",
"memo":"露腿就要露的最性感还显腿细长，试试开叉裙，腿部视觉增长三厘米！",
"thumbsupCount":1
*/
@protocol ThemeItemListModel<NSObject>

@end
@interface ThemeItemListModel : JSONModel
@property (nonatomic,strong)NSNumber<Optional> *themeItemId;
@property (nonatomic,strong)NSNumber<Optional> *isThumbsup;
@property (nonatomic,strong)NSNumber<Optional> *collocationCount;
@property (nonatomic,strong)NSString<Optional> *path;
@property (nonatomic,strong)NSString<Optional> *name;
@property (nonatomic,strong)NSString<Optional> *memo;
@property (nonatomic,strong)NSNumber<Optional> *thumbsupCount;
@end

//header的模型
@interface NowCollocationModel : JSONModel

@property (nonatomic,strong)NSNumber *nowCollectionId;
@property (nonatomic,strong)NSNumber<Optional> *exchangePoint;
@property (nonatomic,strong)NSString<Optional> *picture;
@property (nonatomic,strong)NSNumber<Optional> *thumbsupCount;
@property (nonatomic,strong)NSNumber<Optional> *favoriteCount;
@property (nonatomic,strong)NSNumber<Optional> *memberId;
@property (nonatomic,strong)NSString<Optional> *name;
@property (nonatomic,strong)NSNumber<Optional> *commentCount;
@property (nonatomic,strong)NSString<Optional> *autherName;
@property (nonatomic,strong)NSString<Optional> *memo;
@property (nonatomic,strong)AvatarModel<Optional> *avatar;
@property (nonatomic,strong)NSNumber<Optional> *thumbsup;
@property (nonatomic,strong)NSNumber<Optional> *type;
@property (nonatomic,strong)NSArray<Optional,ThemeItemListModel> *themeItemList;
@property (nonatomic,strong)CommentModel<Optional>* comment;
@property (nonatomic,strong)NSString<Optional> *draft;
@property (nonatomic,strong)NSNumber<Optional> *status;
/**
 *  新增分享
 */
@property (nonatomic,strong) RJShareBasicModel<Optional> * shareInfo;
/**
    新增3.1.0 标签
 */
@property (nonatomic, strong) NSArray<Optional,RJBaseGoodModel> *goodsList;
@property (nonatomic, strong) NSArray<Optional,HHPCCollocationPositionModel> *collocationImages;
@end


@protocol  SingleProductModel<NSObject>

@end
@interface SingleProductModel : JSONModel
@property (nonatomic,strong)NSString<Optional> *image;
@property (nonatomic,strong)NSNumber<Optional> *goodsId;
@property (nonatomic,strong)NSNumber<Optional> *marketPrice;
@property (nonatomic,strong)NSNumber<Optional> *price;
@property (nonatomic,strong)NSNumber<Optional> *exchangePoint;
@property (nonatomic,strong)NSString<Optional> *color;
@property (nonatomic,strong)NSString<Optional> *name;
@property (nonatomic,strong)NSString<Optional> *autherName;
@property (nonatomic,strong)NSNumber<Optional> *effectivePrice;
@property (nonatomic,strong)NSNumber<Optional> *effectiveDiscount;
@property (nonatomic,strong)NSNumber<Optional> *type;

//是否是新品
@property (strong, nonatomic) NSNumber<Optional> * isNewProduct;
@property (strong, nonatomic) NSNumber<Optional> * isSpecialPrice;

@property (strong, nonatomic) NSString<Optional> * brandName;
@end


@protocol  CollocationsItem<NSObject>

@end
@interface CollocationsItem : JSONModel
@property (nonatomic,strong)NSNumber<Optional> *collocationId;
@property (nonatomic,strong)NSNumber<Optional> *exchangePoint;
@property (nonatomic,strong)NSString<Optional> *picture;
@property (nonatomic,strong)NSNumber<Optional> *thumbsupCount;
@property (nonatomic,strong)NSNumber<Optional> *favoriteCount;
@property (nonatomic,strong)NSString<Optional> *name;
@property (nonatomic,strong)NSNumber<Optional> *commentCount;
@property (nonatomic,strong)NSString<Optional> *autherName;
@property (nonatomic,strong)NSNumber<Optional> *type;
@property (nonatomic,strong)MemberData<Optional> * member;
@property (nonatomic,strong)NSNumber<Optional> *thumbsup;
//3.1.0 添加的字段，用来添加标签
@property (nonatomic, strong) NSNumber<Optional> *status;
@property (nonatomic, strong) NSString<Optional> *draft;
@property (nonatomic, strong) NSArray<Optional,RJBaseGoodModel> *goodsList;
@property (nonatomic, strong) NSArray<Optional,HHPCCollocationPositionModel> *collocationImages;

@end


@interface CollectionsDataModel : JSONModel
@property (nonatomic,strong)NowCollocationModel<Optional> *nowCollocation;
@property (nonatomic,strong)NSArray<Optional,SingleProductModel> *singleProduct;
@property (nonatomic,strong)NSArray<Optional,CollocationsItem> *collocations;
@end


@interface RecommendCollectionsModel : JSONModel
@property (nonatomic,strong)NSNumber<Optional> *state;
@property (nonatomic,strong)NSString<Optional> *msg;
@property (nonatomic,strong)CollectionsDataModel<Optional> *data;
@property (nonatomic,strong)NSString<Optional> *token;
@end


