
#import "RJCategoryModel.h"

@interface RJCategoryModel ()
@end

@implementation RJCategoryModel

@end



@implementation RJCategoryItemModel

+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"itemId"
                                                      }];
}

@end