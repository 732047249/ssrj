//
//  MsgCenterWithOutImgTableViewCell.h
//  ssrj
//
//  Created by YiDarren on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgCenterWithOutImgTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *describeLabel;

@property (weak, nonatomic) IBOutlet UILabel *messageTimeLabel;

@end
