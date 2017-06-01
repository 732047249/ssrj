
#import "RJHomeCollectionAndGoodAndCommentCell.h"
#import "RecommendCollectionsModel.h"
#import "GoodsDetailViewController.h"

@interface RJHomeCollectionAndGoodAndCommentCell ()
@property (weak, nonatomic) IBOutlet UIView *goodViewOne;
@property (weak, nonatomic) IBOutlet UIView *goodViewTwo;
@end

@implementation RJHomeCollectionAndGoodAndCommentCell
- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.goodOneBrandLabel.text = @"";
    self.goodOneNameLabel.text = @"";
    self.goodOneMarkPriceLabel.text = @"";
    self.goodOneCurrentPriceLabel.text = @"";
    self.goodOneSpecialImageView.hidden = YES;
    
    self.goodTwoBrandLabel.text = @"";
    self.goodTwoNameLabel.text = @"";
    self.goodTwoMarkPriceLabel.text = @"";
    self.goodTwoCurrentPriceLabel.text = @"";
    self.goodTwoSpecialImageView.hidden = YES;
    
    UITapGestureRecognizer *tapGes1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureOneAction:)];
    UITapGestureRecognizer *tapGes2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureTwoAction:)];
    
    
    [self.goodViewOne addGestureRecognizer:tapGes1];
    [self.goodViewTwo addGestureRecognizer:tapGes2];
    
    /**
     *  点击用户头像去个人中心界面 添加Tap事件
     */
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    self.avatorImageView.userInteractionEnabled = YES;
    self.authorNameLabel.userInteractionEnabled = YES;
    
    [self.avatorImageView addGestureRecognizer:tapGest1];
    [self.authorNameLabel addGestureRecognizer:tapGest2];
    
    self.topLineHeightConstraint.constant = 0.7;
    self.middleLongLineWidthConstraint.constant = 0.35;
    self.middelShortLineHeightConstraint.constant = 0.7;
    self.bottomLineHeightConstraint.constant = 0.35;
    self.bottomShortLineHeightConstraint.constant = 0.35;
    
}
- (void)TapUserViewAction:(id)sender{
    [[RJAppManager sharedInstance] trackingWithTrackingId:self.avatorImageView.trackingId];;
    if (self.userDelegate && [self.userDelegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [self.userDelegate didTapedUserViewWithUserId:self.model.member.id userName:self.model.member.name];
    }
}
- (void)tapGestureOneAction:(UITapGestureRecognizer *)sender{
    if (self.model.goodsList.count>=1) {
        if (sender.view.trackingId) {
            [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
        }
        RJBaseGoodModel *model = [self.model.goodsList firstObject];
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionTapedWithGoodId:fromCollectionId:)]) {
            [self.delegate collectionTapedWithGoodId:model.goodId fromCollectionId:self.model.id];
        }
        //        [self.delegate collectionTapedWithGoodId:model.goodId];
    }
}
- (void)tapGestureTwoAction:(UITapGestureRecognizer *)sender{
    if (self.model.goodsList.count>=2) {
        RJBaseGoodModel *model = self.model.goodsList[1] ;
        if (sender.view.trackingId) {
            [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
        }
        //        [self.delegate collectionTapedWithGoodId:model.goodId];
        if (self.delegate && [self.delegate respondsToSelector:@selector(collectionTapedWithGoodId:fromCollectionId:)]) {
            [self.delegate collectionTapedWithGoodId:model.goodId fromCollectionId:self.model.id];
        }
    }
    
}
- (void)prepareForReuse{
    [super prepareForReuse];
    self.goodOneBrandLabel.text = @"";
    self.goodOneNameLabel.text = @"";
    self.goodOneMarkPriceLabel.text = @"";
    self.goodOneCurrentPriceLabel.text = @"";
    self.goodOneSpecialImageView.hidden = YES;
    self.goodOneImageView.image = nil;
    
    self.goodTwoBrandLabel.text = @"";
    self.goodTwoNameLabel.text = @"";
    self.goodTwoMarkPriceLabel.text = @"";
    self.goodTwoCurrentPriceLabel.text = @"";
    self.goodTwoSpecialImageView.hidden = YES;
    self.goodTwoImageView.image = nil;
    self.tagHeightConstraint.constant = 38;
}
- (void)setModel:(RJHomeItemTypeTwoModel *)model{
    _model = model;
    self.tagHeightConstraint.constant = 38;
    if (!model.themeTagList.count) {
        self.tagHeightConstraint.constant = 0;
    }
    __weak __typeof(&*self)weakSelf = self;
    [self.collectionImageView deleteAllTagView];
    [self.collectionImageView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:GetImage(@"default_1x1") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            NSArray *goodList = model.goodsList;
            //个人中心-发布页面，goodlist返回的最多三个。不符合要求，文敬增加了goodinfo字段。
            if (model.goodsInfo && model.goodsInfo.count > 0) {
                goodList = model.goodsInfo;
            }
            if ([model.status integerValue] == 1) {
                [weakSelf.collectionImageView addTagViewToPCCollocationWithPositionArray:model.collocationImages goodsList:goodList];
            }
            else if ([model.status integerValue] == 2) {
                [weakSelf.collectionImageView addTagViewToPictureWithDraftString:model.draft goodsList:goodList];
            }
            else if  ([model.status integerValue] == 4) {
                [weakSelf.collectionImageView addTagViewToCollocationWithDraftString:model.draft goodsList:goodList];
            } else {
                
            }
        }
    }];
    
    UIViewController *vc = [[RJAppManager sharedInstance] currentViewController];
    
    self.collectionImageView.gotoGoodsDetailBlock = ^(NSString *goodsId) {
        if (goodsId.length && model.id.intValue) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
            GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
            goodsDetaiVC.goodsId = [NSNumber numberWithInt:goodsId.intValue];
            goodsDetaiVC.fomeCollectionId = model.id;
            [vc.navigationController pushViewController:goodsDetaiVC animated:YES];
        }
    };
    
    self.collectionTitleLabel.text = model.name;
    self.collectionDesLabel.text = model.memo;
    self.authorNameLabel.text = model.member.name;
    [self.avatorImageView sd_setImageWithURL:[NSURL URLWithString:model.member.avatar] placeholderImage:GetImage(@"default_1x1")];
    
    /**
     *  统计ID
     */
    NSString *vcName = [[RJAppManager sharedInstance]currentViewControllerName];
    if (self.fatherViewControllerName.length) {
        vcName = self.fatherViewControllerName;
    }
    self.avatorImageView.trackingId = [NSString stringWithFormat:@"%@&%@&avatorImageView&id=%@",vcName,NSStringFromClass(self.class),model.id.stringValue];
    self.topViewButton.trackingId = [NSString stringWithFormat:@"%@&%@&topViewButton&id=%@",vcName,NSStringFromClass(self.class),model.id.stringValue];
    
    self.putIntoThemeButton.trackingId = [NSString stringWithFormat:@"%@&%@&putIntoThemeButton&id=%@",vcName,NSStringFromClass(self.class),model.id.stringValue];
    self.likeButton.trackingId = [NSString stringWithFormat:@"%@&%@&likeButton&id=%@",vcName,NSStringFromClass(self.class),model.id.stringValue];
    
    NSArray *dataArr = model.goodsList;
    if (dataArr.count >= 1) {
        RJBaseGoodModel *model = [dataArr firstObject];
        [self.goodOneImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
        self.goodOneNameLabel.text = model.name;
        self.goodOneBrandLabel.text = model.brandName;
        self.goodOneCurrentPriceLabel.text = [NSString stringWithFormat:@"¥%@",model.effectivePrice];
        self.goodOneMarkPriceLabel.attributedText = [NSString effectivePriceWithString:model.marketPrice];
        
        self.goodOneCurrentPriceLabel.textColor = [UIColor blackColor];
        
        self.goodOneSpecialImageView.hidden = YES;
        if (model.isNewProduct.boolValue) {
            self.goodOneSpecialImageView.hidden = NO;
            self.goodOneSpecialImageView.image = GetImage(@"xinping_right");
        }
        
        if (model.isSpecialPrice.boolValue) {
            self.goodOneCurrentPriceLabel.textColor = [UIColor colorWithHexString:@"#F63649"];
            self.goodOneSpecialImageView.hidden = NO;
            self.goodOneSpecialImageView.image = GetImage(@"tejia_right");
        }
        self.goodViewOne.trackingId = [NSString stringWithFormat:@"%@&RJHomeCollectionAndGoodAndCommentCell&goodViewOne&id=%@",vcName,model.goodId];
        if (dataArr.count>=2) {
            RJBaseGoodModel *model = dataArr[1];
            [self.goodTwoImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
            self.goodTwoNameLabel.text = model.name;
            self.goodTwoBrandLabel.text = model.brandName;
            self.goodTwoCurrentPriceLabel.text = [NSString stringWithFormat:@"¥%@",model.effectivePrice];
            self.goodTwoMarkPriceLabel.attributedText = [NSString effectivePriceWithString:model.marketPrice];
            
            self.goodTwoCurrentPriceLabel.textColor = [UIColor blackColor];
            
            self.goodTwoSpecialImageView.hidden = YES;
            if (model.isNewProduct.boolValue) {
                self.goodTwoSpecialImageView.hidden = NO;
                self.goodTwoSpecialImageView.image = GetImage(@"xinping_right");
            }
            
            if (model.isSpecialPrice.boolValue) {
                self.goodTwoCurrentPriceLabel.textColor = [UIColor colorWithHexString:@"#F63649"];
                self.goodTwoSpecialImageView.hidden = NO;
                self.goodTwoSpecialImageView.image = GetImage(@"tejia_right");
            }
            self.goodViewTwo.trackingId = [NSString stringWithFormat:@"%@&RJHomeCollectionAndGoodAndCommentCell&goodViewTwo&id=%@",vcName,model.goodId];
        }
    }
    
    /**
     *  2.2.0 新增Tags
     */
    for (UIButton * button in self.tagsView.subviews) {
        if ([button isKindOfClass:[UIButton class]]) {
            [button removeFromSuperview];
        }
    }
    
    CGFloat XPoint = 10;
    UIFont *textFont = GetFont(12);
    UIColor *textColor = APP_BASIC_COLOR2;
    
    UIColor *bgColor = [UIColor colorWithHexString:@"#f2f2f2"];
    //Tag 之间间距
    CGFloat minPadding = 10;
    CGFloat tagsMargin = 10;
    CGFloat btnW = 0;
    
    CGFloat btnX = XPoint;
    
    
    for (int i = 0; i<self.model.themeTagList.count; i++) {
        ThemeItemListModel *itemModel = self.model.themeTagList[i];
        NSString *name = itemModel.name;
        btnW  = [self sizeWithTitle:name font:textFont].width + minPadding *2;
        UIButton *button = [UIButton buttonWithType:0];
        button.trackingId = [NSString stringWithFormat:@"%@&RJHomeCollectionAndGoodAndCommentCell&tagButton&id=%@",vcName,itemModel.themeItemId];
        [button setTitle:name forState:0];
        button.titleLabel.font = textFont;
        [button setTitleColor:textColor forState:0];
        [button setBackgroundColor:bgColor];
        button.layer.cornerRadius = 15;
        button.clipsToBounds = YES;
        
        [button sizeToFit];
        [self.tagsView addSubview:button];
        
        [button addTarget:self action:@selector(tagsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.frame = CGRectMake(btnX, 5, btnW, button.height);
        button.tag = itemModel.themeItemId.integerValue;
        CGFloat nextWidth = 0;
        if (i < self.model.themeTagList.count - 1) {
            ThemeItemListModel *nextModel = self.model.themeTagList[i +1];
            nextWidth = [self sizeWithTitle:nextModel.name font:textFont].width + minPadding *2;
        }
        CGFloat nextBtnX = btnX +btnW +tagsMargin;
        if ((nextWidth +nextBtnX) > (SCREEN_WIDTH - tagsMargin)){
            break;
        }else{
            btnX += (btnW + tagsMargin);
        }
    }
    
    /**
     *  3.3.0 评论
     */
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
- (CGSize)sizeWithTitle:(NSString *)title font:(UIFont *)font{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [title sizeWithAttributes:attrs];
}
- (void)tagsButtonAction:(UIButton *)sender{
    NSInteger tag = sender.tag;
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionTapedWithTagId:)]) {
        [self.delegate collectionTapedWithTagId:[NSString stringWithFormat:@"%ld",(long)tag]];
    }
}


@end
