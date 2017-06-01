
#import "CCGoodOrderWithOutFilterView.h"

@interface CCGoodOrderWithOutFilterView ()
@end

@implementation CCGoodOrderWithOutFilterView

- (void)awakeFromNib{
    [super awakeFromNib];
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
@end
