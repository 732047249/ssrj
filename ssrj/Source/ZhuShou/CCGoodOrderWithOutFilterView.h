//
//  CCGoodOrderWithOutFilterView.h
//  ssrj
//
//  Created by CC on 17/1/13.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCGoodOrderView.h"
@interface CCGoodOrderWithOutFilterView : UIView
@property (weak, nonatomic) IBOutlet UIButton * buttonOne;
@property (weak, nonatomic) IBOutlet UIButton * buttonThree;
@property (weak, nonatomic) IBOutlet CCPriceButon * buttonTwo;
//@property (weak, nonatomic) IBOutlet UIButton * filterButton;
@property (assign, nonatomic) CCOrderType selectOrderType;
@property (assign, nonatomic) id<CCGoodOrderViewDelegate> delegate;
@end
