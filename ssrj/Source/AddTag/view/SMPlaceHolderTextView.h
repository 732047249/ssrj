//
//  SMPlaceHolderTextView.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMPlaceHolderTextView : UITextView
/** 占位文字 */
@property (nonatomic, copy) NSString *placeholder;
/** 占位文字的颜色 */
@property (nonatomic, strong) UIColor *placeholderColor;
@end
