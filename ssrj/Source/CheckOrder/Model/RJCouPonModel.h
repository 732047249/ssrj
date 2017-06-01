//
//  RJCouPonModel.h
//  ssrj
//
//  Created by CC on 16/6/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJCouPonModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * expire;
@property (strong, nonatomic) NSNumber * price;
@property (strong, nonatomic) NSString * couponName;
@property (strong, nonatomic) NSNumber * isUsed;
//这是特殊说明 和个人中心里面的model不是同一个
@property (strong, nonatomic) NSString<Optional> * remark;
@property (strong, nonatomic) NSString * minimumPrice;
@property (strong, nonatomic) NSString * minimumPriceMsg;
@property (strong, nonatomic) NSString * code;

@property (nonatomic,strong) NSString<Optional> * introduction;
@end
