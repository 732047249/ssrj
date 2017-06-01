
#import "CCDiarySegmentControl.h"

@interface CCDiarySegmentControl ()

@end

@implementation CCDiarySegmentControl
-(void)awakeFromNib{
    [super awakeFromNib];
    self.selectIndex = 0;
    CCDiaryTopBar *topBar = self.topBars.firstObject;
    topBar.isSelected = YES;
    
}
- (void)buttonSelectWithTag:(NSInteger)tag{
    for (CCDiaryTopBar * topBat in self.topBars) {
        topBat.isSelected = NO;
        if (topBat.button.tag == tag) {
            topBat.isSelected = YES;
            self.selectIndex = tag;
            if (self.delegate) {
                [self.delegate selectedWithIndex:self.selectIndex];
            }
        }
    }
}
- (void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)flag{
    for (CCDiaryTopBar * topBat in self.topBars) {
        topBat.isSelected = NO;
        if (topBat.button.tag == index) {
            topBat.isSelected = YES;
            self.selectIndex = index;
        }
    }
}

@end


@implementation CCDiaryTopBar

-(void)awakeFromNib{
    [super awakeFromNib];
    self.indicator.backgroundColor = [UIColor colorWithHexString:@"#6225de"];
    self.numberCountLabel.textColor = [UIColor colorWithHexString:@"#898e90"];
    
}
-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    self.titleLabel.textColor = _isSelected?[UIColor colorWithHexString:@"#5d32b5"]:[UIColor colorWithHexString:@"#424446"];
    self.numberCountLabel.textColor = _isSelected?[UIColor colorWithHexString:@"#5d32b5"]:[UIColor colorWithHexString:@"#898e90"];
    self.indicator.hidden = !_isSelected;
}
- (IBAction)buttonAction:(id)sender{
    if (self.isSelected) {
        return;
    }
    UIButton *button = (UIButton *)sender;
    [self.delegate buttonSelectWithTag:button.tag];
    
}
@end