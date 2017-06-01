//
//  CouponModel.h
//  ssrj
//
//  Created by YiDarren on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CouponModel : JSONModel
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString<Optional> * code;
@property (strong, nonatomic) NSNumber<Optional> * isUsed;
@property (strong, nonatomic) NSNumber<Optional> * member;
@property (strong, nonatomic) NSString<Optional> * beginDate;
@property (strong, nonatomic) NSString<Optional> * endDate;
@property (strong, nonatomic) NSNumber<Optional> * price;
@property (strong, nonatomic) NSNumber<Optional> * minimumPrice;
@property (strong, nonatomic) NSString<Optional> * useRule;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSString<Optional> * remark;

@end
