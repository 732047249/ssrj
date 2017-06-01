//
//  HHYiStoreAddGoodsController.h
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@protocol HHYiStoreAddGoodsControllerDelegate <NSObject>
- (void)yiStoreAddGoodsContollerDidFinishedChooseGoods;
@end

@interface HHYiStoreAddGoodsController : RJBasicViewController
@property (nonatomic, weak) id<HHYiStoreAddGoodsControllerDelegate> delegate;
- (void)cancelChooseAllState;
- (void)updateChooseSureBtnNummber;
@end
