//
//  SMMatchDraftModel.m
//  ssrj
//
//  Created by MFD on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDraftModel.h"

@implementation SMMatchDraftModel
+(JSONKeyMapper*)keyMapper
{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"ID"
                                                       }];
}
@end
