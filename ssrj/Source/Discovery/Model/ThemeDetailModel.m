//
//  DiscoveryThemeModel.m
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ThemeDetailModel.h"
@implementation memberInfoData
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"memberId"}];
}

@end



@implementation ThemeCollocationList
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"collocationId"}];
}

@end




@implementation fansMemberList
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"fansMemberListId"}];
}

@end



@implementation ThemeData
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"themeCollectionId"}];
}

@end


@implementation ThemeDetailModel

@end
