//
//  CustomSegmentControl.h
//  SwipeTableView
//
//  Created by Roy lee on 16/5/28.
//  Copyright © 2016年 Roy lee. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CustomSegmentControl : UIControl

@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *selectionIndicatorColor;
@property (strong, nonatomic) UIView * indicatorView;
@property (nonatomic, strong) UIColor *indicatorViewColor;
@property (strong, nonatomic) UIView * lineView;
@property (nonatomic, strong) NSArray * items;


@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, copy) void (^IndexChangeBlock)(NSInteger index);

//@property (weak, nonatomic) id<CustomSegmentControlDelegate>delegate;

- (instancetype)initWithItems:(NSArray<NSString *> *)items;
- (void)reloadSegmentBarItemsDataWithArray:(NSArray *)array;

@property (nonatomic,strong) NSString *parentVcName;
@property (nonatomic,strong) NSNumber *parentVcID;

@end
