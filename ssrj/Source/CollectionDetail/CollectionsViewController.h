//
//  CollectionsViewController.h
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
#import "RJHomeItemTypeFourModel.h"
#import "RJHomeItemTypeTwoModel.h"


typedef void(^zanBackBlock)(NSInteger);
@protocol CollectionsViewControllerDelegate <NSObject>
@optional
//合辑代理方法
- (void)reloadZanMessageNetDataWithBtnstate:(BOOL)btnSelected;
//首页代理方法
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected;
//用户中心发布UI删除搭配代理方法
- (void)reloadUserCenterPublishDataWithDelete;
//用户中心发布UI编辑搭配代理方法
- (void)reloadUserCenterPublishDataWithReWriteDic:(NSDictionary *)dic;
//用户中心发布UI加入合辑代理方法
- (void)reloadUserCenterPublishDataWithCollocationModel:(RJHomeItemTypeTwoModel *)collocationModel;
//为了刷新首页搭配cell点击进入搭配详情后再点击加入合辑按钮，编辑完成后的首页搭配cell数据
- (void)reloadHomeCollocationCellDataWithHomeModel:(RJHomeItemTypeTwoModel *)homeItemModel;

@end

@class RJHomeItemTypeTwoShareModel;
@interface CollectionsViewController : RJBasicViewController

@property (nonatomic,strong)NSNumber *collectionId;

@property (nonatomic,weak)id<CollectionsViewControllerDelegate>delegate;

@property (nonatomic,copy) zanBackBlock zanBlock;


/**
 *  3.0.0
 */
@property (assign, nonatomic) BOOL isSelf;
/**
 * 3.0.1 新增发布列表cell来源类型
 */
@property (strong, nonatomic) NSNumber <Optional> *event;
//3.1.0
@property (strong, nonatomic) RJHomeItemTypeTwoModel *homeItemTypeTwoModel;


@end
