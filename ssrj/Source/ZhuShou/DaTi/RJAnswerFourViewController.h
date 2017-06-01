//
//  RJAnswerFourViewController.h
//  ssrj
//
//  Created by CC on 16/8/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RJAnswersSavaDelegate;

@interface RJAnswerFourViewController : UIViewController
@property (assign, nonatomic) id<RJAnswersSavaDelegate> delegate;

@end




@interface RJAnswerFourTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *selectImage;

@end
