
#import "RJUserCenterHeaderView.h"
#import "UIImage+New.h"
@interface RJUserCenterHeaderView ()
@end

@implementation RJUserCenterHeaderView
- (void)awakeFromNib{
    [super awakeFromNib];

    self.avatorImageView.layer.cornerRadius = self.avatorImageView.height/2;
    self.avatorImageView.clipsToBounds = YES;
    self.avatorImageView.layer.borderWidth = 2;
    self.avatorImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.followButton.layer.cornerRadius = self.followButton.frame.size.width/2;
    self.followButton.clipsToBounds = YES;
    [self layoutSubviews];
    
    
    
}

@end
