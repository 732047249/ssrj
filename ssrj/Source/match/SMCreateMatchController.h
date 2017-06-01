//
//  SMCreateMatchController.h
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMMatchView.h"
@interface SMCreateMatchController : UIViewController
/** 添加标签（所有单品或素材） */
- (void)addGoodsOrSourceWithModel:(SMGoodsModel *)model;
/** 新建搭配，删除搭配内容 */
- (void)deleteMatch;
@end
