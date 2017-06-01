//
//  RJHomeNewSubjectCollectionCell.h
//  ssrj
//
//  Created by CC on 16/12/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCButton.h"
@interface RJHomeNewSubjectCollectionViewCell : UICollectionViewCell
@property (nonatomic,weak) IBOutlet UIImageView *   imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UIView *userView;

@end



@interface RJHomeNewSubjectCollectionHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet CCButton *countButton;

@end



@interface RJHomeNewSubjectCollectionFooterView : UICollectionReusableView

@end