//
//  AddToNewThemeModel.m
//  ssrj
//
//  Created by YiDarren on 16/7/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AddToNewThemeModel.h"
#import "RecommendCollectionsModel.h"

@implementation AvatarModel

@end






@implementation AddToNewThemeModel

+ (JSONKeyMapper *)keyMapper {
    
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"collocationId"}];

}

@end
