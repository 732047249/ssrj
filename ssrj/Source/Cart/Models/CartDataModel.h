//
//  CartDataModel.h
//  ssrj
//
//  Created by CC on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "CartItemModel.h"
@interface CartDataModel : JSONModel
@property (strong, nonatomic) NSNumber * price;
@property (strong, nonatomic) NSNumber * count;
@property (strong, nonatomic) NSArray<CartItemModel> *itemList;
@end
