//
//  SSMyClientModel.h
//  ssrj
//  我的微店－客户模型
//  Created by mac on 17/2/16.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@class ClientOrderInfoModel;

@interface SSMyClientModel : JSONModel

@property (strong, nonatomic) NSNumber <Optional>*id;//用户ID
@property (strong, nonatomic) NSString <Optional>*avatar;//头像URL
@property (strong, nonatomic) NSString <Optional>*memberName;//用户的名字
@property (strong, nonatomic) NSString <Optional>*totalIntegral;//总积分
@property (strong, nonatomic) NSNumber <Optional>*ordersQuantity;//订单数量

@property (strong, nonatomic) ClientOrderInfoModel *orderInfor;//订单模型
@property (strong, nonatomic) NSMutableArray <Optional>*orderInforArray;//订单列表

//test display-All
@property (strong, nonatomic) NSNumber <Optional>*isAllDisplay;

@end





@interface ClientOrderInfoModel : JSONModel

@property (strong, nonatomic) NSString <Optional>*create_date;//订单创建时间
@property (strong, nonatomic) NSNumber <Optional>*money;//订单金额
@property (strong, nonatomic) NSNumber <Optional>*integral;//总积分

@end