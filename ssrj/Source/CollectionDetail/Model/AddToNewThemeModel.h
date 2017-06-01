//
//  AddToNewThemeModel.h
//  ssrj
//
//  Created by YiDarren on 16/7/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@class RecommendCollectionsModel;
@protocol ThemeItemListModel;
@protocol AvatarModel <NSObject>
@end
@interface AvatarModel : JSONModel

@property (strong, nonatomic) NSString<Optional> *mediumPath;
@property (strong, nonatomic) NSString<Optional> *thumbnailPath;
@property (strong, nonatomic) NSString<Optional> *largePath;

@end



@interface AddToNewThemeModel : JSONModel

@property (strong, nonatomic) NSNumber<Optional> *collocationId;
@property (strong, nonatomic) NSNumber<Optional> *exchangePoint;
@property (strong, nonatomic) NSString<Optional> *picture;
@property (strong, nonatomic) NSNumber<Optional> *thumbsupCount;
@property (strong, nonatomic) NSNumber<Optional> *favoriteCount;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSNumber<Optional> *commentCount;
@property (strong, nonatomic) NSString<Optional> *autherName;
@property (strong, nonatomic) NSString<Optional> *memo;
@property (strong, nonatomic) AvatarModel<Optional> *avatar;
@property (strong, nonatomic) NSNumber<Optional> *isSpecialPrice;
@property (strong, nonatomic) NSNumber<Optional> *isNewProduct;
@property (strong, nonatomic) NSMutableArray<Optional,ThemeItemListModel> *themeItemList;
@property (strong, nonatomic) NSNumber<Optional> *thumbsup;
@property (strong, nonatomic) NSNumber<Optional> *type;

//用户ID 9.29
@property (strong, nonatomic) NSNumber *memberId;

@property (strong, nonatomic) NSNumber <Optional> *isPublished;



@end
