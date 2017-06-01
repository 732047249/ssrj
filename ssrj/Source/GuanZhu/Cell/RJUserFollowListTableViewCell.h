//
//  RJUserFollowListTableViewCell.h
//  ssrj
//
//  Created by CC on 16/9/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  RJFansListItemModel;
@interface RJUserFollowListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *signLabel;

@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (strong, nonatomic) RJFansListItemModel * model;
@end
