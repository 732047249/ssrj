//
//  CCMatchOrderView.h
//  ssrj
//
//  Created by CC on 16/8/31.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CCMatchOrderViewDelegate <NSObject>
@optional
- (void)didSelectButtonIndex:(NSInteger)index;
@end

@interface CCMatchOrderView : UIView


@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) id<CCMatchOrderViewDelegate> delegate;
@end

