//
//  RJAddressModel.h
//  ssrj
//
//  Created by CC on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJAddressModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> * id;
@property (strong, nonatomic) NSString * phone;
@property (strong, nonatomic) NSString * areaName;
@property (strong, nonatomic) NSNumber<Optional> * isDefault;
@property (strong, nonatomic) NSString * address;
@property (strong, nonatomic) NSString * consignee;
@property (strong, nonatomic) NSString<Optional> * zipCode;
@property (strong, nonatomic) NSString * fullName;
@property (strong, nonatomic) NSNumber * areaId;
@end
