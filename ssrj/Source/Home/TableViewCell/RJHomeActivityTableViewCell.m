
#import "RJHomeActivityTableViewCell.h"
#import "RJHomeWebActivityModel.h"

@interface RJHomeActivityTableViewCell ()
@end

@implementation RJHomeActivityTableViewCell
- (void)setNormalModel:(RJHomeWebActivityModel *)normalModel{
    _normalModel = normalModel;
    [self.activeImageView sd_setImageWithURL:[NSURL URLWithString:normalModel.path] placeholderImage:GetImage(@"640X200")];

    self.trackingId = [NSString stringWithFormat:@"%@&RJHomeActivityTableViewCell&id=%@",[[RJAppManager sharedInstance]currentViewControllerName],normalModel.id.stringValue];

}

@end
