
#import "HomeTopicTableViewCell.h"
#import "RJHomeTopicModel.h"
@interface HomeTopicTableViewCell ()
@end

@implementation HomeTopicTableViewCell

- (void)awakeFromNib{
    [super awakeFromNib];
    self.avatarImageView.layer.borderWidth = 1;
    self.avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.avatarImageView.clipsToBounds = YES;
    self.actionlabel.text = @"";
    
    /**
     *  点击用户头像去个人中心界面 添加Tap事件
     */
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    self.avatarImageView.userInteractionEnabled = YES;
    self.authorNameLabel.userInteractionEnabled = YES;
    
    [self.avatarImageView addGestureRecognizer:tapGest1];
    [self.authorNameLabel addGestureRecognizer:tapGest2];
}

- (void)TapUserViewAction:(UITapGestureRecognizer *)sender{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [self.delegate didTapedUserViewWithUserId:self.model.member.id userName:self.model.member.name];
    }
    if (sender.view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
    }
}
- (void)setModel:(RJHomeTopicModel *)model{
    _model = model;
    self.blackView.hidden = NO;
    if (!model.name.length) {
        self.blackView.hidden = YES;
    }
    [self.topicImageView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:GetImage(@"640X425")];
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.member.avatar] placeholderImage:GetImage(@"default_1x1")];
    self.topicTitleLabel.text = model.name;
    self.lookButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.hits.intValue];
    self.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
    self.likeButton.selected = model.isThumbsup.boolValue;
    self.authorNameLabel.text = model.member.name;
    self.lookButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.hits.intValue];
    /**
     *  统计ID
     */
    NSString *str = [[RJAppManager sharedInstance]currentViewControllerName];
    if (self.fatherViewControllerName.length) {
        str = self.fatherViewControllerName;
    }
    self.trackingId = [NSString stringWithFormat:@"%@&HomeTopicTableViewCell&id=%@",str,model.id.stringValue];
    self.likeButton.trackingId = [NSString stringWithFormat:@"%@&HomeTopicTableViewCell&likeButton&id=%@",str,model.id.stringValue];
    self.authorNameLabel.trackingId = [NSString stringWithFormat:@"%@&HomeTopicTableViewCell&authorNameLabel&id=%@",str,model.id.stringValue];
    self.avatarImageView.trackingId = [NSString stringWithFormat:@"%@&HomeTopicTableViewCell&avatarImageView&id=%@",str,model.id.stringValue];
    self.categoryButton.trackingId = [NSString stringWithFormat:@"%@&HomeTopicTableViewCell&categoryButton&id=%@",str,model.id.stringValue];
    self.topicButton.trackingId = [NSString stringWithFormat:@"%@&HomeTopicTableViewCell&topicButton&id=%@",str,model.id.stringValue];

}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [touches anyObject];
//    NSInteger a = [touch tapCount];
//    if (a == 2) {
//        NSLog(@"success");
//    }
//    if (a==1) {
//        [super touchesEnded:touches withEvent:event];
//    }
//    
//}
@end
