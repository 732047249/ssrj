
#import "RJClickCountLabel.h"

@interface RJClickCountLabel ()
@end

@implementation RJClickCountLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor redColor];
        self.backgroundColor = [UIColor whiteColor];
        self.font = GetFont(9);
        self.text = @"11";
    }
    return self;
}
- (void)clikeLabelSizeToFit{
    self.frame = CGRectMake(2, self.superview.height/2, self.superview.width, 10);
    [self sizeToFit];
    self.width = self.width +10;
}
@end
