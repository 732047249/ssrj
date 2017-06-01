
#import "RJUserFollowListTableViewCell.h"
#import "UIImage+New.h"
#import "RJFansListItemModel.h"
@interface RJUserFollowListTableViewCell ()
@end

@implementation RJUserFollowListTableViewCell

- (void)awakeFromNib{
    [super awakeFromNib];
    [self.followButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#5d32b5"] size:self.followButton.size] forState:0];
    [self.followButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#e5e5e5"] size:self.followButton.size] forState:UIControlStateSelected];
}
- (void)setModel:(RJFansListItemModel *)model{
    _model = model;
    [self.avatorImageView sd_setImageWithURL:[NSURL URLWithString:model.headimg] placeholderImage:GetImage(@"default_1x1")];
    self.nameLabel.text = model.username;
    self.signLabel.text = model.memo?:@"尚未设置";
    self.fansCountLabel.text =[model.fansCount stringValue];
    self.followButton.selected = model.isSubscribe.boolValue;
    
}
@end
