//
//  FilterListViewController.h
//  ssrj
//
//  Created by CC on 16/6/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@protocol FilterListViewDelegate <NSObject>

//- (void)filiterDownWithDictionary:(NSMutableDictionary *)dic;
@optional
- (void)filiterDownWithDictionary:(NSMutableDictionary *)dic shouldReload:(BOOL)flag;
//为了刷新品牌rootVC，给goodsVC通知
- (void)filiterRJBrandRootVCInGoodVC;

@end

@interface FilterListViewController : RJBasicViewController


@property (strong, nonatomic) NSMutableDictionary * dictionary;
@property (strong, nonatomic) NSMutableArray * filterPriceArray;
@property (strong, nonatomic) NSMutableArray * filterColorArray;
@property (strong, nonatomic) NSMutableArray * filterCategoryArray;
@property (strong, nonatomic) NSMutableArray * filterBrandArray;
@property (assign, nonatomic) id<FilterListViewDelegate> delegate;
//@property (strong, nonatomic) NSMutableArray * filterSizeArray;
/**
 *  从商品列表传递过来的请求参数
 */
@property (strong, nonatomic) NSMutableDictionary * parameterDictionary;

- (void)updateFilterDic;

@end


@interface FilterListViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *choseLabel;
@end