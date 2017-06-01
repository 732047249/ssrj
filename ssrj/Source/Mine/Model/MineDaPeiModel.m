//
//  MineFavoriteGoodsModel.m
//  ssrj
//
//  Created by YiDarren on 16/8/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MineDaPeiModel.h"

@implementation MineDaPeiModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"mineDaPeiModelId"}];
}
@end


@implementation collocationListModel
+ (JSONKeyMapper *)keyMapper{
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"collocationId"}];
}
@end
