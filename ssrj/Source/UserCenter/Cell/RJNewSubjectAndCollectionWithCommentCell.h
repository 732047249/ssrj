//
//  RJNewSubjectAndCollectionWithCommentCell.h
//  ssrj
//
//  Created by CC on 16/12/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCButton.h"
#import "RJHomeItemTypeFourModel.h"
#import "RJUserCenteRootViewController.h"
#import "RJHomeNewSubjectAndCollectionCell.h"
#import "EditImageView.h"
#import "YYLabel.h"
/**
 *  个人中心主题带评论的Cell
 */

@class RJNewSubjectAndCollectionCommentView;
@interface RJNewSubjectAndCollectionWithCommentCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonViewHieghtConstraint;
@property (weak, nonatomic) IBOutlet UIView *buttonView;

@property (weak, nonatomic) IBOutlet UIButton *bigButton;
@property (weak, nonatomic) IBOutlet CCButton *collectionButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *subjectTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectDescLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet CCButton *likeButton;
@property (strong, nonatomic) RJHomeItemTypeFourModel * model;

@property (weak, nonatomic) IBOutlet EditImageView *bigImageView;

@property (weak, nonatomic) IBOutlet UIView *bigImageFatherView;
@property (weak, nonatomic) IBOutlet UIImageView *smallImageView;
@property (nonatomic,weak) id<RJHomeNewSubjectAndCollectionCellDelegate,RJTapedUserViewDelegate> delegate;


/**
 *  3.0.0
 */
@property (weak, nonatomic) IBOutlet UIView *dropDownBgView;

@property (weak, nonatomic) IBOutlet UIButton *dropDownButton;

@property (weak, nonatomic) IBOutlet UILabel *unPublishLabel;


/**
 *  3.0.1
 */
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *actionLabel;




/**
 *  新增评论功能 CC
 */

@property (weak, nonatomic) IBOutlet UIView *commentSuperView;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;



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



@interface RJNewSubjectAndCollectionCommentView : UIView
@property (nonatomic,weak) IBOutlet UIImageView *  avatorImageView;
@property (nonatomic,weak) IBOutlet UILabel *  nameLable;
@property (nonatomic,weak) IBOutlet YYLabel *  commentLabel;
@property (nonatomic,weak) IBOutlet UILabel *  dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *  normalLabel;
@property (nonatomic,strong) RJCommentModel  * itemModel;
- (void)setYYLabelAttributeString:(NSAttributedString *)text;
@end
