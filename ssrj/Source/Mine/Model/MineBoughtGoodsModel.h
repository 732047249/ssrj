//
//  MineBoughtGoodsModel.h
//  ssrj
//
//  Created by YiDarren on 16/8/6.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol MineSingleGoodsImageListModel <NSObject>
@end

@interface MineSingleGoodsImageListModel : JSONModel
@property (strong, nonatomic) NSString <Optional>*imgThumbnail;
//@property (strong, nonatomic) NSString <Optional>*imgTitle;
@end



@interface MineBoughtGoodsModel : JSONModel

@property (strong, nonatomic) NSNumber<Optional> *MineBoughtGoodsId;
@property (strong, nonatomic) NSNumber<Optional> *discount;
@property (strong, nonatomic) NSNumber<Optional> *effectivePrice;
@property (strong, nonatomic) NSNumber<Optional> *marketPrice;
@property (strong, nonatomic) NSNumber<Optional> *price;
@property (strong, nonatomic) NSString<Optional> *image;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *memo;
@property (strong, nonatomic) NSNumber<Optional> *thumbsupCount;
@property (nonatomic,assign) BOOL isNewProduct;
@property (nonatomic,assign) BOOL isSpecialPrice;
@property (strong, nonatomic) NSString<Optional> *brandName;
@property (strong, nonatomic) NSString<Optional> *path;
@property (nonatomic,assign) BOOL isStock;
@property (nonatomic,assign) BOOL isThumbsup;
/**
 *  单品内的三张图片
 */
@property (strong, nonatomic) NSArray <Optional> *imgsList;


@end








