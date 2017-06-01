//
//  ChoseCouponViewController.h
//  ssrj
//
//  Created by CC on 16/6/15.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
@class RJCouPonModel;
@protocol ChoseCouponDelegate <NSObject>
- (void)updateOrderWithModel:(RJCouPonModel *)model;
@end

@interface ChoseCouponViewController : RJBasicViewController
@property (assign, nonatomic) id<ChoseCouponDelegate> delegate;
@property (strong, nonatomic) NSNumber *choseId;
/**
 *  2.1.4 启用V5接口 要给cartItemId
 */
@property (strong, nonatomic) NSString * cartItemIds;

@end
