//
//  HomeTopicTableViewCell.h
//  ssrj
//
//  Created by CC on 16/7/20.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCButton.h"
#import "RJUserCenteRootViewController.h"

@class RJHomeTopicModel;
@interface HomeTopicTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *topicImageView;
@property (weak, nonatomic) IBOutlet CCButton *lookButton;
@property (weak, nonatomic) IBOutlet CCButton *likeButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UIButton *topicButton;

@property (weak, nonatomic) IBOutlet UILabel *topicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (strong, nonatomic) RJHomeTopicModel * model;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) id<RJTapedUserViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIView *categoryView;
@property (weak, nonatomic) IBOutlet UIView *blackView;

/**
 *  3.0.0
 */
@property (weak, nonatomic) IBOutlet UIView *dropDownBgView;

@property (weak, nonatomic) IBOutlet UIButton *dropDownButton;

/**
 * 3.0.1 只在用户中心发布列表的资讯cell中打开
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *actionlabel;
@property (nonatomic, strong) NSString *fatherViewControllerName;

@end
