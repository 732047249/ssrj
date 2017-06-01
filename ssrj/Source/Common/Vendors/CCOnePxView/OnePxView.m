
#import "OnePxView.h"

@interface OnePxView ()
@end

@implementation OnePxView
-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.lineHeiConstraint) {
        self.lineHeiConstraint.constant = 1/[UIScreen mainScreen].scale;
        self.backgroundColor = [UIColor colorWithHexString:@"#dcdcdc"];
    }
}

@end
