
#import "HomePageFourCell.h"
#import "HomeGoodListViewController.h"
@interface HomePageFourCell ()<UICollectionViewDataSource,UICollectionViewDelegate>
@end

@implementation HomePageFourCell

- (void)setModel:(RJHomeItemTypeZeroModel *)model{

    _model = model;
    [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:_model.path] placeholderImage:GetImage(@"640X425")];
    /**
     *  统计ID
     */
    if (self.fatherViewClassName.length) {
       self.bigImageView.trackingId = [NSString stringWithFormat:@"%@&HomePageFourCell&bigImageView&id=%ld",self.fatherViewClassName,(long)model.id.integerValue];
    }else{
        self.bigImageView.trackingId = [NSString stringWithFormat:@"%@&HomePageFourCell&bigImageView&id=%ld",[[RJAppManager sharedInstance]currentViewControllerName],(long)model.id.integerValue];
    }
    self.goodsArray = [NSArray arrayWithArray:_model.goodsList];
    [self.collectionView reloadData];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.goodsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeFourCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FourCollectionCell" forIndexPath:indexPath];
    RJBaseGoodModel *model = self.goodsArray[indexPath.row];
    //加统计ID
    if (self.fatherViewClassName.length) {
           cell.trackingId = [NSString stringWithFormat:@"%@&%@&%@",self.fatherViewClassName,NSStringFromClass(self.class),model.goodId];
    }else{
         cell.trackingId = [NSString stringWithFormat:@"%@&%@&%@",[[RJAppManager sharedInstance]currentViewControllerName],NSStringFromClass(self.class),model.goodId];
    }
   
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
    cell.imageView.goodsModel = model;
    cell.goodNameLabel.text = model.name;
    cell.goodBrandLabel.text = model.brandName;
    cell.currentPriceLabel.text = [NSString stringWithFormat:@"¥%@",model.effectivePrice];
    cell.marketPriceLabel.attributedText = [NSString effectivePriceWithString:model.marketPrice];
    
    cell.currentPriceLabel.textColor = [UIColor blackColor];
    if (model.isSpecialPrice.boolValue) {
        cell.currentPriceLabel.textColor = [UIColor colorWithHexString:@"#F63649"];
    }
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(SCREEN_WIDTH/320*114 +8 +8, SCREEN_WIDTH/320*114 +64 +8 +8);
}
-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bigImageTapGestureAction:)];
    [self.bigImageView addGestureRecognizer:tapGesture];
    self.collectionView.scrollsToTop = NO;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionTapedWithGoodId:)]) {
        RJBaseGoodModel *model = self.goodsArray[indexPath.row];
        [self.delegate collectionTapedWithGoodId:model.goodId];
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionFooter) {
        HomeFourCollectionFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"HomeFourCollectionFooterView" forIndexPath:indexPath];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(footerViewTapGesture:)];
        [footer addGestureRecognizer:tapGesture];
        if (self.fatherViewClassName.length) {
           footer.trackingId= [NSString stringWithFormat:@"%@&HomePageFourCell&footerView&id=%ld",self.fatherViewClassName,(long)self.model.id.integerValue];
        }else{
         footer.trackingId= [NSString stringWithFormat:@"%@&HomePageFourCell&footerView&id=%ld",[[RJAppManager sharedInstance]currentViewControllerName],(long)self.model.id.integerValue];
        }
   
        return footer;
    }
    return nil;
}
- (void)footerViewTapGesture:(UITapGestureRecognizer *)sender{
    [self bigImageTapGestureAction:sender];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH/320*114 +8 +8, SCREEN_WIDTH/320*114 +64 +8 +8);
}
-(void)prepareForReuse{
    [super prepareForReuse];
    [self.collectionView setContentOffset:CGPointZero];
}

- (void)bigImageTapGestureAction:(UITapGestureRecognizer *)gesture{
    /**
     *  统计上报
     */
    UIView *view = gesture.view;
    if (view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:view.trackingId];
    }
    
    
    NSString *paramValue = self.model.paramValue2;
    if (paramValue.length) {
        NSArray *arr1 = [paramValue componentsSeparatedByString:@"&"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        BOOL isBrand = NO;
        NSNumber *brandId;
        for (NSString *str in arr1) {
            //searchTerm=brands113
            NSArray *arr = [str componentsSeparatedByString:@"="];
            if (arr.count ==2) {
                [dic addEntriesFromDictionary:@{arr[0]:arr[1]}];
                NSString *str = arr[0];
                if ([str isEqualToString:@"brands"]) {
                    isBrand = YES;
                    brandId = arr[1];
                }
            }
        }
        if (isBrand) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(bigImageBrandTapedWithDic:brandId:)]) {
                [self.delegate bigImageBrandTapedWithDic:dic brandId:brandId];
            }
        }else{
            if (self.delegate) {
                [self.delegate bigImageTapedWithDic:dic];
            }
        
        }
        
        
     
        
       
    }

}
@end


@implementation HomeFourCollectionCell


-(void)awakeFromNib{
    [super awakeFromNib];
    
}
@end


@implementation HomeFourCollectionFooterView
- (void)awakeFromNib{
    [super awakeFromNib];
    self.bgView.layer.borderColor = [UIColor colorWithHexString:@"#efefef"].CGColor;
    self.bgView.layer.borderWidth = 1;

    
}


@end
