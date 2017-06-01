//
//  SearchForCreateMatchViewController.h
//  ssrj
//
//  Created by YiDarren on 16/11/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
//搜索时下拉列表呈现的合辑推荐列表model
#import "ThemeLabelForSearchModel.h"


@protocol SearchForCreateMatchViewControllerDelegate <NSObject>
//刷新标签数据
- (void)reloadLabelDataWithModel:(ThemeLabelForSearchModel *)model;

@end



@interface SearchForCreateMatchViewController : RJBasicViewController

@property (strong, nonatomic) NSNumber *collectionID;

@property (strong, nonatomic) id<SearchForCreateMatchViewControllerDelegate>createLabelDelegate;

//用于ugc上传搭配和创建搭配
@property (nonatomic, assign) BOOL isFromCreateCollection;
@end
