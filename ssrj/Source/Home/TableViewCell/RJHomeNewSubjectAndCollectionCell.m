
#import "RJHomeNewSubjectAndCollectionCell.h"
#import "RJHomeNewSubjectCollectionViewCell.h"

@interface RJHomeNewSubjectAndCollectionCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (nonatomic,strong)  UIVisualEffectView *effectView;
@end

@implementation RJHomeNewSubjectAndCollectionCell

- (void)awakeFromNib{
    
    [super awakeFromNib];
    self.bigImageFatherView.layer.borderColor = [UIColor colorWithHexString:@"#e6e6e6"].CGColor;
//    self.bigImageFatherView.layer.borderColor = [UIColor redColor].CGColor;
    self.bigImageFatherView.layer.borderWidth = .7;
    
    self.smallImageView.layer.borderColor = [UIColor colorWithHexString:@"#e6e6e6"].CGColor;
    self.smallImageView.layer.borderWidth = .7;
    
    self.effectView = [[UIVisualEffectView alloc]initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    self.collectionView.backgroundView = self.effectView;
    self.effectView.frame = self.collectionView.bounds;
    self.effectView.alpha = 0;
    self.collectionView.scrollsToTop = NO;
    
    /**
     *  点击用户头像去个人中心界面 添加Tap事件
     */
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapBigUserViewAction:)];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapBigUserViewAction:)];
    self.avatarImageView.userInteractionEnabled = YES;
    self.authorNameLabel.userInteractionEnabled = YES;
    
    [self.avatarImageView addGestureRecognizer:tapGest1];
    [self.authorNameLabel addGestureRecognizer:tapGest2];
}
- (void)prepareForReuse{
    [super prepareForReuse];
    [self.collectionView setContentOffset:CGPointZero];
    self.effectView.alpha = 0;
}
- (void)setModel:(RJHomeItemTypeFourModel *)model{
    if (_model != model) {
        _model = model;
        self.subjectDescLabel.text = model.memo;
        self.subjectTitleLabel.text = model.name;
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.member.avatar] placeholderImage:GetImage(@"default_1x1")];
        self.authorNameLabel.text = model.member.name;
      
        self.collectionButton.titleLabel.text = [NSString stringWithFormat:@"%d个搭配",model.collocationCount.intValue];
        self.dataArray = [NSMutableArray arrayWithArray:[model.collocationList copy]];
        [self.collectionView reloadData];
        [self.bigImageView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:GetImage(@"default_1x1")];
        RJHomeTypeFourCollectionModel *itemModel = model.collocationList.firstObject;
        
        [self.smallImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.path] placeholderImage:GetImage(@"default_1x1")];
        
        /**
         *  统计ID
         */
        NSString *str = [[RJAppManager sharedInstance]currentViewControllerName];
        if (self.fatherViewControllerName.length) {
            str = self.fatherViewControllerName;
        }
        self.avatarImageView.trackingId = [NSString stringWithFormat:@"%@&%@&AvatarImageView&id=%@",str,NSStringFromClass(self.class),model.member.id.stringValue];
        self.likeButton.trackingId = [NSString stringWithFormat:@"%@&%@&likeButton&id=%@",str,NSStringFromClass(self.class),model.id.stringValue];
        self.bigButton.trackingId = [NSString stringWithFormat:@"%@&%@&BigButton&id=%@",str,NSStringFromClass(self.class),model.id.stringValue];
        

    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RJHomeNewSubjectCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RJHomeNewSubjectCollectionViewCell" forIndexPath:indexPath];
    RJHomeTypeFourCollectionModel *model = self.dataArray[indexPath.row];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:GetImage(@"default_1x1")];
    
    /**
     *  统计ID
     */
    
    if (self.fatherViewControllerName.length) {
        cell.trackingId = [NSString stringWithFormat:@"%@%@&SmallDapeiCell&id=%d",self.fatherViewControllerName,NSStringFromClass([self class]),model.id.intValue];
        cell.userView.trackingId = [NSString stringWithFormat:@"%@%@&userView&id=%d",self.fatherViewControllerName,NSStringFromClass([self class]),model.id.intValue];
    }else {
        cell.trackingId = [NSString stringWithFormat:@"%@%@&SmallDapeiCell&id=%d",[[RJAppManager sharedInstance]currentViewControllerName],NSStringFromClass([self class]),model.id.intValue];
        cell.userView.trackingId = [NSString stringWithFormat:@"%@%@&userView&id=%d",[[RJAppManager sharedInstance]currentViewControllerName],NSStringFromClass([self class]),model.id.intValue];
    }

    cell.authorNameLabel.text = model.memberPO.name;
    [cell.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.memberPO.avatar] placeholderImage:GetImage(@"default_1x1")];
    cell.titleNameLabel.text = model.name;
    cell.userView.tag = indexPath.row;
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    [cell.userView addGestureRecognizer:tapGest];
    
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    CGFloat collHei = SCREEN_WIDTH/4 *3;
//    CGFloat cellHei = collHei - 40;
//    return CGSizeMake(cellHei - 66, cellHei);
    return CGSizeMake(150 *SCREEN_WIDTH/320, 150 *SCREEN_WIDTH/320 +51);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        RJHomeNewSubjectCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RJHomeNewSubjectCollectionHeaderView" forIndexPath:indexPath];
        [headerView.countButton addTarget:self action:@selector(countButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.fatherViewControllerName.length) {
            headerView.countButton.trackingId = [NSString stringWithFormat:@"%@%@&dapei&countButton&id=%d",self.fatherViewControllerName,NSStringFromClass([self class]),self.model.id.intValue];
        }else {
            headerView.countButton.trackingId = [NSString stringWithFormat:@"%@%@&dapei&countButton&id=%d",[[RJAppManager sharedInstance]currentViewControllerName],NSStringFromClass([self class]),self.model.id.intValue];
        }

        if (self.model) {
            headerView.countButton.titleLabel.text = [NSString stringWithFormat:@"%d",self.model.collocationCount.intValue];
        }
        return headerView;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        RJHomeNewSubjectCollectionFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RJHomeNewSubjectCollectionFooterView" forIndexPath:indexPath];
        return footerView;
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGFloat collHei = SCREEN_WIDTH/4 *3;

    return CGSizeMake(collHei + 90, collHei);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGFloat collHei = SCREEN_WIDTH/4 *3;
    
    return CGSizeMake(130, collHei);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    RJHomeTypeFourCollectionModel *model = self.dataArray[indexPath.row];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionSelectWithId:)]) {
        [self.delegate collectionSelectWithId:model.id];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat xx = scrollView.contentOffset.x / 200.00 <1 ?scrollView.contentOffset.x / 200.00:1;
    self.effectView.alpha = xx;
}
- (void)countButtonAction:(CCButton *)sender{
    if (self.dataArray) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}
- (void)TapUserViewAction:(UITapGestureRecognizer *)sender{
    NSInteger tag = sender.view.tag;
    
    [[RJAppManager sharedInstance]trackingWithTrackingId:self.avatarImageView.trackingId];
    RJHomeTypeFourCollectionModel *model = self.dataArray[tag];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
        [self.delegate didTapedUserViewWithUserId:model.memberPO.id userName:model.memberPO.name];
    }
}
- (void)TapBigUserViewAction:(UITapGestureRecognizer *)sender{
    UIView *view = sender.view;
    if (view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:view.trackingId];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [self.delegate didTapedUserViewWithUserId:self.model.member.id userName:self.model.member.name];
    }
}
@end
