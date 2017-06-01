//
//  HHTextAttachment.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHTextAttachment.h"

@implementation HHTextAttachment

+ (instancetype)attachmentWithImage:(UIImage *)image width:(CGFloat)width {
    HHTextAttachment *textAttachment = [[HHTextAttachment alloc] init];
    CGRect rect = CGRectZero;
    rect.size.width = width;
    rect.size.height = width * image.size.height / image.size.width;
    textAttachment.bounds = rect;
    textAttachment.image = image;
    return textAttachment;
}


- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    [aCoder encodeObject:_imageStyle forKey:@"imageStyle"];
    [aCoder encodeCGRect:self.bounds forKey:@"bounds"];
    [aCoder encodeObject:self.image forKey:@"image"];
    
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _imageStyle = [aDecoder decodeObjectForKey:@"imageStyle"];
        self.bounds = [aDecoder decodeCGRectForKey:@"bounds"];
        self.image = [aDecoder decodeObjectForKey:@"image"];
    }
    return self;
}

@end
