//
//  RJUserCenterHeaderView.h
//  ssrj
//
//  Created by CC on 16/9/24.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "STHeaderView.h"
#import "FXBlurView.h"
@interface RJUserCenterHeaderView : STHeaderView

@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UIView *fxBlurView;
@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *memoLabel;
@property (weak, nonatomic) IBOutlet UILabel *followCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

@property (weak, nonatomic) IBOutlet UIButton *goFollowListButton;
@property (weak, nonatomic) IBOutlet UIButton *goFansListButton;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end
