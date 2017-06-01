//
//  ColorSelfDefinedModel.m
//  ssrj
//
//  Created by YiDarren on 16/10/31.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SelfDefinedModel.h"
@implementation SelfDefinedModel

@end


@implementation ColorModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"colorId"}];
}
@end


@implementation SceneModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"sceneId"}];
}

@end


@implementation BackgroundModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"id":@"backgroundId"}];
}


@end

@implementation SMBackgroundDraftModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
@implementation SMBackgroundSize
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}
@end
