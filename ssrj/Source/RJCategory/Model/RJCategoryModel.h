//
//  RJCategoryModel.h
//  ssrj
//
//  Created by CC on 16/6/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol RJCategoryItemModel;

@interface RJCategoryModel : JSONModel
@property (strong, nonatomic) NSArray<RJCategoryItemModel,Optional> * data;
@property (strong, nonatomic) NSString<Optional> *token;
@property (strong, nonatomic) NSNumber *state;
@property (strong, nonatomic) NSString *msg;
@end


@protocol RJCategoryItemModel <NSObject>

@end
@interface RJCategoryItemModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * nameen;
@property (strong, nonatomic) NSNumber * itemId;
@property (strong, nonatomic) NSString<Optional> * icon;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSString * categoryImg1;
@end