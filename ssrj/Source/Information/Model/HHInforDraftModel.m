//
//  HHInforDraftModel.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforDraftModel.h"

@implementation HHInforDraftModel
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:_ID forKey:@"ID"];
    [aCoder encodeObject:_coverImageStyle forKey:@"coverImageStyle"];
    [aCoder encodeObject:_title forKey:@"title"];
    [aCoder encodeObject:_specialTopicId forKey:@"specialTopicId"];
    [aCoder encodeObject:_specialTopicName forKey:@"specialTopicName"];
    [aCoder encodeObject:_attributeString forKey:@"attributeString"];
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _coverImageStyle = [aDecoder decodeObjectForKey:@"coverImageStyle"];
        _title = [aDecoder decodeObjectForKey:@"title"];
        _specialTopicId = [aDecoder decodeObjectForKey:@"specialTopicId"];
        _specialTopicName = [aDecoder decodeObjectForKey:@"specialTopicName"];
        _attributeString = [aDecoder decodeObjectForKey:@"attributeString"];
        _ID = [aDecoder decodeObjectForKey:@"ID"];
    }
    return self;
}
@end
