//
//  RJFilterColorModel.h
//  ssrj
//
//  Created by CC on 16/7/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJFilterColorModel : JSONModel
@property (strong, nonatomic) NSString * content;
@property (strong, nonatomic) NSString * icon;
@property (strong, nonatomic) NSString * pro;
@property (strong, nonatomic) NSString<Optional> * geared;
@end



@protocol RJFilterColorModel <NSObject>

@end