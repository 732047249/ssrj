//
//  CollectionsHeaderTableViewCell.m
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CollectionsHeaderTableViewCell.h"
#import "Masonry.h"
#import "ZanModel.h"
#import "GetToThemeViewController.h"
#import "GoodsDetailViewController.h"

@implementation CollectionsHeaderTableViewCell

- (void)setDataModel:(NowCollocationModel *)dataModel{
    _dataModel = dataModel;
    __weak __typeof(&*self)weakSelf = self;
    [self.colllectionImageView deleteAllTagView];
    [self.colllectionImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.picture] placeholderImage:GetImage(@"default_1x1") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            //status == 2 则是上传搭配。== 4 是在线创作， == 1 是pc端的搭配。
            if ([dataModel.status intValue] == 2) {
                [weakSelf.colllectionImageView addTagViewToPictureWithDraftString:dataModel.draft goodsList:dataModel.goodsList];
            }
            else if ([dataModel.status intValue] == 4) {
                [weakSelf.colllectionImageView addTagViewToCollocationWithDraftString:dataModel.draft goodsList:dataModel.goodsList];
            }
            else if ([dataModel.status intValue] == 1) {
                [weakSelf.colllectionImageView addTagViewToPCCollocationWithPositionArray:dataModel.collocationImages goodsList:dataModel.goodsList];
            }else {
                
            }
        }
    }];
    UIViewController *vc = [[RJAppManager sharedInstance] currentViewController];
    
    self.colllectionImageView.gotoGoodsDetailBlock = ^(NSString *goodsId) {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
        goodsDetaiVC.goodsId = [NSNumber numberWithInt:goodsId.intValue];
        goodsDetaiVC.fomeCollectionId = dataModel.nowCollectionId;
        [vc.navigationController pushViewController:goodsDetaiVC animated:YES];
    };
    
    self.collectionName.text = dataModel.name;
    self.collectionDescription.text = dataModel.memo;
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.avatar.mediumPath]];
    self.zanCountLabel.text = [dataModel.thumbsupCount stringValue];
    self.authorName.text = dataModel.autherName;
//    self.descriptionHeight.constant = [self heightWithContent:dataModel.memo andWidth:SCREEN_WIDTH-10*2];
    if (dataModel.thumbsup.integerValue == 1) {
        self.zanBtn.selected = YES;
        //10.5
        _dataModel.thumbsup = [NSNumber numberWithBool:YES];
    }else{
        self.zanBtn.selected = NO;
        //10.5
        _dataModel.thumbsup = [NSNumber numberWithBool:NO];
    }
    ///**搭配的状态   -1为删除状态，0为未发布， 1为发布状态  2 app上传发布 3 app暂存 4app创建发布**/
    
    /**
     *  统计ID
     */
    self.iconImageView.trackingId = [NSString stringWithFormat:@"%@&authorName&id=%@",self.parentClassName,dataModel.nowCollectionId];

}

- (void)setTagsFrames:(TagsFrames *)tagsFrames{
    self.tagsView.tagsFrames = tagsFrames;
    self.tagsViewHeight.constant = tagsFrames.tagsHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.iconImageView.layer.cornerRadius = 12;
    self.iconImageView.layer.borderWidth = 0.5;
    self.iconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.iconImageView.clipsToBounds = YES;
    self.headerBottomLineHeightConstraint.constant = 0.7;
    
//    self.zanBtn.selected = NO;
    
    /**
     *  点击用户头像去个人中心界面 添加Tap事件
     */
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    self.iconImageView.userInteractionEnabled = YES;
    self.authorName.userInteractionEnabled = YES;
    
    [self.iconImageView addGestureRecognizer:tapGest1];
    [self.authorName addGestureRecognizer:tapGest2];

}

#pragma mark -- headerView点击用户头像动作
- (void)TapUserViewAction:(UITapGestureRecognizer *)sender{
    [[RJAppManager sharedInstance] trackingWithTrackingId:self.iconImageView.trackingId];
    if (self.userDelegate && [self.userDelegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        if (sender.view.trackingId) {
            [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
        }
        [self.userDelegate didTapedUserViewWithUserId:self.dataModel.memberId userName:self.dataModel.autherName];
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (UIViewController *)viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

//- (IBAction)addToTheme:(id)sender {
//        if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
//            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
//            
//            [[self viewController]presentViewController:loginNav animated:YES completion:^{
//                
//            }];
//            return;
//        }
//    
//
//        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
//        
//        GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
//        
//        getToThemeVC.collectionID = self.dataModel.nowCollectionId;
////        getToThemeVC.delegate = [self viewController];
//    
//        [[self viewController].navigationController pushViewController:getToThemeVC animated:YES];
//    
////    [[self viewController] presentViewController:getToThemeVC animated:YES completion:nil];
//}

- (IBAction)clickZan:(UIButton *)sender {
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [[self viewController]presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    [self getNetData];
    if (self.zanBlock) {
        self.zanBlock(sender.selected);
        
    }
}

//调用点赞接口
- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb";
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"collocation" forKey:@"type"];
    if (self.dataModel.nowCollectionId) {
        [dict setObject:self.dataModel.nowCollectionId forKey:@"id"];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.getParams = dict;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            
            weakSelf.zanCountLabel.text = [NSString stringWithFormat:@"%d",[responseObject[@"data"][@"thumbCount"] intValue]];
            self.dataModel.thumbsup = [NSNumber numberWithBool:[responseObject[@"data"][@"thumb"] boolValue]];
            self.zanBtn.selected = [responseObject[@"data"][@"thumb"] boolValue];
            _dataModel.thumbsupCount = [NSNumber numberWithInt:[responseObject[@"data"][@"thumbCount"] intValue]];
            //设置代理刷新上级UI
            if ([_delegate respondsToSelector:@selector(letMeNotificateTheSuperVCToReloadData:)]) {
                [_delegate letMeNotificateTheSuperVCToReloadData:[responseObject[@"data"][@"thumb"] boolValue]];
            }
        }else {
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:responseObject[@"msg"] hideDelay:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
    }];
}


@end
