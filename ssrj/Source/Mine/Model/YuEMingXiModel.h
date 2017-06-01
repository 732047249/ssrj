//
//  YuEMingXiModel.h
//  ssrj
//
//  Created by YiDarren on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface YuEMingXiModel : JSONModel

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber<Optional> * balance;
@property (strong, nonatomic) NSNumber<Optional> * member;
@property (strong, nonatomic) NSString<Optional> * createPDate;
@property (strong, nonatomic) NSString<Optional> * depositType;
@property (strong, nonatomic) NSNumber<Optional> * ptype;
@property (strong, nonatomic) NSString<Optional> * typeName;
@property (strong, nonatomic) NSString<Optional> * amount;

@end
