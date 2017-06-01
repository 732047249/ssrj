//
//  RJFilterBrandModel.h
//  ssrj
//
//  Created by CC on 16/7/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol RJFilterBrandModel <NSObject>

@end

@interface RJFilterBrandModel : JSONModel
@property (strong, nonatomic) NSString * content;
@property (strong, nonatomic) NSString * s_content;
@property (strong, nonatomic) NSString * pro;
@property (strong, nonatomic) NSString<Optional> * geared;
@end

