//
//  RJBrandDetailRootViewController.h
//  ssrj
//
//  Created by CC on 16/9/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
//#define ST_PULLTOREFRESH_HEADER_HEIGHT  54.0


@protocol RJBrandDetailRootViewControllerDelegate <NSObject>
@optional
- (void)reloadSegmentBarItemsDataWithArray:(NSArray *)array;

@end


@interface RJBrandDetailRootViewController : RJBasicViewController
@property (strong, nonatomic) NSNumber * brandId;
@property (strong, nonatomic) NSDictionary * parameterDictionary;
/**
 *  筛选条件
 */
@property (strong, nonatomic) NSMutableDictionary *filterDictionary;
- (void)getBrandHeanderData;
@end
