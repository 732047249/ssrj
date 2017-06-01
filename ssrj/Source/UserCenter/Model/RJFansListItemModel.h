//
//  RJFansListItemModel.h
//  ssrj
//
//  Created by CC on 16/9/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJFansListItemModel : JSONModel
@property (strong, nonatomic) NSNumber *id;
@property (strong, nonatomic) NSString * username;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSString<Optional> * headimg;
@property (strong, nonatomic) NSNumber<Optional> * isSubscribe;
@property (strong, nonatomic) NSNumber<Optional> * fansCount;
/**
 *  是否是自己
 */
@property (strong, nonatomic) NSNumber<Optional> * isSelf;
/**
 *  1是品牌 2是用户
 */
@property (strong, nonatomic) NSNumber<Optional> * type;

@end
