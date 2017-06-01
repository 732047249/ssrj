//
//  SearchHotWordsModel.m
//  ssrj
//
//  Created by YiDarren on 16/9/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SearchHotWordsModel.h"

@implementation SearchHotWordsModel

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"goodsId"}];
}

@end
