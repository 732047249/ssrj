//
//  ThemeDetailCollectionViewCell.h
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeDetailModel.h"
#import "RJUserCenteRootViewController.h"
#import "EditImageView.h"
@interface ThemeDetailCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet EditImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UILabel *themeTitle;
@property (weak, nonatomic) IBOutlet UIImageView *authorIcon;
@property (weak, nonatomic) IBOutlet UILabel *author;
@property (weak, nonatomic) IBOutlet UIImageView *zanImageView;
@property (weak, nonatomic) IBOutlet UIButton *plusButton;
@property (weak, nonatomic) IBOutlet UIButton *likeItButton;


@property (weak, nonatomic) id<RJTapedUserViewDelegate> userDelegate;

@property (nonatomic,strong)ThemeCollocationList *collocationList;

/**
 *  3.0.0 管理合辑内容
 */
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLineWidth;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeight;

@end
