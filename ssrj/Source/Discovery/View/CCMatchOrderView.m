
#import "CCMatchOrderView.h"

@interface CCMatchOrderView ()
@end

@implementation CCMatchOrderView
- (void)awakeFromNib{
    [super awakeFromNib];
    NSString *vcName =[[RJAppManager sharedInstance] currentViewControllerName];
    for (int i=0; i< self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        button.trackingId = [NSString stringWithFormat:@"%@CCMatchOrderView&button%d",vcName,i];
    }
    
}
- (IBAction)buttonAction:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    for (UIButton *button in self.buttons) {
        button.selected = NO;
    }
    sender.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectButtonIndex:)]) {
        [self.delegate didSelectButtonIndex:sender.tag];
    }
}
@end
