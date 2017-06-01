//
//  JiFenViewController.h
//  ssrj
//
//  Created by YiDarren on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@interface JiFenViewController : RJBasicViewController
@property (weak, nonatomic) IBOutlet UIButton *tixianButton;

@end





//积分tableViewCell
@interface JiFenTableVeiwCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *jiFenLabel;


@end