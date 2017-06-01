//
//  HHImageStyle.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HHImageStyleType) {
    HHImageStyleTypeLine = 1,
    HHImageStyleTypeMatch,
    HHImageStyleTypeGoods,
    HHImageStyleTypeLibrary
};

@interface HHImageStyle : NSObject<NSCoding>

@property (nonatomic, assign) int ID;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSURL * fileUrl;
@property (nonatomic, assign) HHImageStyleType type;

+ (instancetype)imageStyleWithType:(HHImageStyleType)type;
@end
