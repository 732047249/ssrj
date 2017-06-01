//
//  RJFilterCategoryModel.h
//  ssrj
//
//  Created by CC on 16/7/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>


@protocol RJFilterCategoryChildrenModel <NSObject>

@end;

@interface RJFilterCategoryChildrenModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * geared;
@property (strong, nonatomic) NSString * pro;
@property (strong, nonatomic) NSString * content;
@property (strong, nonatomic) NSString * image;
@end

@protocol RJFilterCategoryModel <NSObject>

@end;

@interface RJFilterCategoryModel : JSONModel
@property (strong, nonatomic) NSString * content;
@property (strong, nonatomic) NSString * pro;
@property (strong, nonatomic) NSString * image;
@property (strong, nonatomic) NSString<Optional> * geared;
@property (strong, nonatomic) NSArray<RJFilterCategoryChildrenModel> * children;
//是否打开  app自定义字段
@property (assign, nonatomic) NSNumber<Optional>* isOpen;
@end




