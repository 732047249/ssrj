//
//  RJAnswerThreeViewController.h
//  ssrj
//
//  Created by CC on 16/8/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "RJAnswerOneViewController.h"
@protocol RJAnswersSavaDelegate;

@interface RJAnswerThreeViewController : UIViewController
@property (assign, nonatomic) id<RJAnswersSavaDelegate> delegate;
@end




@interface RJAnswerThreeCollectionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end


@interface RJAnswerThreeCollectionFooterView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@end


@interface RJAnswerThreeCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;
@end


@interface RJAnswerThreeNolikeCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@end