//
//  RJFilterBigModel.h
//  ssrj
//
//  Created by CC on 16/7/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "RJFilterBrandModel.h"
#import "RJFilterCategoryModel.h"
#import "RJFilterColorModel.h"
#import "RJFilterPriceModel.h"
@interface RJFilterBigModel : JSONModel
@property (strong, nonatomic) NSArray<RJFilterBrandModel> * brands;
@property (strong, nonatomic) NSArray<RJFilterCategoryModel> *category;
@property (strong, nonatomic) NSArray<RJFilterColorModel> * colors;
@property (strong, nonatomic) NSArray<RJFilterPriceModel> *prices;
@end



