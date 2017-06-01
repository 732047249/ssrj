//
//  SMMatchCutoutCollectionCell.h
//  ssrj
//
//  Created by MFD on 16/11/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//切图条

#import <UIKit/UIKit.h>
#import "SMMatchCutoutModel.h"
@interface SMMatchCutoutCollectionCell : UICollectionViewCell
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)SMMatchCutoutModel *cutModel;
@property (nonatomic,copy)void (^clickBlock)();
@end
