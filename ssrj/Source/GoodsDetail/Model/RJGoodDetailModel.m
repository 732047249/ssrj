
#import "RJGoodDetailModel.h"

@interface RJGoodDetailModel ()
@end

@implementation RJGoodDetailModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"dataId"}];
}

@end




@implementation RJGoodDetailColorGoodModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"goodsId"}];
}
@end


@implementation RJGoodDetailRelationGoodsModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"relationGoodsId"}];
}

@end


@implementation RJGoodDetailProductImagesModel



@end


@implementation RJGoodDetailProductsModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"productsId"}];
}

@end


@implementation RJGoodDetailRelationCollocationModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"id":@"collocationId"}];
}

@end