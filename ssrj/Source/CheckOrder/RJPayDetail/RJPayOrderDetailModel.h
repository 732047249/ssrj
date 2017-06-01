//
//  RJPayOrderDetailModel.h
//  ssrj
//
//  Created by CC on 16/6/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RJAddressModel.h"
#import "CartItemModel.h"
@protocol PayOrderDeatailItemModel;

@interface RJPayOrderDetailModel : JSONModel
@property (strong, nonatomic) NSString<Optional> *shippingSn;
@property (strong, nonatomic) NSString<Optional> *trackingNo;
@property (strong, nonatomic) NSString<Optional> *statusStr;
@property (strong, nonatomic) NSString<Optional> *memo;
@property (strong, nonatomic) NSString<Optional> *paymentMethodName;
@property (strong, nonatomic) NSString<Optional> *paymentMethodType;
@property (strong, nonatomic) NSNumber<Optional> *hasExpired;
@property (strong, nonatomic) NSNumber *amount;
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber<Optional> *refundAmount;
@property (strong, nonatomic) NSNumber<Optional> *isAllocatedStock;
@property (strong, nonatomic) NSString<Optional> *expire;
@property (strong, nonatomic) NSString *sn;
@property (strong, nonatomic) NSNumber<Optional> *returnedQuantity;
@property (strong, nonatomic) NSString *status;
@property (strong, nonatomic) NSNumber<Optional> *shippedQuantity;
@property (strong, nonatomic) NSNumber<Optional> *couponDiscount;

/**
 *  3.0.0
 */
@property (strong, nonatomic) NSNumber<Optional> *exchangePoint;
@property (strong, nonatomic) NSNumber<Optional> *exchangePointAmount;


@property (strong, nonatomic) NSNumber<Optional> *promotionDiscount;
@property (strong, nonatomic) NSNumber<Optional> *price;
@property (strong, nonatomic) NSString<Optional> *orderTime;
@property (strong, nonatomic) RJAddressModel *address;
/**
 *  付款方式 alipayDirectPaymentPlugin  wxpayPubPaymentPlugin
 */
@property (strong, nonatomic) NSString<Optional> * paymentType;

@property (strong, nonatomic) NSNumber<Optional> *amountPaid;
@property (strong, nonatomic) NSNumber<Optional> *kaolaOrderId;
@property (strong, nonatomic) NSString<Optional> *shippingMethodName;
@property (strong, nonatomic) NSNumber<Optional> *isUseCouponCode;
@property (strong, nonatomic) NSArray<PayOrderDeatailItemModel> * orderItemList;

/**
 *  应付金额
 */

@property (strong, nonatomic) NSNumber * amountPayable;
//运费
@property (strong, nonatomic) NSNumber<Optional> *freight;



@end


@protocol PayOrderDeatailItemModel <NSObject>



@end
@interface PayOrderDeatailItemModel : JSONModel
@property (strong, nonatomic) CartProductModel * product;
@property (strong, nonatomic) NSString * sn;
@property (strong, nonatomic) NSNumber<Optional> * returnedQuantity;
@property (strong, nonatomic) NSNumber<Optional> * applyQuantity;
@property (strong, nonatomic) NSNumber<Optional> * shippedQuantity;
@property (strong, nonatomic) NSNumber<Optional> * barcode;
@property (strong, nonatomic) NSString<Optional> * originPrice;
@property (strong, nonatomic) NSNumber<Optional> * id;
@property (strong, nonatomic) NSNumber<Optional> * price;
@property (strong, nonatomic) NSString<Optional> * thumbnail;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSNumber<Optional> * salePrice;
@property (strong, nonatomic) NSNumber<Optional> * quantity;

@property (strong, nonatomic) NSNumber<Optional> * effectivePrice;

@property (assign, nonatomic) BOOL canApply;

@property (nonatomic,strong) NSString<Optional> * preSaleDesc;
@end
