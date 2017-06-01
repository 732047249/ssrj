//
//  RJHomeCollectionAndGoodAndCommentCell.h
//  ssrj
//
//  Created by CC on 17/1/6.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJHomeItemTypeTwoModel.h"
#import "CCButton.h"
#import "RJUserCenteRootViewController.h"
#import "RJHomeCollectionAndGoodCell.h"
#import "RJNewSubjectAndCollectionWithCommentCell.h"
#import "EditImageView.h"

@interface RJHomeCollectionAndGoodAndCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHieghtConstraint;

@property (weak, nonatomic) IBOutlet UIButton *topViewButton;
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet EditImageView*collectionImageView;
@property (assign, nonatomic) id<RJHomeCollectionAndGoodCellDelegate> delegate;
@property (strong, nonatomic) id<RJTapedUserViewDelegate>  userDelegate;
/**
 *  GoodOne
 */
@property (weak, nonatomic) IBOutlet UIImageView *goodOneImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodOneNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *goodOneBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodOneCurrentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodOneMarkPriceLabel;

@property (weak, nonatomic) IBOutlet UIImageView *goodOneSpecialImageView;

/**
 *  GoodTwo
 */

@property (weak, nonatomic) IBOutlet UIImageView *goodTwoImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodTwoNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *goodTwoBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodTwoCurrentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodTwoMarkPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *collectionTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *collectionDesLabel;

@property (weak, nonatomic) IBOutlet UIImageView *avatorImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *goodTwoSpecialImageView;

@property (strong, nonatomic) RJHomeItemTypeTwoModel * model;
//新增加入合辑button 9.27
@property (weak, nonatomic) IBOutlet UIButton *putIntoThemeButton;

@property (weak, nonatomic) IBOutlet CCButton *likeButton;
/**
 *  2.2.0 Cell也要现实标签
 */

@property (weak, nonatomic) IBOutlet UIView *tagsView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagHeightConstraint;

/**
 *  3.0.0新增用户自己的编辑按钮
 */
@property (weak, nonatomic) IBOutlet UIView *dropDownBgView;
@property (weak, nonatomic) IBOutlet UIButton *dropDownButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middleLongLineWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *middelShortLineHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomShortLineHeightConstraint;


/**
 *  新增评论功能 CC 3.3.0
 */

@property (weak, nonatomic) IBOutlet UIView *commentSuperView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;

/**
 * 3.0.1 搭配cell添加时间Label
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *actionLabel;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentOneHeiConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTwoHeiConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentThreeHeiConstraint;

@property (weak, nonatomic) IBOutlet UIView *moreCommentView;

@property (weak, nonatomic) IBOutlet RJNewSubjectAndCollectionCommentView *commentViewOne;
@property (weak, nonatomic) IBOutlet RJNewSubjectAndCollectionCommentView *commentViewTwo;
@property (weak, nonatomic) IBOutlet RJNewSubjectAndCollectionCommentView *commentViewThree;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentSuperViewHeiConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentTopHeiConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentBottomHeiConstraint;

@property (nonatomic, strong) NSString *fatherViewControllerName;

@end
