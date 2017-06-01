//
//  HHLineStyleViewController.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HHImageStyle;
@protocol HHLineStyleViewControllerDelegate <NSObject>

- (void)yf_didSelectLineStyle:(HHImageStyle *)imageStyle;

@end
@interface HHLineStyleViewController : UIViewController

@property (nonatomic, weak) id<HHLineStyleViewControllerDelegate> delegate;
@end
