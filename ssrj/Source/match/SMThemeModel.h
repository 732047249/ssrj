//
//  SMThemeModel.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
// 已有合辑

#import <JSONModel/JSONModel.h>

@interface SMThemeModel : JSONModel
@property (nonatomic,strong)NSString *ID;
@property (nonatomic,assign)BOOL is_publish;
@property (nonatomic,strong)NSString<Optional>*title;
@property (nonatomic,strong)NSString<Optional> *desp;


@property (nonatomic,strong)NSString<Optional> *praise_count;
@property (nonatomic,strong)NSString<Optional> *comment_count;
@property (nonatomic,strong)NSString<Optional> *is_open;
@property (nonatomic,strong)NSString<Optional> *favored;
@property (nonatomic,strong)NSString<Optional> *image;
@property (nonatomic,strong)NSString<Optional> *favor_count;
@property (nonatomic,strong)NSString<Optional> *owner;
@end
