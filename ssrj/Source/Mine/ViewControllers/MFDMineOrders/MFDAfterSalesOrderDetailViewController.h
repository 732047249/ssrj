//
//  MFDAfterSalesOrderDetailViewController.h
//  ssrj
//
//  Created by YiDarren on 16/12/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@interface MFDAfterSalesOrderDetailViewController : RJBasicViewController
//退换货ID
@property (strong,nonatomic) NSNumber *afterSalesId;
//用来区别申请服务类别（换货｜退货）
@property (strong, nonatomic) NSString *applyType;


@end




@interface AfterSalesOrderModel : JSONModel

//申请服务server;
@property (strong, nonatomic) NSString <Optional> *server;

//更换尺码size;
@property (strong, nonatomic) NSString <Optional> *size;

//申请原因reason;
@property (strong, nonatomic) NSString <Optional> *reason;

//上门取货时间time;
@property (strong, nonatomic) NSString <Optional> *time;

//订单状态status;
@property (strong, nonatomic) NSString <Optional> *status;


//====上门取货收货地址
//姓名 userDoorName;
@property (strong, nonatomic) NSString <Optional> *userDoorName;

//电话 userDoorPhone;
@property (strong, nonatomic) NSString <Optional> *userDoorPhone;

//取货地址 userDoorDestination;
@property (strong, nonatomic) NSString <Optional> *userDoorDestination;

//====换货商品取货地址
//姓名 userName;
@property (strong, nonatomic) NSString <Optional> *userName;

//电话 userPhone;
@property (strong, nonatomic) NSString <Optional> *userPhone;

//取货地址 userDestination;
@property (strong, nonatomic) NSString <Optional> *userDestination;

//====商品信息
//图片goodsImage;
@property (strong, nonatomic) NSString <Optional> *goodsImage;

//名称goodsName;
@property (strong, nonatomic) NSString <Optional> *goodsName;

//英文名goodsNickName;
@property (strong, nonatomic) NSString <Optional> *brandName;

//尺码goodsSize;
@property (strong, nonatomic) NSString <Optional> *goodsSize;

//颜色图片goodsColorImage;
@property (strong, nonatomic) NSString <Optional> *goodsColorImage;

//当前价格currentPrice;
@property (strong, nonatomic) NSString <Optional> *currentPrice;

//之前价格prePrice;
@property (strong, nonatomic) NSString <Optional> *prePrice;


@end