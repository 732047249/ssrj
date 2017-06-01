//
//  RJGoodDetailModel.h
//  ssrj
//
//  Created by CC on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol RJGoodDetailColorGoodModel;
@protocol RJGoodDetailRelationGoodsModel;
@protocol RJGoodDetailProductImagesModel;
@protocol RJGoodDetailProductsModel;
@protocol RJGoodDetailRelationCollocationModel;



@interface RJGoodDetailModel : JSONModel
@property (strong, nonatomic)NSArray<RJGoodDetailProductImagesModel,Optional> *productImages;
@property (strong, nonatomic)NSString<Optional> * colorName;
@property (strong, nonatomic)NSString<Optional> * weight;
@property (strong, nonatomic)NSString<Optional> * memo;
@property (strong, nonatomic)NSNumber<Optional> * isNonSell;
@property (strong, nonatomic)NSNumber<Optional> *colorId;
@property (strong, nonatomic)NSString<Optional>* kaolaKey;
@property (strong, nonatomic)NSNumber<Optional> *brandId;
@property (strong, nonatomic)NSString<Optional> *colorPicture;
@property (strong, nonatomic)NSString<Optional> *brandName;
@property (strong, nonatomic)NSNumber *dataId;
@property (strong, nonatomic)NSString<Optional> *cloth;
@property (strong, nonatomic)NSString<Optional> *maxImage;
@property (strong, nonatomic)NSString<Optional> *mediumImage;
@property (strong, nonatomic)NSString<Optional> *name;
@property (strong, nonatomic)NSString<Optional> *path;
@property (strong, nonatomic)NSString<Optional> *productCategoryName;
@property (strong, nonatomic)NSString<Optional> *sizePath;
@property (strong, nonatomic)NSArray<RJGoodDetailProductsModel,Optional> *products;
@property (strong, nonatomic)NSString<Optional> *productRelationId;
@property (strong, nonatomic)NSString<Optional> *brandLogo;
@property (strong, nonatomic)NSArray<Optional> *tags;
@property (strong, nonatomic)NSString<Optional> *sn;
@property (strong, nonatomic)NSNumber<Optional> *marketPrice;
@property (strong, nonatomic)NSArray<RJGoodDetailRelationGoodsModel,Optional> *relationGoods;
@property (strong, nonatomic)NSNumber<Optional> *effectiveDiscount;
@property (strong, nonatomic)NSString<Optional> *footageImage;
@property (strong, nonatomic)NSNumber<Optional> *effectiveDiscountPrice;
@property (strong, nonatomic)NSString<Optional> *largeImage;
@property (strong, nonatomic)NSNumber<Optional> * isMarketable;
@property (strong, nonatomic)NSString<Optional> *image;
@property (strong, nonatomic)NSNumber<Optional> *discountPrice;
@property (strong, nonatomic)NSString<Optional> *caption;
@property (strong, nonatomic)NSNumber<Optional> *commentCount;
@property (strong, nonatomic)NSArray<RJGoodDetailRelationCollocationModel,Optional> *collocations;
@property (strong, nonatomic)NSNumber<Optional> *discount;
@property (strong, nonatomic)NSString<Optional> *downTime;
@property (strong, nonatomic)NSNumber<Optional> *effectivePrice;
@property (strong, nonatomic)NSString<Optional> *unit;
@property (strong, nonatomic)NSNumber<Optional> *thumbsupCount;
@property (strong, nonatomic)NSString<Optional> *thumbnail;
@property (strong, nonatomic)NSNumber<Optional> *price;
@property (strong, nonatomic)NSNumber<Optional> *favoriteCount;
@property (strong, nonatomic)NSString<Optional> *upTime;
@property (strong, nonatomic)NSArray<RJGoodDetailRelationGoodsModel,Optional> *recommendGoods;
@property (strong, nonatomic)NSArray<RJGoodDetailColorGoodModel,Optional> *colorGoods;
@property (strong, nonatomic)NSNumber<Optional> *isSpecialPrice;
@property (strong, nonatomic)NSNumber<Optional> *isNewProduct;
@property (strong, nonatomic)NSNumber<Optional> *productCategoryId;
@property (strong, nonatomic)NSString<Optional> *brandAppImage2;
@property (strong, nonatomic)NSNumber<Optional> *isThumbsup;
@property (strong, nonatomic)NSString<Optional> *defaultRecommend;

/**
 *  手机分享link
 */
@property (strong, nonatomic) NSString<Optional> * mobilePath;
/**
 *  分享出去的商品介绍
 */
@property (strong, nonatomic) NSString<Optional> * productDesc;


/**
 *  新增是否是预售字段
 */
@property (nonatomic,strong) NSNumber<Optional> * isPreSale;
@end


@protocol  RJGoodDetailColorGoodModel<NSObject>
@end
@interface RJGoodDetailColorGoodModel : JSONModel
@property (strong, nonatomic) NSNumber* goodsId;
@property (strong, nonatomic) NSString<Optional>* colorName;
@property (strong, nonatomic) NSString<Optional>* sn;
@property (strong, nonatomic) NSString<Optional>* colorTitle;
@property (strong, nonatomic) NSNumber<Optional>* colorId;
@property (strong, nonatomic) NSString<Optional>* name;
@property (strong, nonatomic) NSString<Optional>* colorValue;
@property (strong, nonatomic) NSString<Optional>* colorPicture;
@end




/**
 *  这个单品下面推荐的单品
 */
@protocol RJGoodDetailRelationGoodsModel <NSObject>

@end

@interface RJGoodDetailRelationGoodsModel : JSONModel
@property (strong,nonatomic)NSNumber* relationGoodsId;
@property (strong,nonatomic)NSNumber<Optional>* marketPrice;
@property (strong,nonatomic)NSString<Optional>* thumbnail;
@property (strong,nonatomic)NSString<Optional>* maxImage;
@property (strong,nonatomic)NSNumber<Optional>* price;
@property (strong,nonatomic)NSString<Optional>* name;
@property (strong,nonatomic)NSString<Optional>* path;
@property (strong,nonatomic)NSString<Optional>* mobilePath;
@property (strong,nonatomic)NSNumber<Optional>* cost;
@property (strong,nonatomic)NSString<Optional>* brandName;

@property (strong, nonatomic) NSNumber<Optional> * isSpecialPrice;
@property (strong, nonatomic) NSNumber<Optional> * isNewProduct;

@end


//商品详情图片
@protocol  RJGoodDetailProductImagesModel <NSObject>

@end
@interface RJGoodDetailProductImagesModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * title;
@property (strong, nonatomic) NSString<Optional> * thumbnail;
@property (strong, nonatomic) NSString<Optional> * max;
@property (strong, nonatomic) NSString<Optional> * order;
@property (strong, nonatomic) NSString<Optional> * source;
@property (strong, nonatomic) NSString<Optional> * medium;
@property (strong, nonatomic) NSString<Optional> * large;
@property (strong, nonatomic) NSString<Optional> * videoPath;
@end

/**
 *  加入购物车和立即购买界面用的模型
 */
@protocol RJGoodDetailProductsModel <NSObject>

@end
@interface RJGoodDetailProductsModel : JSONModel
@property (strong,nonatomic)NSNumber<Optional>* exchangePoint;
@property (strong,nonatomic)NSString<Optional>* sn;
@property (strong,nonatomic)NSNumber<Optional>* marketPrice;
@property (strong,nonatomic)NSNumber<Optional>* rewardPoint;
@property (strong,nonatomic)NSString<Optional>* kaolaKey;
@property (strong,nonatomic)NSNumber<Optional>* cost;


@property (strong,nonatomic)NSNumber<Optional>* productsId;


@property (strong,nonatomic)NSNumber<Optional>* price;


@property (strong,nonatomic)NSNumber<Optional>* isDefault;
@property (strong,nonatomic)NSString<Optional>* name;
@property (strong,nonatomic)NSString<Optional>* specification;
@property (strong,nonatomic)NSString<Optional>* sizeRecommend;

//现货总库存
@property (strong,nonatomic)NSNumber<Optional>* stock;
//冻结的现货库存 用不到
@property (strong,nonatomic)NSNumber<Optional>* allocatedStock;
//现售是否可用
@property (strong,nonatomic)NSNumber<Optional>* isAvailable;
/**
 *  3.1.0 新增预售字段
 */
//预售总库存
@property (nonatomic,strong) NSNumber<Optional> *preStock;
//是否支持预售
@property (nonatomic,strong) NSNumber<Optional> *isPreSale;
//冻结预售库存  已经卖出去的预售商品个数 用不到
@property (nonatomic,strong) NSNumber<Optional> *allocatedPreStock;
//预售发货时间说明
@property (strong,nonatomic) NSString<Optional>* preSaleDesc;
//可用的预售库存
@property (nonatomic,strong) NSNumber<Optional>* availablePreStock;
//预售是否可用
@property (nonatomic,strong) NSNumber<Optional>* isAvailablePreStock;
//现货可用库存
@property (nonatomic,strong) NSNumber<Optional>* availableStock;
@end

/**
 *  单品详情下方关联的搭配推荐Model
 */

@protocol  RJGoodDetailRelationCollocationModel<NSObject>

@end
@interface RJGoodDetailRelationCollocationModel : JSONModel
@property (strong, nonatomic) NSString<Optional>* picture;
@property (strong, nonatomic) NSNumber* collocationId;
@property (strong, nonatomic) NSNumber<Optional>* thumbsupCount;
@property (strong, nonatomic) NSNumber<Optional>* favoriteCount;
@property (strong, nonatomic) NSString<Optional>* name;
@property (strong, nonatomic) NSString<Optional>* path;
@property (strong, nonatomic) NSString<Optional>* mobilePath;
@property (strong, nonatomic) NSNumber<Optional>* commentCount;
@property (strong, nonatomic) NSString<Optional>* autherName;
@property (strong, nonatomic) NSString<Optional>* avatar;
@property (strong, nonatomic) NSNumber<Optional>* isThumbsup;
@property (strong, nonatomic) NSNumber<Optional> *memberId;
@end
