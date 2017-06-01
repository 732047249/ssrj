//
//  RJBaseGoodModel.h
//  ssrj
//
//  Created by CC on 16/5/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RJGoodDetailModel.h"
/**
 *  新API 商品Model
 "colorName": "蓝色",
 "weight": "null",
 "memo": null,
 "isNonSell": "false",
 "colorId": "25",
 "kaolaKey": null,
 "mobilePath": "/mobile/goods/content/201605/1635.html",
 "brandId": "124",
 "brandName": "Cutie London",
 "id": "1635",
 "isgather": "false",
 "isthumb": "false",
 "cloth": "100% 聚酯纤维",
 "maxImage": "http://www.ssrj.com/upload/image/201605/362f5c8f-808e-47a9-a4d3-e5db09b18ed3-max.png",
 "mediumImage": "http://www.ssrj.com/upload/image/201605/362f5c8f-808e-47a9-a4d3-e5db09b18ed3-medium.png",
 "name": "蓝色方格衬衫",
 "path": "/default/goods/content/201605/1635.html",
 "productCategoryName": "衬衫",
 "default_img": "/resources/shop/mobile/images/default_goods.png",
 "productRelationId": "null",
 "marketPrice": "315.000000",
 "sn": "C5622",
 "footageImage": "http://www.ssrj.com/upload/image/201605/c1e77cfe-0744-4e0e-ad0e-2ed5637f8174.jpg",
 "largeImage": "http://www.ssrj.com/upload/image/201605/362f5c8f-808e-47a9-a4d3-e5db09b18ed3-large.png",
 "image": "http://www.ssrj.com/upload/image/201605/362f5c8f-808e-47a9-a4d3-e5db09b18ed3-source.png",
 "isMarketable": "true",
 "caption": null,
 "downTime": null,
 "discount": "8.4",
 "effectivePrice": "263",
 "unit": null,
 "thumbnail": "http://www.ssrj.com/upload/image/201605/362f5c8f-808e-47a9-a4d3-e5db09b18ed3-thumbnail.png",
 "price": "263.000000",
 "upTime": "2016-05-13",
 "productCategoryId": "265"
 */


@protocol RJGoodListImageListModel;
@protocol RJBaseGoodModel <NSObject>



@end

@interface RJBaseGoodModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * colorName;
@property (strong, nonatomic) NSString<Optional> * weight;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSNumber<Optional> * isNonSell;
@property (strong, nonatomic) NSString<Optional> * colorId;
@property (strong, nonatomic) NSString<Optional> * kaolaKey;
@property (strong, nonatomic) NSString<Optional> * mobilePath;
@property (strong, nonatomic) NSString<Optional> * brandId;
@property (strong, nonatomic) NSString<Optional> * brandName;
@property (strong, nonatomic) NSString * goodId;
@property (strong, nonatomic) NSNumber<Optional> * isgather;
@property (strong, nonatomic) NSNumber<Optional> * isthumb;
@property (strong, nonatomic) NSNumber<Optional> * isThumbsup;
@property (strong, nonatomic) NSString<Optional> * cloth;
@property (strong, nonatomic) NSString<Optional> * maxImage;
@property (strong, nonatomic) NSString<Optional> * mediumImage;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSString<Optional> * path;
@property (strong, nonatomic) NSString<Optional> * productCategoryName;
@property (strong, nonatomic) NSString<Optional> * default_img;
@property (strong, nonatomic) NSString<Optional> * productRelationId;
@property (strong, nonatomic) NSString<Optional> * marketPrice;
@property (strong, nonatomic) NSString<Optional> * sn;
@property (strong, nonatomic) NSString<Optional> * footageImage;
@property (strong, nonatomic) NSString<Optional> * largeImage;
@property (strong, nonatomic) NSString<Optional> * image;
@property (strong, nonatomic) NSString<Optional> * source;
@property (strong, nonatomic) NSNumber<Optional> * isMarketable;
@property (strong, nonatomic) NSString<Optional> * caption;
@property (strong, nonatomic) NSString<Optional> * downTime;
@property (strong, nonatomic) NSString<Optional> * discount;
@property (strong, nonatomic) NSString<Optional> * effectivePrice;
@property (strong, nonatomic) NSString<Optional> * unit;
@property (strong, nonatomic) NSString<Optional> * thumbnail;
@property (strong, nonatomic) NSString<Optional> * price;
@property (strong, nonatomic) NSString<Optional> * upTime;
@property (strong, nonatomic) NSString<Optional> * productCategoryId;
//是否是新品
@property (strong, nonatomic) NSNumber<Optional> * isNewProduct;
@property (strong, nonatomic) NSNumber<Optional> * isSpecialPrice;
/**
 *  商品list里面新增字段 每次返回三个imageview
 */
@property (strong, nonatomic) NSArray<Optional,RJGoodListImageListModel> * imgsList;

// --- 3.1.0 --- //
/** 商品添加时尚币字段 */
@property (nonatomic, strong) NSString<Optional> *fashionCurrency;
/** 添加购物车需要的详情页的字段 */
@property (nonatomic, strong) RJGoodDetailModel<Optional> *detail;
/** 标记是否被选中，用在添加单品到Yi店页 */
@property (nonatomic, strong) NSNumber<Ignore> *selected;

@end

@protocol RJGoodListImageListModel <NSObject>

@end
@interface RJGoodListImageListModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * imgThumbnail;
@property (strong, nonatomic) NSString<Optional> * imgTitle;
@property (nonatomic, strong) NSString<Optional> *videoPath;

@end


