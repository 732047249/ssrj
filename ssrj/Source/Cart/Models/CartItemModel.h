//
//  CartItemModel.h
//  ssrj
//
//  Created by CC on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@class CartProductModel;
@protocol CartItemModel <NSObject>

@end

@protocol CartProductModel <NSObject>

@end
@interface CartItemModel : JSONModel
@property (strong, nonatomic) CartProductModel * product;
@property (strong, nonatomic) NSNumber *cartItemId;
@property (strong, nonatomic) NSNumber<Optional> *isChecked;
@property (strong, nonatomic) NSNumber *quantity;
@property (strong, nonatomic) NSNumber *cartId;
@property (strong, nonatomic) NSNumber<Optional> *isAvailable;
@property (strong, nonatomic) NSString<Optional> * thumbnail;
//在App中自行判断是否选中
@property (strong, nonatomic) NSNumber<Optional> * customIsChecked;

/**
 *  3.1.0  有预售时候 会有描述
 */
@property (nonatomic,strong) NSString<Optional> * memo;
@property (nonatomic,strong) NSString<Optional> * preSaleDesc;

@end


/**
 *   
 "product": {
 "goodsId": 1584,
 "sn": "1682_2",
 "marketPrice": 766,
 "kaolaKey": null,
 "image": "http://www.ssrj.com/upload/image/201605/396fba55-9923-45e5-b32d-e922d40e3f7e-source.png",
 "brandName": "Boy London",
 "brandId": 120,
 "cost": 360,
 "allocatedStock": 0,
 "price": 696,
 "stock": 2,
 "productid": 4443,
 "isDefault": false,
 "name": "黑色BOY REPEAT短裙",
 "specification": "S"
 },
 "cartItemId": 8594,
 "isChecked": true,
 "quantity": 1,
 "cartId": 2924
 */

@interface CartProductModel : JSONModel
@property (strong, nonatomic) NSNumber * goodsId;
@property (strong, nonatomic) NSString<Optional>* sn;
@property (strong, nonatomic) NSNumber<Optional>* marketPrice;
@property (strong, nonatomic) NSString<Optional>* kaolaKey;
@property (strong, nonatomic) NSString<Optional>* image;
@property (strong, nonatomic) NSString<Optional>* brandName;
@property (strong, nonatomic) NSNumber<Optional>* brandId;
@property (strong, nonatomic) NSNumber<Optional>* cost;
@property (strong, nonatomic) NSNumber<Optional>* price;
@property (strong, nonatomic) NSNumber<Optional>* productid;
@property (strong, nonatomic) NSNumber<Optional>* isDefault;
@property (strong, nonatomic) NSString<Optional>* name;
@property (strong, nonatomic) NSString<Optional>* specification;
@property (strong, nonatomic) NSString<Optional> * colorPicture;

//新增字段
//库存紧张
@property (strong, nonatomic) NSNumber<Optional> * isStockAlert;
//是否售罄
@property (strong, nonatomic) NSNumber<Optional> * isOutOfStock;
/**
 *  新增真实售价
 */
@property (strong, nonatomic) NSNumber<Optional>* effectivePrice;



//现货总库存
@property (strong, nonatomic) NSNumber<Optional>* stock;
//冻结的现货库存
@property (strong, nonatomic) NSNumber<Optional>* allocatedStock;

/**
 *  3.1.0 新增预售功能 新增字段  需求改了 暂时用不到
 */

//是否预售
@property (nonatomic,strong) NSNumber<Optional> * isPreSale;
//冻结库存（现售）
@property (nonatomic,strong) NSNumber<Optional> * availableStock;
//是否可用（现售）
@property (nonatomic,strong) NSNumber<Optional> * isAvailable;
//预售总库存
@property (nonatomic,strong) NSNumber<Optional> * preStock;
//冻结预售库存
@property (nonatomic,strong) NSNumber<Optional> * allocatedPreStock;
//可用预售库存
@property (nonatomic,strong) NSNumber<Optional> * availablePreStock;
//预售是否可用
@property (nonatomic,strong) NSNumber<Optional> * isAvailablePreStock;

@end