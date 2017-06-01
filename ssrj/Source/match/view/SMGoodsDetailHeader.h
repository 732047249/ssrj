//
//  SMGoodsDetailHeader.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMGoodsDetailScrollView.h"
#import "RJGoodDetailModel.h"
@interface SMGoodsDetailHeader : UIView

@property (nonatomic,strong) SMGoodsDetailScrollView *goodsDetailScrollView;
@property (nonatomic,strong) UIButton *addGoodsButton;
@property (nonatomic,strong) UIButton *starButton;
@property (nonatomic,strong) RJGoodDetailModel *dataModel;
@end
