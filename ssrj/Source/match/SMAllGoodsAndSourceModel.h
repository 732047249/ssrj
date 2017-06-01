//
//  SMAllGoodsAndSourceModel.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/15.
//  Copyright © 2016年 ssrj. All rights reserved.
// 底部导航控制器的：所有单品和素材

#import <JSONModel/JSONModel.h>

@interface SMAllGoodsAndSourceModel : JSONModel
@property (nonatomic,strong)NSString *title;
@property (nonatomic,strong)NSString *label;
@property (nonatomic,strong)NSString *group_name;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong)NSString *ID;
@property (nonatomic,strong)NSString *icon;
@end
