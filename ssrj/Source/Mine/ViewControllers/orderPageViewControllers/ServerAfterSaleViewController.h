//
//  ServerAfterSaleViewController.h
//  ssrj
//
//  Created by YiDarren on 16/6/28.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
#import "RJAddressModel.h"

@protocol ServerAfterSaleViewControllerDelegate <NSObject>
//刷新订单详情
- (void)reloadPayOrderDetailData;

@end


@interface ServerAfterSaleViewController : RJBasicViewController

@property (strong, nonatomic) NSString *orderSn;
@property (strong, nonatomic) NSNumber *singleOrderId;//暂不用
@property (strong, nonatomic) NSNumber *productid;
@property (strong, nonatomic) NSNumber *orderItemId;

//要退换货的数量
@property (strong, nonatomic) NSNumber *toReturnQuantity;
@property (strong, nonatomic) RJAddressModel *addressModel;

@property (strong, nonatomic) id<ServerAfterSaleViewControllerDelegate>serverDelegate;


@end





@interface GoodsInSizeModel : JSONModel

@property (strong, nonatomic) NSNumber<Optional> *productId;
@property (strong, nonatomic) NSString<Optional> *specification;

@end