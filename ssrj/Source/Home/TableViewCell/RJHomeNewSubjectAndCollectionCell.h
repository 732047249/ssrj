//
//  RJHomeNewSubjectAndCollectionCell.h
//  ssrj
//
//  Created by CC on 16/12/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCButton.h"
#import "RJHomeItemTypeFourModel.h"
#import "RJUserCenteRootViewController.h"
#import "CCCollectionView.h"
@protocol RJHomeNewSubjectAndCollectionCellDelegate <NSObject>

- (void)collectionSelectWithId:(NSNumber *)number;

@end


@interface RJHomeNewSubjectAndCollectionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonViewHieghtConstraint;
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet CCButton *collectionButton;
@property (weak, nonatomic) IBOutlet CCCollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *subjectTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectDescLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet CCButton *likeButton;
@property (strong, nonatomic) RJHomeItemTypeFourModel * model;

@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;

@property (weak, nonatomic) IBOutlet UIView *bigImageFatherView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (nonatomic,weak) id<RJHomeNewSubjectAndCollectionCellDelegate,RJTapedUserViewDelegate> delegate;


/**
 *  3.0.0
 */
@property (weak, nonatomic) IBOutlet UIView *dropDownBgView;

@property (weak, nonatomic) IBOutlet UIButton *dropDownButton;

@property (nonatomic, strong) NSString *fatherViewControllerName;


@end
