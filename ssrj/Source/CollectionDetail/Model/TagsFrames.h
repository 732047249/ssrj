//
//  TagsFrames.h
//  ssrj
//
//  Created by MFD on 16/7/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define Tags_Font [UIFont systemFontOfSize:12]

//搭配详情页标签frame模型
@interface TagsFrames : NSObject

//主题名称数组
@property (nonatomic,strong) NSArray *titlesArray;

//标签跳转到主题合辑的id数组
@property (nonatomic,strong) NSArray *themeIdsArray;

@property (nonatomic,strong) NSMutableArray *tagsFrames;

@property (nonatomic,assign) CGFloat tagsHeight;

//标签间距
@property (nonatomic,assign) CGFloat tagsMargin;
//最小内边距
@property (nonatomic,assign) CGFloat tagsLineSpacing;
//标签行间距
@property (nonatomic,assign) CGFloat tagsMinPadding;

@end
