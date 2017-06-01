//
//  SMBrandsModel.m
//  ssrj
//
//  Created by MFD on 16/11/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMBrandsModel.h"

@implementation SMBrandsModel
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"ID"
                                                       }];
}
@end
