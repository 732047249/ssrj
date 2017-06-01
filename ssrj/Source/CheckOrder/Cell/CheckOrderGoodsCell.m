
#import "CheckOrderGoodsCell.h"

@interface CheckOrderGoodsCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeftWithImageViewConstrant;

@end

@implementation CheckOrderGoodsCell
- (void)awakeFromNib{
    self.colorImageView.layer.cornerRadius = self.colorImageView.width/2;
    self.colorImageView.clipsToBounds = YES;
    self.goodImageView.layer.borderWidth = 1;
    self.goodImageView.layer.borderColor = [UIColor colorWithHexString:@"#e5e5e5"].CGColor;
    if (DEVICE_IS_IPHONE4 ||DEVICE_IS_IPHONE5) {
        self.textViewLeftWithImageViewConstrant.constant = 10;
    }
    if (DEVICE_IS_IPHONE6) {
        self.textViewLeftWithImageViewConstrant.constant = 20;
    }
    if (DEVICE_IS_IPHONE6Plus) {
        self.textViewLeftWithImageViewConstrant.constant = 25;
    }
    [super awakeFromNib];
}
-(void)setModel:(CartItemModel *)model{

    _model = model;
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail.length?model.thumbnail:model.product.image] placeholderImage:GetImage(@"default_1x1")];
    [self.colorImageView sd_setImageWithURL:[NSURL URLWithString:model.product.colorPicture] placeholderImage:nil];
    self.nameLabel.text = model.product.name;
    self.brandNameLabel.text = model.product.brandName;
    self.sizeNameLabel.text = model.product.specification;
    self.countNumberLabel.text = [NSString stringWithFormat:@"x%d",model.quantity.intValue];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"￥%d",model.product.effectivePrice.intValue];
    self.markPriceLabel.attributedText = [NSString effectivePriceWithString:[NSString stringWithFormat:@"%d",model.product.marketPrice.intValue]];

    self.preSaleDescLabel.text = model.preSaleDesc;
}
@end
