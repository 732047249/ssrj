//
//  SMCategaryDetailController.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@interface SMCategaryDetailController : UIViewController
//显示第几个bar。
@property (nonatomic,assign)NSInteger selectIndex;
//所有单品或素材的数据(上页的模型数组)。
@property (nonatomic,strong)NSArray * tabbarArray;
//判断是搜索单品还是素材。
@property (nonatomic,assign)BOOL isFromAllGoods;
@end
