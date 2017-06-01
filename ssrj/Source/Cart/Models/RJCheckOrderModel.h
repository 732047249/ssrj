//
//  RJCheckOrderModel.h
//  ssrj
//
//  Created by CC on 16/6/17.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJAddressModel.h"
#import "CartItemModel.h"
#import "RJCouPonModel.h"
@protocol RJKuaiDiModel <NSObject>

@end
@protocol RJPayMethodModel <NSObject>

@end
@interface RJCheckOrderModel : JSONModel

@property (strong, nonatomic) NSNumber * amount;
@property (strong, nonatomic) NSNumber * balance;
@property (strong, nonatomic) RJAddressModel<Optional> * address;
@property (strong, nonatomic) NSArray<CartItemModel> * itemList;
@property (strong, nonatomic) NSString * cartToken;
@property (strong, nonatomic) NSString * cartItemIds;
@property (strong, nonatomic) NSArray<RJKuaiDiModel> *shippingMethodData;
@property (strong, nonatomic) NSArray<RJPayMethodModel> *paymentPluginData;

/**
 *  新增香港地址邮费
 */
@property (strong, nonatomic) NSNumber<Optional> * isHongkong;
//运费
@property (strong, nonatomic) NSNumber<Optional> * freight;
//运费描述
@property (strong, nonatomic) NSString<Optional> * freightDesc;


/**
 *  3.3.0 新增积分抵现
 */
@property (nonatomic,strong) NSNumber<Optional> * exchangePointAmount;

/**
 *  3.1.0 进入界面后台默认返回一张金额最低的优惠券
 */
@property (nonatomic,strong) RJCouPonModel<Optional> * couponCode;


@end



@interface RJKuaiDiModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * icon;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSNumber * isAvailable;


@end


@interface RJPayMethodModel : JSONModel
@property (strong, nonatomic) NSString * paymentPluginValue;
@property (strong, nonatomic) NSString * paymentPluginName;

@end
