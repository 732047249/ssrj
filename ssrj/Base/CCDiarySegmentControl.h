//
//  CCDiarySegmentControl.h
//  ssrj
//
//  Created by CC on 16/5/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCDiaryTopBar;

@protocol CCDiarySegmentDelegate <NSObject>
- (void)selectedWithIndex:(NSInteger)index;

@end

@protocol CCDiaryTopBarTapDelegate <NSObject>
- (void)buttonSelectWithTag:(NSInteger)tag;
@end

//改变toolbar上方的数字
@protocol CCDiaryTopBarChanegNumberDelegate
- (void)changeTopNumberWithNumber:(NSInteger)number index:(NSInteger)index;

@end

@interface CCDiarySegmentControl : UIView<CCDiaryTopBarTapDelegate>
@property (strong, nonatomic) IBOutletCollection(CCDiaryTopBar) NSArray *topBars;
@property (assign, nonatomic) NSInteger  selectIndex;
@property (assign, nonatomic) id<CCDiarySegmentDelegate> delegate;
- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)flag;
@end



@interface CCDiaryTopBar : UIView
@property (weak, nonatomic) IBOutlet  UIButton *button;
@property (weak, nonatomic) IBOutlet  UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet  UILabel *numberCountLabel;
@property (weak, nonatomic) IBOutlet  UIView *indicator;
@property (weak, nonatomic) IBOutlet id<CCDiaryTopBarTapDelegate> delegate;
@property (assign, nonatomic) BOOL  isSelected;
- (IBAction)buttonAction:(id)sender;
@end
