//
//  SMMatchImage.h
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMGoodsModel.h"
@class SMMatchImageView;
@protocol SMMatchImageViewDelegate <NSObject>
//点击图片事件
- (void)didTapMatchImage:(SMMatchImageView *)imageView;
//图片的各种手势事件
- (void)didReseiveImageRegesture:(UIGestureRecognizer *)recognizer;
@end

@interface SMMatchImageView : UIImageView<UIGestureRecognizerDelegate>
//自定义的边框
@property (nonatomic,strong) CAShapeLayer *borderLayer;
@property (nonatomic,weak)id<SMMatchImageViewDelegate>delegate;
/** 每个图片对应一个商品模型（或素材模型） 
    类型区分：id存在是商品。不存在是素材
 */
@property (nonatomic,strong)SMGoodsModel * goodsModel;
/** 记录图片的是否垂直翻转 */
@property (nonatomic,assign)BOOL isFlipX;
/** 记录是不是背景图中的单品图) */
@property (nonatomic,assign)BOOL isBgGoodImage;
/** 记录是不是背景图 */
@property (nonatomic,assign)BOOL isBgImage;
@end
