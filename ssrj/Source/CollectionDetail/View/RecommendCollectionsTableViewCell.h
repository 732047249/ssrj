//
//  RecommendCollectionsTableViewCell.h
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendCollectionsModel.h"
#import "RJUserCenteRootViewController.h"
#import "EditImageView.h"

@interface RecommendCollectionsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *recommendCollectionsColView;
@property (nonatomic,strong) NSArray *dataArray;
//记录当前搭配推荐cell从哪个搭配进入的 for 统计上报 add 12.20
@property (strong, nonatomic) NSNumber *collectionID;

@end




@interface RecommendCollectionsCollectionViewCell : UICollectionViewCell
@property (nonatomic,weak)IBOutlet UIButton *shoucangbtn;
@property (weak, nonatomic) IBOutlet EditImageView *recommendCollectionsImageView;
@property (weak, nonatomic) IBOutlet UILabel *recommendCollectionsName;

@property (weak, nonatomic) IBOutlet UIImageView *authorIcon;
@property (weak, nonatomic) IBOutlet UIButton *addToThemeBtn;
@property (weak, nonatomic) IBOutlet UIButton *zanBtn;

- (IBAction)zan:(id)sender;
- (IBAction)addToTheme:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *recommendCollectionAuthor;

@property (nonatomic,strong) CollocationsItem *dataModel;

@property (weak, nonatomic) id<RJTapedUserViewDelegate>userDelegate;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightLineWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLineHeightConstraint;




@end
