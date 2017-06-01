//
//  categoryTableViewCell.h
//  categoryDemo
//
//  Created by MFD on 16/5/24.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface categoryTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *picture;

@property (nonatomic,strong) UILabel * categoryLabel;
@property (nonatomic,strong) UILabel * engCategoryLabel;

@property (nonatomic,strong) UIView *coverView;

- (CGFloat)cellOffset;

@end
