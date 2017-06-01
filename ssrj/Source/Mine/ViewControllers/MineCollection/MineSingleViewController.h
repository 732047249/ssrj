//
//  MineSingleViewController.h
//  ssrj
//
//  Created by YiDarren on 16/8/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol MineSingleViewControllerDelegate <NSObject>
//- (void)updataGoodsWithModel:()
@end

@interface MineSingleViewController :RJBasicViewController
@property (assign, nonatomic) id<MineSingleViewControllerDelegate> delegate;
@property (strong, nonatomic) NSNumber *choseId;
@property (strong, nonatomic) NSString *titleLabelNumString;

@end
