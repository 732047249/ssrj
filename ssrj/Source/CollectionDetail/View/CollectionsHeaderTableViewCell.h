//
//  CollectionsHeaderTableViewCell.h
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendCollectionsModel.h"
#import "TagsView.h"
#import "RJUserCenteRootViewController.h"
#import "EditImageView.h"
typedef void(^zanBackBlock)(NSInteger);

@protocol CollectionsHeaderTableViewCellDelegate <NSObject>

- (void)letMeNotificateTheSuperVCToReloadData:(BOOL) btnSelected;

@end


@interface CollectionsHeaderTableViewCell : UITableViewCell

@property (nonatomic,copy) zanBackBlock zanBlock;

@property (weak, nonatomic) IBOutlet EditImageView *colllectionImageView;

@property (weak, nonatomic) IBOutlet UILabel *collectionName;
@property (weak, nonatomic) IBOutlet UILabel *collectionDescription;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorName;
@property (weak, nonatomic) IBOutlet TagsView *tagsView;

@property (weak, nonatomic) IBOutlet UIButton *addThemeBtn;

@property (weak, nonatomic) IBOutlet UIButton *zanBtn;

@property (weak, nonatomic) IBOutlet UILabel *zanCountLabel;


//- (IBAction)addToTheme:(id)sender;

- (IBAction)clickZan:(id)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionToTop;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagsViewHeight;
@property (strong, nonatomic) TagsFrames *tagsFrames;

@property (nonatomic,strong) NowCollocationModel *dataModel;

@property (strong, nonatomic) id<CollectionsHeaderTableViewCellDelegate> delegate;


@property (weak, nonatomic) id<RJTapedUserViewDelegate>userDelegate;

/**
 *  3.0.0
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerBottomLineHeightConstraint;

/**
 *  统计用的 上个界面的类名 不再从RJAppmanager 中取 效率低
 */
@property (nonatomic,strong) NSString * parentClassName;

@end
