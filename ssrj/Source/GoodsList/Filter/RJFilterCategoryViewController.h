//
//  RJFilterCategoryViewController.h
//  ssrj
//
//  Created by CC on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
@class RJFilterCategoryModel;
@interface RJFilterCategoryViewController : RJBasicViewController
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSMutableArray * selectIdArray;

@end



@interface RJFilterCategoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView * selectImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end


@class RJFilterCategoryHeaderView;

@protocol RJFilterCategoryHeaderViewDelegate <NSObject>
- (void)didClickHeaderView:(RJFilterCategoryHeaderView *)headerView;

@end

/**
 *  header头  折叠cell
 */

@interface RJFilterCategoryHeaderView : UITableViewHeaderFooterView
@property (assign, nonatomic) id<RJFilterCategoryHeaderViewDelegate> delegate;
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) UIImageView * imageView;
@property (strong, nonatomic) UILabel *lineLabel;
@property (strong, nonatomic) RJFilterCategoryModel * model;
@property (strong, nonatomic) UIImageView * iconImageView;
@end

