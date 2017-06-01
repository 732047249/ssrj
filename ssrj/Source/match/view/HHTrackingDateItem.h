//
//  HHTrackingDateItem.h
//  dd
//
//  Created by 夏亚峰 on 17/2/28.
//  Copyright © 2017年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HHTrackingDateItem;
@protocol HHTrackingDateItemDelegate <NSObject>

- (void)trackingDateItem:(HHTrackingDateItem *)trackingDateItem didSetupDate:(NSString *)dateString;

@end

@interface HHTrackingDateItem : UIView
@property (nonatomic, assign) CGFloat fontsize;
@property (nonatomic, strong) NSString *itemName;
@property (nonatomic, weak) id<HHTrackingDateItemDelegate> delegate;
@property (nonatomic, copy) NSString *dateString;
@end
