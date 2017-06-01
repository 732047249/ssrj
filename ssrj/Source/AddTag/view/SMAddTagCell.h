//
//  SMAddTagCell.h
//  ssrj
//
//  Created by MFD on 16/11/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMGoodsModel.h"
@interface SMAddTagCell : UICollectionViewCell
@property (nonatomic,strong)SMGoodsModel *model;
@property (nonatomic,copy) void (^deleteBlock)();
@end
