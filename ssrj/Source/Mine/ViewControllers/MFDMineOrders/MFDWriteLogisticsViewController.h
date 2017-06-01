//
//  MFDWriteLogisticsViewController.h
//  ssrj
//
//  Created by YiDarren on 16/11/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol MFDWriteLogisticsViewControllerDelegate <NSObject>
//刷新售后订单数据
- (void)reloadServiceOrderData;

@end

@interface MFDWriteLogisticsViewController : RJBasicViewController

//退换货单id
@property (strong, nonatomic) NSNumber *goodsId;

@property (strong, nonatomic) id<MFDWriteLogisticsViewControllerDelegate> delegate;

@end
