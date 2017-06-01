//
//  SMMatchCutoutModel.m
//  ssrj
//
//  Created by MFD on 16/11/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchCutoutModel.h"

@implementation SMMatchCutoutModel
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"ID"
                                                       }];
}
@end
