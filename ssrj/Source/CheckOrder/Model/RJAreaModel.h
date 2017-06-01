//
//  RJAreaModel.h
//  ssrj
//
//  Created by CC on 16/6/15.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol RJAreaModel <NSObject>
@end
@interface RJAreaModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Ignore> * areaName;
@property (strong, nonatomic) NSString * addRess;
@property (strong, nonatomic) NSNumber * pid;
@property (strong, nonatomic) NSString<Ignore> * treePath;
@property (strong, nonatomic) NSArray<RJAreaModel,Optional> *child;

@end
