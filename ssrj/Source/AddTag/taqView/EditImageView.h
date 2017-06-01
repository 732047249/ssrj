//
//  EditImageView.h
//  20161101
//
//  Created by MFD on 16/11/1.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagView.h"
#import "RJHomeItemTypeTwoModel.h"

@protocol EditImageViewDelegate<NSObject>
@optional
//添加标签
- (void)didTapEditTagViewWithTapPoint:(CGPoint)point;
//修改标签
- (void)didEditTagView:(TagView *)tagView;
//长按删除
- (void)didLongPressTagView:(TagView *)tagView;
@end

@interface EditImageView : UIImageView
@property (nonatomic,strong) NSMutableArray *tagViewArray;
@property (nonatomic,strong) NSMutableArray *tagModelArray;
@property (nonatomic,assign) BOOL allowLongPressDeleteTagView;
@property (nonatomic, assign) BOOL allowTapBgHiddenTagView;
@property (nonatomic, assign) BOOL allowTapTagView;
@property (nonatomic,weak)id<EditImageViewDelegate> delegate;
//点击标签回调
@property (nonatomic, copy) void (^gotoGoodsDetailBlock)(NSString *);
+ (instancetype)editViewWithFrame:(CGRect)frame;
- (void)addTagWithModel:(TagModel *)model;
- (void)deleteAllTagView;
- (void)addTagViewToCollocationWithDraftString:(NSString *)string goodsList:(NSArray<RJBaseGoodModel *> *)goodsList;
- (void)addTagViewToPictureWithDraftString:(NSString *)string goodsList:(NSArray<RJBaseGoodModel *> *)goodsList;
- (void)addTagViewToPCCollocationWithPositionArray:(NSArray<HHPCCollocationPositionModel *> *)positionArray goodsList:(NSArray<RJBaseGoodModel *> *)goodsList;

@end
