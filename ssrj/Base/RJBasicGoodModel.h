//
//  RJBasicGoodModel.h
//  ssrj
//
//  Created by CC on 16/5/17.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "JSONModel.h"
/**
 *  商品的基类 包含商品的一些信息
 
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

@protocol RJBasicGoodModel <NSObject>

@end


@interface RJBasicGoodModel : JSONModel
@property (copy, nonatomic) NSString * id;
@property (copy, nonatomic) NSString<Optional> * effectivePrice;
@property (copy, nonatomic) NSString<Optional> * marketPrice;
@property (copy, nonatomic) NSString<Optional> * price;
@property (copy, nonatomic) NSString<Optional> * name;
@property (copy, nonatomic) NSString<Optional> * image;
@property (copy, nonatomic) NSString<Optional> * mobilePath;
@property (copy, nonatomic) NSString<Optional> * brand_name;
@property (copy, nonatomic) NSString<Optional> * discount;
@property (copy, nonatomic) NSString<Optional> * category_name;
@property (copy, nonatomic) NSString<Optional> * path;
@property (strong, nonatomic) NSNumber<Optional> * thumbsup_flag;
@property (strong, nonatomic) NSNumber<Optional> * gather_flag;
@property (strong, nonatomic) NSNumber<Optional> * isgather;
@property (strong, nonatomic) NSNumber<Optional> * isthumb;
@property (copy, nonatomic) NSString<Optional> * default_img;

@end


