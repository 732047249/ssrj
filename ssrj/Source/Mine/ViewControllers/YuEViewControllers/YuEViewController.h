//
//  YuEViewController.h
//  ssrj
//
//  Created by YiDarren on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
@interface YuEViewController : RJBasicViewController

@property (weak, nonatomic) IBOutlet UILabel *monyeLabel;

@end



//明细cell
@interface MingXiTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *mingXinImageView;

@property (weak, nonatomic) IBOutlet UIImageView *indexImageview;

@end



//订单支付cell
@interface DingDanPayedTableViewCell: UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dingDanLabel;

@property (weak, nonatomic) IBOutlet UILabel *dingDanTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *moneyLeftLabel;

@property (weak, nonatomic) IBOutlet UILabel *moneyUsedLabel;



@end