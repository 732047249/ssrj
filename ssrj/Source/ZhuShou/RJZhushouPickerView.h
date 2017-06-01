//
//  RJZhushouPickerView.h
//  ssrj
//
//  Created by CC on 16/8/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RJZhushouPickerView;
@protocol RJZhushouPickerViewDelegate <NSObject>
- (void)didSelectDataWithInteger:(NSInteger ) data unitStr:(NSString *)unit pickerView:(RJZhushouPickerView *)view;
- (void)clearDataUnitStr:(NSString *)unit pickerView:(RJZhushouPickerView *)view;

@end

@interface RJZhushouPickerView : UIView
@property (strong, nonatomic) UIPickerView * pickerView;
@property (assign, nonatomic) id<RJZhushouPickerViewDelegate> delegate;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSString * unitStr;
@property (assign, nonatomic) NSInteger  defaultRow;
- (void)showPickerView;
- (void)hidePickerView;

- (instancetype)initWithDataArray:(NSMutableArray *)dataArray unitStr:(NSString *)unitStr defaultRow:(NSInteger)defaultRow;

@end

