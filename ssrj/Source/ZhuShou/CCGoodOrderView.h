//
//  CCGoodOrderView.h
//  ssrj
//
//  Created by CC on 16/8/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>



@class CCPriceButon;
typedef NS_ENUM(NSUInteger, CCOrderType) {
    CCOrderNew = 0,
    CCOrderPriceAsc,
    CCOrderPriceDesc,
    CCOrderHot,
};



@protocol CCGoodOrderViewDelegate <NSObject>
@optional
- (void)changeOrderWithOrderType:(CCOrderType) type;
- (void)filterButtonTaped;
@end


@interface CCGoodOrderView : UIView
@property (weak, nonatomic) IBOutlet UIButton * buttonOne;
@property (weak, nonatomic) IBOutlet UIButton * buttonThree;
@property (weak, nonatomic) IBOutlet CCPriceButon * buttonTwo;
@property (weak, nonatomic) IBOutlet UIButton * filterButton;
@property (assign, nonatomic) CCOrderType selectOrderType;
@property (assign, nonatomic) id<CCGoodOrderViewDelegate> delegate;
@end


@interface CCPriceButon  : UIButton
@property (strong, nonatomic) CAShapeLayer * upLayer;
@property (strong, nonatomic) CAShapeLayer * downLayer;
- (void)showUpIndicator;
- (void)showDownIndicator;
- (void)closeIndicator;
@end