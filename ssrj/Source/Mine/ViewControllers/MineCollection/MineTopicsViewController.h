//
//  MineTopicsViewController.h
//  ssrj
//
//  Created by YiDarren on 16/8/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
@class RJHomeTopicModel;
@interface MineTopicsViewController : RJBasicViewController
@property (strong, nonatomic) NSString *titleNumString;
@end


@interface MineTopicsTableViewCell : UITableViewCell

@property (nonatomic,weak) IBOutlet UIImageView *topicImageView;
@property (nonatomic,weak) IBOutlet UILabel *scannerNumLabel;
@property (nonatomic,weak) IBOutlet UILabel *followerLabel;
@property (nonatomic,weak) IBOutlet UIImageView *userIcon;
@property (nonatomic,weak) IBOutlet UILabel *userNameLabel;
@property (nonatomic,weak) IBOutlet UILabel *topicTitleLabel;
@property (nonatomic,weak) IBOutlet CCButton *lookButton;

@property (nonatomic,weak) IBOutlet CCButton *likeButton;
//用于在资讯图片上放置黑色渐变蒙板
@property (nonatomic,strong) UIToolbar *toolbar;

@property (strong, nonatomic) RJHomeTopicModel *model;

@end