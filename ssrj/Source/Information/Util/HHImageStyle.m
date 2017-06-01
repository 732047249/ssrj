//
//  HHImageStyle.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHImageStyle.h"

@implementation HHImageStyle


+ (instancetype)imageStyleWithType:(HHImageStyleType)type {
    
    HHImageStyle *imageStyle = [[self alloc] init];
    switch (type) {
        case HHImageStyleTypeLine:
             imageStyle.type = HHImageStyleTypeLine;
            break;
        case HHImageStyleTypeGoods:
            imageStyle.type = HHImageStyleTypeGoods;
            break;
        case HHImageStyleTypeMatch:
            imageStyle.type = HHImageStyleTypeMatch;
            break;
        case HHImageStyleTypeLibrary:
            imageStyle.type = HHImageStyleTypeLibrary;
    }
    return imageStyle;
}
- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeInt:_ID forKey:@"ID"];
    [aCoder encodeCGSize:_size forKey:@"size"];
    [aCoder encodeObject:_url forKey:@"url"];
    [aCoder encodeObject:_fileUrl forKey:@"fileUrl"];
    [aCoder encodeObject:_image forKey:@"image"];
    [aCoder encodeInteger:_type forKey:@"type"];
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _ID = [aDecoder decodeIntForKey:@"ID"];
        _size = [aDecoder decodeCGSizeForKey:@"size"];
        _url = [aDecoder decodeObjectForKey:@"url"];
        _fileUrl = [aDecoder decodeObjectForKey:@"fileUrl"];
        _image = [aDecoder decodeObjectForKey:@"image"];
        _type = [aDecoder decodeIntegerForKey:@"type"];
    }
    return self;
}
@end
