//
//  MsgCenterWithOutImgTableViewCell.m
//  ssrj
//
//  Created by YiDarren on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MsgCenterWithOutImgTableViewCell.h"

@implementation MsgCenterWithOutImgTableViewCell

-(void)prepareForReuse {
    [super prepareForReuse];
//    self.icon.image = nil;
    self.nameLabel.text = @"";
    self.describeLabel.text = @"";
    self.messageTimeLabel.text = @"";
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
//    self.icon.image = nil;
    self.nameLabel.text = @"";
    self.describeLabel.text = @"";
    self.messageTimeLabel.text = @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
