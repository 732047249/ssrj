//
//  BubbleView.h
//  ssrj
//
//  Created by MFD on 16/11/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BubbleViewDirection)  {
    BubbleViewDirectionArc,
    BubbleViewDirectionLeft,
    BubbleViewDirectionRight
};

//气泡
@interface BubbleView : UIView
@property (nonatomic,strong)NSString *title;
@property (nonatomic, assign) BubbleViewDirection direction;
@property (nonatomic, assign) CGFloat bubbleHeight;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) CGFloat sharpConers;
@end
