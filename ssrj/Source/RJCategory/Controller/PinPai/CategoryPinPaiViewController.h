//
//  CategoryPinPaiViewController.h
//  ssrj
//
//  Created by MFD on 16/5/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CategoryPinPaiViewController : UIViewController

@end

//for search
@interface CategoryCollectionHeaderView : UICollectionReusableView

@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *topButton;

@end