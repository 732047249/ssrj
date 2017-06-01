//
//  SSClientViewController.h
//  ssrj
//
//  Created by mac on 17/2/15.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@interface SSClientViewController : RJBasicViewController

@end



#pragma mark -微店－我的客户－客户tableViewCell
@class SSMyClientModel;
@interface SSMyClientTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (strong,nonatomic) SSMyClientModel *model;

@property (strong,nonatomic) IBOutlet UITableView *orderTableView;

@property (strong,nonatomic) NSMutableArray *orderDataArr;

@end




@interface SSOrderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *orderTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderSSMoneyLabel;



@end