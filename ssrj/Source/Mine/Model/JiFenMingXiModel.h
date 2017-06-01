//
//  JiFenMingXiModel.h
//  ssrj
//
//  Created by YiDarren on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface JiFenMingXiModel : JSONModel

@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSNumber<Optional> * balance;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSNumber<Optional> * member;
@property (strong, nonatomic) NSString<Optional> * score;
@property (strong, nonatomic) NSString<Optional> * pointType;
@property (strong, nonatomic) NSNumber<Optional> * ptype;
@property (strong, nonatomic) NSString<Optional> * typeName;
@property (strong, nonatomic) NSString<Optional> * createPDate;

@end
