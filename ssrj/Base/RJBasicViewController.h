//
//  RJBasicViewController.h
//  ssrj
//
//  Created by CC on 16/5/31.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCButton.h"
typedef NS_ENUM(NSInteger ,RJButtonItemType){
    RJNavSearchButtonItem = 0,
    RJNavCartButtonItem,
    RJNavShareButtonItem,
    RJNavBackButtonItem,
    RJNavScanButtonItem,
    RJNavColseButtonItem,
    RJNavDoneButtonItem,
    RJNavLikeButtonItem
};
typedef NS_ENUM(NSInteger ,RJSideType){
    RJNavLeftSide,
    RJNavRightSide
};
@interface RJBasicViewController : UIViewController<UIGestureRecognizerDelegate>
- (void)addBackButton;
- (void)addCloseButton;

- (void)addSaveButton;
- (UIBarButtonItem *)getBarButtonItemWithType:(RJButtonItemType)type;
- (void)addBarButtonItem:(RJButtonItemType)type onSide:(RJSideType)side;
- (void)addBarButtonItems:(NSArray *)itemsArray onSide:(RJSideType)side;

- (void)enableBackSwipeGesture;
- (void)disableBackSwipeGesture;
//Title
- (void)setTitle:(NSString *)title tappable:(BOOL)tappable;
- (void)setTitle:(NSString *)title tappable:(BOOL)tappable textColor:(UIColor *)textColor;
- (void)setTitleImage:(UIImage *)image;
//Action
- (void)back:(id)sender;
- (void)share:(id)sender;
- (void)cart:(id)sender;
- (void)search:(id)sender;
- (void)scan:(id)sender;
- (void)dismiss:(id)sender;
- (void)done:(id)sender;
- (void)like:(id)sender;
- (void)save:(id)sender;
@property (nonatomic,strong) UIImageView * triangleImg;
@property (nonatomic, assign) BOOL  isRootViewController;
@end



@interface CCCartBarItemButton : UIButton
@end
