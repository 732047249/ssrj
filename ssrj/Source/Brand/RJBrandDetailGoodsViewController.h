//
//  RJBrandDetailGoodsViewController.h
//  ssrj
//
//  Created by CC on 16/9/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "STCollectionView.h"
@class RJBrandDetailRootViewController;

@protocol RJBrandDetailGoodsViewControllerDelegate  <NSObject>
@optional
- (void)reloadRJBrandRootVCData;

@end

@interface RJBrandDetailGoodsViewController : UICollectionViewController
@property (strong, nonatomic) STCollectionView * stCollectionView;

@property (strong, nonatomic) NSNumber * brandId;
@property (strong, nonatomic) NSDictionary * parameterDictionary;
@property (assign, nonatomic) RJBrandDetailRootViewController * fatherViewController;

@property (weak, nonatomic) id<RJBrandDetailGoodsViewControllerDelegate> delegate;
@end
