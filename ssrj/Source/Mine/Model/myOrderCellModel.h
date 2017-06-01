//
//  myOrderCellModel.h
//  ssrj
//
//  Created by YiDarren on 16/5/23.
//  Copyright © 2016年 ssrj. All rights reserved.


#import "JSONModel.h"

@class RJAddressModel;

#pragma mark --OrderItemListModel.h
@protocol OrderItemListModel <NSObject>

@end

@interface OrderItemListModel : JSONModel

@property (strong, nonatomic) NSNumber<Optional> *itemId;
//@property (strong, nonatomic) NSNumber<Optional> *applyQuantity;
//@property (strong, nonatomic) NSNumber<Optional> *returnedQuantity;
//@property (strong, nonatomic) NSString<Optional> *sn;
@property (strong, nonatomic) NSString<Optional> *thumbnail;
//@property (strong, nonatomic) NSNumber<Optional> *price;
//@property (strong, nonatomic) NSString<Optional> *name;
//@property (strong, nonatomic) NSString<Optional> *barcode;
//@property (strong, nonatomic) NSNumber<Optional> *shippedQuantity;
//@property (strong, nonatomic) NSNumber<Optional> *quantity;
//@property (strong, nonatomic) NSNumber<Optional> *salePrice;
//@property (strong, nonatomic) NSString<Optional> *originPrice;

@end

@interface memberModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> *memberId;
@property (strong, nonatomic) NSNumber<Optional> *balance;
@property (strong, nonatomic) NSString<Optional> *username;
@property (strong, nonatomic) NSString<Optional> *email;
@property (strong, nonatomic) NSString<Optional> *wxnickname;
@property (strong, nonatomic) NSString<Optional> *userId;
@property (strong, nonatomic) NSNumber<Optional> *wxopenId;
@property (strong, nonatomic) NSNumber<Optional> *isEnabled;
@property (strong, nonatomic) NSNumber<Optional> *isLocked;
@property (strong, nonatomic) NSString<Optional> *mobile;
@end

@protocol  myOrderCellModel<NSObject>

@end
@interface myOrderCellModel : JSONModel

@property (strong, nonatomic) NSString<Optional> *shippingSn;
@property (strong, nonatomic) NSString<Optional> *trackingNo;
//@property (strong, nonatomic) NSString<Optional> *memo;
//@property (strong, nonatomic) NSString<Optional> *paymentMethodName;
//@property (strong, nonatomic) NSString<Optional> *paymentMethodType;
@property (strong, nonatomic) NSNumber<Optional> *hasExpired;
@property (strong, nonatomic) NSNumber<Optional> *amount;
@property (strong, nonatomic) NSNumber<Optional> *myOrderCellModelId;
//@property (strong, nonatomic) NSNumber<Optional> *refundAmount;
//@property (strong, nonatomic) NSString<Optional> *zipCode;
@property (strong, nonatomic) NSNumber<Optional> *quantity;
//
//@property (strong, nonatomic) memberModel<Optional> *member;
//@property (strong, nonatomic) NSNumber<Optional> *isAllocatedStock;
@property (strong, nonatomic) NSString<Optional> *expire;
@property (strong, nonatomic) NSString<Optional> *sn;
//@property (strong, nonatomic) NSNumber<Optional> *returnedQuantity;
@property (strong, nonatomic) NSString<Optional> *status;

//add 11.22
@property (strong, nonatomic) NSString<Optional> *statusValue;//退换货单状态，售后专用
@property (strong, nonatomic) NSString<Optional> *returnsStatus;//退换货单状态描述，中文，售后专用
@property (strong, nonatomic) NSString<Optional> *orderStatus;//订单状态，售后专用
@property (strong, nonatomic) NSString<Optional> *returnsStatusValue;//售后状态，售后专用


//@property (strong, nonatomic) NSNumber<Optional> *shippedQuantity;
//@property (strong, nonatomic) NSNumber<Optional> *couponDiscount;
//@property (strong, nonatomic) NSNumber<Optional> *promotionDiscount;
//@property (strong, nonatomic) NSNumber<Optional> *price;
@property (strong, nonatomic) RJAddressModel<Optional> *address;
@property (strong, nonatomic) NSNumber<Optional> *orders;//售后订单ID
@property (strong, nonatomic) NSString<Optional> *orderDate;//订单下单时间，精确到天
@property (strong, nonatomic) NSString<Optional> *orderTime;//订单下单时间，精确到小时


////存放cell内的collection Cell
@property (strong, nonatomic) NSArray<OrderItemListModel,Optional> *orderItemList;
//
//@property (strong, nonatomic) NSNumber<Optional> *amountPaid;
//@property (strong, nonatomic) NSString<Optional> *shippingMethodName;
//@property (strong, nonatomic) NSNumber<Optional> *kaolaOrderId;
//@property (strong, nonatomic) NSString<Optional> *isUseCouponCode;

//订单类型，普通订单general、积分兑换订单exchange、退换货订单swap  add 11.24
@property (strong, nonatomic) NSString<Optional> *type;
@property (strong, nonatomic) NSString<Optional> *returnsTypeValue;//退货单类型


@end


@interface MFDMineOrderModel : JSONModel
@property (nonatomic,strong)NSString<Optional> *token;
@property (nonatomic,strong)NSArray<Optional,myOrderCellModel> *data;
@property (nonatomic,strong)NSString<Optional> *msg;
@property (nonatomic,strong)NSNumber<Optional> *state;
@end