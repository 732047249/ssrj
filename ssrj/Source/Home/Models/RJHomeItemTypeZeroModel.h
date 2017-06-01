//
//  RJHomeItemTypeZeroModel.h
//  ssrj
//
//  Created by CC on 16/6/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RJBaseGoodModel.h"
@interface RJHomeItemTypeZeroModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * path;
@property (strong, nonatomic) NSString<Optional> * paramValue1;
@property (strong, nonatomic) NSString<Optional> * paramValue2;
@property (strong, nonatomic) NSArray<RJBaseGoodModel> * goodsList;
@end


