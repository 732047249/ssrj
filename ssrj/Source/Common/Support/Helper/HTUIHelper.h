//
//  HTUIHelper.h
//  LLLove
//
//  Created by George on 14-7-3.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum {
	kZHCellBackgroundPositionSingle = 0,
	kZHCellBackgroundPositionTop,
	kZHCellBackgroundPositionMiddle,
	kZHCellBackgroundPositionBottom,
} ZHCellBackgroundPosition;

@interface HTUIHelper : NSObject
+(instancetype)shareInstance;
// 提醒
+ (void)alertMessage:(NSString *)message;

// HUD
+ (void)addHUDToWindowWithString:(NSString *)string;
+ (void)addHUDToWindowWithString:(NSString *)string hideDelay:(CGFloat)delay;


+ (void)removeHUDToWindow;
+ (void)removeHUDToWindowWithEndString:(NSString *)string image:(UIImage *)image delyTime:(NSTimeInterval)time;
+ (void)addHUDToView:(UIView *)view withString:(NSString *)string xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset;
+ (void)addHUDToView:(UIView *)view withString:(NSString *)string hideDelay:(CGFloat)delay;


//新HUD 不使用类方法
- (void)addHUDToView:(UIView *)view withString:(NSString *)string xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset;
- (void)editWithString:(NSString *)str;
- (void)removeHUD;
- (void)removeHUDWithEndString:(NSString *)endString image:(UIImage *)image;
- (void)removeHUDWithEndString:(NSString *)endString image:(UIImage *)image delyTime:(NSTimeInterval)time;

// BarItem
+ (UIBarButtonItem *)createStringNavBarItem:(NSString *)title
                               actionObject:(id)actionObject
                                     action:(SEL)action
                                buttonImage:(UIImage *)buttonImage
                       buttonHighlightImage:(UIImage *)buttonHighlightImage;
+ (UIBarButtonItem *)createImageNavBarItem:(UIImage *)buttonImage
                      buttonHighlightImage:(UIImage *)buttonHighlightImage
                              actionObject:(id)actionObject
                                    action:(SEL)action
                                    isLeft:(BOOL)isLeft;

+ (void)setTableViewCellBackground:(UITableView *)tableView
                              cell:(UITableViewCell *)cell
                         indexPath:(NSIndexPath *)indexPath;

/* resize image */
+ (UIImage *)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize;
+ (UIImage *)clipImageToCircle:(UIImage *)image;


@end
