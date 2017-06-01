//
//  RJHomeHotGoodModel.h
//  ssrj
//
//  Created by CC on 16/12/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
/**
 *  2.2.0 新增的热卖单品展示 虽然后台返回的模型和  RJHomeItemTypeZeroModel 一致
    谨慎之举还是在建立一个新模型方便扩展
 */
#import "RJBaseGoodModel.h"
@interface RJHomeHotGoodModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * path;
@property (strong, nonatomic) NSString<Optional> * paramValue1;
@property (strong, nonatomic) NSString<Optional> * paramValue2;
@property (strong, nonatomic) NSArray<RJBaseGoodModel> * goodsList;
@property (nonatomic,strong)  NSNumber<Optional> *isThumbsup;
@end
