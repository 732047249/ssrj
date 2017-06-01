//
//  MsgCenterWithImageTableViewCell.m
//  ssrj
//
//  Created by YiDarren on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MsgCenterWithImageTableViewCell.h"

@implementation MsgCenterWithImageTableViewCell


-(void)prepareForReuse{
    [super prepareForReuse];
    
    self.icon.image = nil;
    self.nameLabel.text = @"";
    self.describeLabel.text = @"";
    self.messageTimeLabel.text = @"";
}


- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.icon.image = nil;
    self.nameLabel.text = @"";
    self.describeLabel.text = @"";
    self.messageTimeLabel.text = @"";
    self.detailImageView.layer.borderColor = [UIColor colorWithHexString:@"#c3c3c3"].CGColor;
    self.detailImageView.layer.borderWidth = .5;
    self.icon.layer.cornerRadius = self.icon.width/2;
    self.icon.clipsToBounds = YES;

    
}


@end
