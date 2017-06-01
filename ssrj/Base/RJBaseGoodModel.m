
#import "RJBaseGoodModel.h"

@interface RJBaseGoodModel ()
@end

@implementation RJBaseGoodModel

+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"goodId"
                                                      }];
    
}
@end



@implementation RJGoodListImageListModel



@end