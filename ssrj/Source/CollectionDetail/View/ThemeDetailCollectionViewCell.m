//
//  ThemeDetailCollectionViewCell.m
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ThemeDetailCollectionViewCell.h"
#import "GoodsDetailViewController.h"

@implementation ThemeDetailCollectionViewCell
- (void)setCollocationList:(ThemeCollocationList *)collocationList{
    
    _collocationList = collocationList;
    
    __weak __typeof(&*self)weakSelf = self;
    [self.themeImageView deleteAllTagView];
    [self.themeImageView sd_setImageWithURL:[NSURL URLWithString:collocationList.picture] placeholderImage:GetImage(@"default_1x1") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            if ([collocationList.status integerValue] == 1) {
                if (collocationList.collocationImagesList && collocationList.collocationImagesList.count) {
                    
                    [weakSelf.themeImageView addTagViewToPCCollocationWithPositionArray:collocationList.collocationImagesList goodsList:collocationList.goodsList];
                }else {
                    [weakSelf.themeImageView addTagViewToPCCollocationWithPositionArray:collocationList.collocationImages goodsList:collocationList.goodsList];
                }
            }
            else if ([collocationList.status integerValue] == 2) {
                [weakSelf.themeImageView addTagViewToPictureWithDraftString:collocationList.draft goodsList:collocationList.goodsList];
            }
            else if  ([collocationList.status integerValue] == 4) {
                [weakSelf.themeImageView addTagViewToCollocationWithDraftString:collocationList.draft goodsList:collocationList.goodsList];
            } else {
                
            }
        }
    }];
    
    UIViewController *vc = [[RJAppManager sharedInstance] currentViewController];
    
    self.themeImageView.gotoGoodsDetailBlock = ^(NSString *goodsId) {
        if (goodsId.length && collocationList.collocationId.intValue) {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
            GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
            goodsDetaiVC.goodsId = [NSNumber numberWithInt:goodsId.intValue];
            goodsDetaiVC.fomeCollectionId = collocationList.collocationId;
            [vc.navigationController pushViewController:goodsDetaiVC animated:YES];
        }
    };
    self.themeTitle.text = collocationList.name;
    self.author.text = collocationList.userName;
    
    if (collocationList.isThumbsup) {
        [self.zanImageView setImage:[UIImage imageNamed:@"zan_icon_select"]];
    }else{
        [self.zanImageView setImage:[UIImage imageNamed:@"zan_icon"]];
    }
        
    [self.authorIcon sd_setImageWithURL:[NSURL URLWithString:collocationList.memberPO.avatar]];
    
    self.authorIcon.trackingId = [NSString stringWithFormat:@"%@&authorIcon&id=%@",NSStringFromClass(self.class),collocationList.collocationId];
    self.plusButton.trackingId = [NSString stringWithFormat:@"%@&plusButton&id=%@",NSStringFromClass(self.class),collocationList.collocationId];
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.authorIcon.layer.cornerRadius = 10.0f;
    self.authorIcon.clipsToBounds = YES;
   
    self.rightLineWidth.constant = 0.7;
    self.bottomLineHeight.constant = 0.7;
    
    /**
     *  点击用户头像去个人中心界面 添加Tap事件
     */
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    self.authorIcon.userInteractionEnabled = YES;
    self.author.userInteractionEnabled = YES;
    
    [self.authorIcon addGestureRecognizer:tapGest1];
    [self.author addGestureRecognizer:tapGest2];
    
}
- (void)TapUserViewAction:(UITapGestureRecognizer *)sender{
    
    if (self.userDelegate && [self.userDelegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [[RJAppManager sharedInstance] trackingWithTrackingId:self.authorIcon.trackingId];
        [self.userDelegate didTapedUserViewWithUserId:self.collocationList.memberPO.memberId userName:self.collocationList.memberPO.name];
    }
    if (sender.view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
    }
}
@end
