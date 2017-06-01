//
//  MineFavoriteGoodsModel.h
//  ssrj
//
//  Created by YiDarren on 16/8/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol collocationListModel <NSObject>
@end
@interface collocationListModel : JSONModel
@property (strong, nonatomic) NSNumber *collocationId;
@property (strong, nonatomic) NSString *name;
@property (nonatomic,assign) BOOL isNewProduct;
@property (nonatomic,assign) BOOL isSpecialPrice;
@property (strong, nonatomic) NSString *path;
@property (strong, nonatomic) NSString *auter;
@end




@interface MineDaPeiModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *mineDaPeiModelId;
@property (strong, nonatomic) NSString<Optional> *path;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *memo;
@property (strong, nonatomic) NSNumber<Optional> *thumbsupCount;
@property (strong, nonatomic) NSNumber<Optional> *collocationCount;
@property (strong, nonatomic) NSString<Optional> *auter;
@property (strong, nonatomic) NSNumber<Optional> *userid;
@property (strong, nonatomic) NSArray <Optional> *collocationList;
@property (nonatomic,assign) BOOL isThumbsup;
@property (strong, nonatomic) NSString<Optional> *avatar;

@end
