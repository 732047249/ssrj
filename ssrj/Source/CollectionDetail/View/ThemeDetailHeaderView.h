//
//  ThemeDetailHeaderView.h
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThemeDetailModel.h"
#import "RJUserCenteRootViewController.h"

@interface ThemeDetailHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (weak, nonatomic) IBOutlet UILabel *themeTitle;
@property (weak, nonatomic) IBOutlet UILabel *themeDescription;
@property (weak, nonatomic) IBOutlet UILabel *themeNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *zanCountLabel;
//@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIView *zanBgView;
@property (weak, nonatomic) IBOutlet UIView *commentBgView;
@property (weak, nonatomic) IBOutlet UIImageView *zanIcon;
@property (weak, nonatomic) IBOutlet UIButton *zanButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIImageView *authorIcon;
@property (weak, nonatomic) IBOutlet UILabel *authorName;

@property (weak, nonatomic) IBOutlet UIImageView *followerImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *followerImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *followerImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *followerImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *followerImageView5;
@property (nonatomic,strong) ThemeData *data;

@property (strong, nonatomic) UIToolbar *toolbar;
//存取主题详情下对该主题关注过的用户(粉丝)数据 (暂不用，后续使用模型)
//@property (nonatomic,strong) NSArray *fansArr;

@property (weak, nonatomic) id<RJTapedUserViewDelegate>headerUserDelegate;


/**
 *  3.0.0
 */
//搭配、点赞背景 已发布状态
@property (weak, nonatomic) IBOutlet UIView *publishedHeaderDataView;
//搭配背景 未发布状态
@property (weak, nonatomic) IBOutlet UIView *unPublishedHeaderDataView;

@property (weak, nonatomic) IBOutlet UILabel *themeThumbNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *publishButton;


@end
