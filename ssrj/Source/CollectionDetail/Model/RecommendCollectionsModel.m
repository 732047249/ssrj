//
//  RecommendCollectionsModel.m
//  ssrj
//
//  Created by MFD on 16/6/17.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RecommendCollectionsModel.h"

//@implementation AvatarModel
//
//@end

@implementation CommentListModel

@end


@implementation CommentModel

@end


@implementation MemberData
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"memberId"}];
}

@end

@implementation ThemeItemListModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"themeItemId"}];
}

@end


@implementation NowCollocationModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"nowCollectionId"}];
}
@end

@implementation SingleProductModel

@end

@implementation CollocationsItem
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"collocationId"}];
}

@end


@implementation CollectionsDataModel

@end


@implementation RecommendCollectionsModel

@end