//
//  MFDAfterSalesReturnGoodsViewController.h
//  ssrj
//
//  Created by YiDarren on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"


@interface MFDAfterSalesReturnGoodsViewController : RJBasicViewController

//退换货ID
@property (strong,nonatomic) NSNumber *afterSalesId;
//用来区别申请服务类别（换货｜退货）
@property (strong, nonatomic) NSString *applyType;

@end
