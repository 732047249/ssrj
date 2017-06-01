//
//  SMThemeModel.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMThemeModel.h"

@implementation SMThemeModel
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"ID",
                                                       @"memo": @"desp"
                                                       }];
}
@end
