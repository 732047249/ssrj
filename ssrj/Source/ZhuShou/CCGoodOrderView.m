
#import "CCGoodOrderView.h"

@interface CCGoodOrderView ()
@end

@implementation CCGoodOrderView
- (void)awakeFromNib{
    [super awakeFromNib];
    NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
    self.buttonOne.trackingId = [NSString stringWithFormat:@"%@&CCGoodOrderView&buttonOne",vcName];
    self.buttonTwo.trackingId = [NSString stringWithFormat:@"%@&CCGoodOrderView&buttonTwo",vcName];
    self.buttonThree.trackingId = [NSString stringWithFormat:@"%@&CCGoodOrderView&buttonThree",vcName];
    self.filterButton.trackingId = [NSString stringWithFormat:@"%@&CCGoodOrderView&filterButton",vcName];
}

- (void)setSelectOrderType:(CCOrderType)selectOrderTyp{
    _selectOrderType = selectOrderTyp;
    switch (selectOrderTyp) {
        case CCOrderNew:{
            self.buttonTwo.selected = NO;
            [self.buttonTwo closeIndicator];
            self.buttonThree.selected = NO;
        }
            break;
        case CCOrderPriceAsc:{
            self.buttonOne.selected = NO;
            self.buttonThree.selected = NO;
        }
            
            break;
        case CCOrderPriceDesc:{
            self.buttonOne.selected = NO;
            self.buttonThree.selected = NO;
        }
            
            break;
        case CCOrderHot:{
            self.buttonTwo.selected = NO;
            [self.buttonTwo closeIndicator];
            self.buttonOne.selected = NO;
        }
            break;
        default:
            break;
    }
    if (self.delegate) {
        [self.delegate changeOrderWithOrderType:selectOrderTyp];
//        NSLog(@"%lu",(unsigned long)selectOrderTyp);
    }
 
}

- (IBAction)buttonOneAction:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    //从未选中到选中
    self.selectOrderType = CCOrderNew;
    sender.selected = YES;
    
}
- (IBAction)buttonTwoAction:(CCPriceButon *)sender{
    if (!sender.selected) {
        //从未选中到选中 变为价格降序
        sender.selected = YES;
        self.selectOrderType = CCOrderPriceDesc;
        [sender showDownIndicator];
    }else{
        if (sender.selected) {
            if (self.selectOrderType == CCOrderPriceDesc) {
                self.selectOrderType = CCOrderPriceAsc;
                [sender showUpIndicator];
            }else{
                self.selectOrderType = CCOrderPriceDesc;
                [sender showDownIndicator];
            }
        }
    }
    
}
- (IBAction)buttonThreeAction:(UIButton *)sender{
    if (sender.selected) {
        return;
    }
    //从未选中到选中
    self.selectOrderType = CCOrderHot;
    sender.selected = YES;
}
- (IBAction)filterButtonAction:(UIButton *)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterButtonTaped)]) {
        [self.delegate filterButtonTaped];
    }
}
@end



@implementation CCPriceButon
- (void)awakeFromNib{
    [super awakeFromNib];
}
- (void)showUpIndicator{
    self.upLayer.fillColor = [UIColor colorWithHexString:@"#5d32b5"].CGColor;
    self.downLayer.fillColor = [UIColor grayColor].CGColor;

}
- (void)showDownIndicator{
    self.downLayer.fillColor = [UIColor colorWithHexString:@"#5d32b5"].CGColor;
    self.upLayer.fillColor = [UIColor grayColor].CGColor;
}
- (void)closeIndicator{
    self.downLayer.fillColor = [UIColor grayColor].CGColor;

    self.upLayer.fillColor = [UIColor grayColor].CGColor;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.upLayer) {
        self.upLayer = [CAShapeLayer new];
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(8, 0)];
        [path addLineToPoint:CGPointMake(4, -5)];
        [path closePath];
        
        self.upLayer.path = path.CGPath;
        self.upLayer.lineWidth = 1.0;
        self.upLayer.fillColor = [UIColor grayColor].CGColor;
        
        CGPathRef bound = CGPathCreateCopyByStrokingPath(_upLayer.path, nil, _upLayer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, _upLayer.miterLimit);
        _upLayer.bounds = CGPathGetBoundingBox(bound);
        CGPathRelease(bound);
        
        _upLayer.position = CGPointMake(self.titleLabel.xPosition + self.titleLabel.width + 7 , self.titleLabel.yPosition + 3);
        [self.layer addSublayer:_upLayer];
    }
    if (!self.downLayer) {
        self.downLayer = [CAShapeLayer new];
        UIBezierPath *path = [UIBezierPath new];
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(8, 0)];
        [path addLineToPoint:CGPointMake(4, 5)];
        [path closePath];
        self.downLayer.path = path.CGPath;
        self.downLayer.lineWidth = 1.0;
        self.downLayer.fillColor = [UIColor grayColor].CGColor;
        
        CGPathRef bound = CGPathCreateCopyByStrokingPath(_downLayer.path, nil, _downLayer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, _downLayer.miterLimit);
        _downLayer.bounds = CGPathGetBoundingBox(bound);
        CGPathRelease(bound);
        
        _downLayer.position = CGPointMake(self.titleLabel.xPosition + self.titleLabel.width + 7 , self.titleLabel.yPosition + self.titleLabel.height - 3);
        [self.layer addSublayer:_downLayer];
    }
    
}
@end
