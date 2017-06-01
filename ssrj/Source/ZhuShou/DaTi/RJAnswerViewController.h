//
//  RJAnswerViewController.h
//  ssrj
//
//  Created by CC on 16/8/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RJAnswerViewControllerDelegate <NSObject>

- (void)redoAnswerSaveAction;

@end
@interface RJAnswerViewController : UIViewController
@property (assign, nonatomic) BOOL  isFirstIn;
@property (assign, nonatomic) BOOL  isPresentIn;
@property (weak, nonatomic) id<RJAnswerViewControllerDelegate> delegate;

@end



