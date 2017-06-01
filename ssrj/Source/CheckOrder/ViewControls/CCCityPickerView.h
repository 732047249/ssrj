//
//  CCCityPickerView.h
//  ssrj
//
//  Created by CC on 16/6/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CCCityPickerViewDelegate <NSObject>
- (void)didSelectedAddress:(NSString *)address areaId:(NSNumber *)idNum;
@end

@interface CCCityPickerView : UIView
@property (assign, nonatomic) id<CCCityPickerViewDelegate> delegate;
@property (strong, nonatomic) UIPickerView * pickerView;

- (void)showPickerView;
- (void)hidePickerView;
@end
