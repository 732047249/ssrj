
#import "RJNewSubjectAndCollectionWithCommentCell.h"
#import "RJHomeNewSubjectCollectionViewCell.h"
#import "NSAttributedString+YYText.h"
@interface RJNewSubjectAndCollectionWithCommentCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (nonatomic,strong)  UIVisualEffectView *effectView;
@end

@implementation RJNewSubjectAndCollectionWithCommentCell
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
    
    self.unPublishLabel.layer.cornerRadius = 3;
    self.unPublishLabel.layer.masksToBounds = YES;
    
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
    self.commentSuperView.hidden = NO;
    self.commentViewTwo.hidden = NO;
    self.commentViewThree.hidden = NO;
    self.commentViewOne.hidden = NO;
}
- (void)setModel:(RJHomeItemTypeFourModel *)model{

    _model = model;
//    model.memo = @"倒垃圾垃圾的离开就立刻到件莱卡江山路到家啦涉及到垃圾上来看到家了卡萨塑料科技的来看撒娇来得快撒娇了肯德基萨拉可敬的来看撒娇的来看撒娇了建档立卡涉及到立刻就撒了肯德基三的健康垃圾堆拉卡拉刷卡机的卢卡斯就立刻";
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
    
    
    self.commentThreeHeiConstraint.constant = model.commentThreeHeight.intValue;
    self.commentOneHeiConstraint.constant =  model.commentOneHeight.intValue;
    self.commentTwoHeiConstraint.constant = model.commentTwoHeight.intValue;
    self.commentSuperViewHeiConstraint.constant = model.commentHeight.intValue;
    
    if (!model.comment||model.comment.countComment.intValue == 0) {
        self.commentSuperView.hidden = YES;
    }else{
        self.commentSuperView.hidden = NO;
        self.commentCountLabel.text = model.comment.countComment.stringValue;
        for (int i=0; i<model.comment.commentList.count; i ++) {
            RJCommentModel *itemModel = model.comment.commentList[i];
            if (i==0) {
                self.commentViewOne.itemModel = itemModel;
            }
            if (i == 1) {
                self.commentViewTwo.itemModel = itemModel;

            }
            if (i == 2) {
                self.commentViewThree.itemModel = itemModel;
            }
        }
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
    
    NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
    if (self.fatherViewControllerName.length) {
        vcName = self.fatherViewControllerName;
    }
    
    if (kind == UICollectionElementKindSectionHeader) {
        RJHomeNewSubjectCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RJHomeNewSubjectCollectionHeaderView" forIndexPath:indexPath];
        [headerView.countButton addTarget:self action:@selector(countButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.model) {
            headerView.countButton.titleLabel.text = [NSString stringWithFormat:@"%d",self.model.collocationCount.intValue];
            headerView.countButton.trackingId = [NSString stringWithFormat:@"%@&RJNewSubjectAndCollectionWithCommentCell&id=%@",vcName,self.model.themeItemId];
        }
        return headerView;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        RJHomeNewSubjectCollectionFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RJHomeNewSubjectCollectionFooterView" forIndexPath:indexPath];
        footerView.trackingId = [NSString stringWithFormat:@"%@&RJNewSubjectAndCollectionWithCommentCell&id=%@",vcName,self.model.themeItemId];
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
    if (self.dataArray.count) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}
- (void)TapUserViewAction:(UITapGestureRecognizer *)sender{
    NSInteger tag = sender.view.tag;
    RJHomeTypeFourCollectionModel *model = self.dataArray[tag];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [self.delegate didTapedUserViewWithUserId:model.memberPO.id userName:model.memberPO.name];
    }
    if (sender.view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
    }
    
}
- (void)TapBigUserViewAction:(UITapGestureRecognizer *)sender{
    [[RJAppManager sharedInstance] trackingWithTrackingId:self.avatarImageView.trackingId];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [self.delegate didTapedUserViewWithUserId:self.model.member.id userName:self.model.member.name];
    }
    if (sender.view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
    }
}

@end





@implementation RJNewSubjectAndCollectionCommentView
- (void)awakeFromNib{
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userTapAction:)];
    [self.avatorImageView addGestureRecognizer:tapGesture];
    self.avatorImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userTapAction:)];
    [self.nameLable addGestureRecognizer:tapGesture2];
    self.nameLable.userInteractionEnabled = YES;
    
    
    self.avatorImageView.layer.cornerRadius = self.avatorImageView.width/2;
    self.avatorImageView.clipsToBounds = YES;
    
    self.commentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 60;
    
    self.commentLabel.font = GetFont(15);
}
- (void)userTapAction:(UITapGestureRecognizer *)sender{
    if (self.itemModel.member.memberId) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
        RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
        rootVc.userId = self.itemModel.member.memberId;
        rootVc.userName = @"";
        UIViewController *vc =[[RJAppManager sharedInstance]currentViewController];
        [vc.navigationController pushViewController:rootVc animated:YES];
    }
}
- (void)setItemModel:(RJCommentModel *)itemModel{
    _itemModel = itemModel;
    [self setYYLabelAttributeString:itemModel.attributeText];
    [self.commentLabel updateConstraints];
    [self.avatorImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.member.avatar] placeholderImage:GetImage(@"default_1x1")];
    self.dateLabel.text = itemModel.createDate;
    self.nameLable.text = itemModel.member.name;
}
- (void)setYYLabelAttributeString:(NSAttributedString *)text{
    self.commentLabel.attributedText = text;
    self.commentLabel.highlightTapAction  = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
        if ([containerView isKindOfClass:[YYLabel class]]) {
            YYLabel *label =(YYLabel *)containerView;
            NSAttributedString *text2 =label.attributedText;
            YYTextHighlight *highlight = [text2 yy_attribute:YYTextHighlightAttributeName atIndex:range.location];
//            NSLog(@"%@",highlight.userInfo);
            
            NSNumber *userId = highlight.userInfo[@"memberId"];
            if (!userId) {
                return;
            }
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
            RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
            rootVc.userId = userId;
            rootVc.userName = @"";
            UIViewController *vc =[[RJAppManager sharedInstance]currentViewController];
            [vc.navigationController pushViewController:rootVc animated:YES];
        }
    };
}


@end
