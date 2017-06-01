//
//  SMMatchView.h
//  CreateMatchView
//
//  Created by MFD on 16/11/9.
//  Copyright © 2016年 MFD. All rights reserved.
//面板

#import <UIKit/UIKit.h>
#import "SMMatchImageView.h"
#import "SMMatchDraftModel.h"
#import "SelfDefinedModel.h"
@class SMMatchImageView;
@class SMMatchView;
@protocol SMMatchViewDelegate <NSObject>
//点击面板上的图片
- (void)didTapMatchImage:(SMMatchView *)matchView;
//点击面板
- (void)didTapMatchView:(SMMatchView *)matchView;
@end

@interface SMMatchView : UIImageView<UIGestureRecognizerDelegate>
/** 记录选中的图片 */
@property (nonatomic,strong)SMMatchImageView *selectImageView;
/** 记录添加到面板上的图片 */
@property (nonatomic,strong)NSMutableArray *matchImageArray;
@property (nonatomic,weak)id<SMMatchViewDelegate>delegate;
/** 图片容器 */
@property (nonatomic,strong)UIImageView *imageContainerView;
/** 添加单张图片 */
- (void)addImageWithImageModel:(SMGoodsModel *)goodsModel;
/** 通过草稿添加到面板上 */
- (void)addImagesWithDraftModel:(SMMatchDraftModel *)draftModel;
/** 通过草稿添加背景到面板上 */
- (void)addBgImagesWithSelfDefineBgDraftModelArray:(NSArray *)draftModelArray;
/** 清空记录 */
- (void)deleteAllRecord;
@end
