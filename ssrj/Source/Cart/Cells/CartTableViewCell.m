
#import "CartTableViewCell.h"

@interface CartTableViewCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeftWithImageViewConstrant;
@end

@implementation CartTableViewCell
- (void)awakeFromNib{
    [super awakeFromNib];

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
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(editViewTap)];
    [self.editView addGestureRecognizer:tapGesture];
}
- (void)editViewTap{
    // do nothing
}
- (void)setModel:(CartItemModel *)model{
    _model = model;
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail.length?model.thumbnail:model.product.image] placeholderImage:GetImage(@"default_1x1")];
    [self.colorImageView sd_setImageWithURL:[NSURL URLWithString:model.product.colorPicture] placeholderImage:nil];
    self.nameLabel.text = model.product.name;
    self.brandNameLabel.text = model.product.brandName;
    self.sizeNameLabel.text = model.product.specification;
    self.countNumberLabel.text = [NSString stringWithFormat:@"x%d",model.quantity.intValue];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"￥%d",model.product.effectivePrice.intValue];
//    self.choceButton.selected = model.customIsChecked.boolValue;
    
    self.editCountLabel.text = [NSString stringWithFormat:@"%d",model.quantity.intValue];
    self.subtractButton.enabled = YES;
    if (model.quantity.intValue == 1) {
        self.subtractButton.enabled = NO;
    }
}
@end


@implementation CartSoldOutTableCell
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
- (void)setModel:(CartItemModel *)model{
    _model = model;
    [self.goodImageView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail.length?model.thumbnail:model.product.image] placeholderImage:GetImage(@"default_1x1")];
    [self.colorImageView sd_setImageWithURL:[NSURL URLWithString:model.product.colorPicture] placeholderImage:nil];
    self.nameLabel.text = model.product.name;
    self.brandNameLabel.text = model.product.brandName;
    self.sizeNameLabel.text = model.product.specification;
    self.countNumberLabel.text = [NSString stringWithFormat:@"x%d",model.quantity.intValue];
    self.goodPriceLabel.text = [NSString stringWithFormat:@"￥%d",model.product.effectivePrice.intValue];
//    self.choceButton.selected = model.customIsChecked.boolValue;


}


@end