//
//  RJAnswerTwoViewController.h
//  ssrj
//
//  Created by CC on 16/8/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCButton.h"
@protocol RJAnswersSavaDelegate;

@interface RJAnswerTwoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (assign, nonatomic) id<RJAnswersSavaDelegate> delegate;
@end




@interface RJAnswerTwoCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *colorImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@end



@interface RJAnswerTwoCollectionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end


@interface RJAnswerTwoCollectionFooterView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (weak, nonatomic) IBOutlet CCButton *noLikeButton;
@end