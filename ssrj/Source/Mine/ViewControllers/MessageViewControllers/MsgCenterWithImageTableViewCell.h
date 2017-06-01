//
//  MsgCenterWithImageTableViewCell.h
//  ssrj
//
//  Created by YiDarren on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgCenterWithImageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *icon;

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UILabel *describeLabel;

@property (strong, nonatomic) IBOutlet UILabel *messageTimeLabel;

@property (strong, nonatomic) IBOutlet UIImageView *detailImageView;

@end
