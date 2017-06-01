//
//  RecommendCollectionsTableViewCell.m
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RecommendCollectionsTableViewCell.h"
#import "CollectionsViewController.h"
#import "ZanModel.h"
#import "GetToThemeViewController.h"
#import "CollectionsHeaderTableViewCell.h"
#import "GoodsDetailViewController.h"

@interface RecommendCollectionsTableViewCell()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation RecommendCollectionsTableViewCell

- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
//    self.recommendCollectionsColView.frame = CGRectMake(0, 30, SCREEN_WIDTH, (dataArray.count+1)/2*(22 + SCREEN_WIDTH/320 *140 + 10 + 63));
//    [self.recommendCollectionsColView reloadData];
}

- (UIViewController *)viewController{
    for (UIView *nextView = [self superview]; nextView;nextView = [nextView superview]) {
        UIResponder *nextResponser = [nextView nextResponder];
        if ([nextResponser isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponser;
        }
    }
    return nil;
}


- (void)awakeFromNib {

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];


}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RecommendCollectionsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommendCollectionsCollectionViewCell" forIndexPath:indexPath];
    cell.dataModel = self.dataArray[indexPath.row];
    cell.authorIcon.tag = indexPath.row;
    cell.recommendCollectionAuthor.tag = indexPath.row;

    /**
     *  统计ID
     */
    CollocationsItem *model = self.dataArray[indexPath.row];
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH/320*160 ,22 + SCREEN_WIDTH/320 *140 + 10 + 63);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    CollocationsItem *model = self.dataArray[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = model.collocationId;
    /**
     *  逻辑更正 后台返回数据 在回调block
     */
    collectionViewController.zanBlock = ^(NSInteger buttonState){
        CollocationsItem *model= self.dataArray[indexPath.row];
        model.thumbsup = [NSNumber numberWithInteger:buttonState];
        [self.recommendCollectionsColView reloadItemsAtIndexPaths:@[indexPath]];
    };
    //记录点击的cell的indexPath,用于下级UI返回时刷新该cell
    self.indexPath = indexPath;
    
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = @"CollectionsViewController";
//    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//    statisticalDataModel.entranceType = _collectionID;
//    statisticalDataModel.entranceTypeId = model.collocationId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.viewController.navigationController pushViewController:collectionViewController animated:YES];
}


@end


#pragma -@implementation RecommendCollectionsCollectionViewCell
@implementation RecommendCollectionsCollectionViewCell

- (UIViewController *)viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.authorIcon.layer.cornerRadius = 14;
    self.authorIcon.layer.masksToBounds = YES;
    self.authorIcon.layer.borderWidth = 0.5;
    self.authorIcon.layer.borderColor = [UIColor colorWithHexString:@"ffffff"].CGColor;
    self.rightLineWidthConstraint.constant = 0.7;
    self.bottomLineHeightConstraint.constant = 0.7;
    
}

- (void)setDataModel:(CollocationsItem *)dataModel{
    if (_dataModel != dataModel) {
        _dataModel = dataModel;

        [self.recommendCollectionsImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.picture] placeholderImage:GetImage(@"default_1x1")];
        __weak __typeof(&*self)weakSelf = self;
        [self.recommendCollectionsImageView deleteAllTagView];
        [self.recommendCollectionsImageView sd_setImageWithURL:[NSURL URLWithString:dataModel.picture] placeholderImage:GetImage(@"default_1x1") completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (!error) {
                if ([dataModel.status integerValue] == 1) {
                    [weakSelf.recommendCollectionsImageView addTagViewToPCCollocationWithPositionArray:dataModel.collocationImages goodsList:dataModel.goodsList];
                }
                else if ([dataModel.status integerValue] == 2) {
                    [weakSelf.recommendCollectionsImageView addTagViewToPictureWithDraftString:dataModel.draft goodsList:dataModel.goodsList];
                }
                else if  ([dataModel.status integerValue] == 4) {
                    [weakSelf.recommendCollectionsImageView addTagViewToCollocationWithDraftString:dataModel.draft goodsList:dataModel.goodsList];
                } else {
                    
                }
            }
        }];
        
        UIViewController *vc = [[RJAppManager sharedInstance] currentViewController];
        
        self.recommendCollectionsImageView.gotoGoodsDetailBlock = ^(NSString *goodsId) {
            if (goodsId.length && dataModel.collocationId.intValue) {
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
                GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
                goodsDetaiVC.goodsId = [NSNumber numberWithInt:goodsId.intValue];
                goodsDetaiVC.fomeCollectionId = dataModel.collocationId;
                [vc.navigationController pushViewController:goodsDetaiVC animated:YES];
            }
        };
        
        self.recommendCollectionsName.text = dataModel.name;
        self.recommendCollectionAuthor.text = dataModel.autherName;
        [self.authorIcon sd_setImageWithURL:[NSURL URLWithString:dataModel.member.avatar] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
        if (dataModel.thumbsup.integerValue == 1) {
            self.zanBtn.selected = YES;
        }else{
            self.zanBtn.selected = NO;
        }
        
        /**
         *  点击用户头像去个人中心界面 添加Tap事件
         */
        UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
        UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
        self.authorIcon.userInteractionEnabled = YES;
        self.recommendCollectionAuthor.userInteractionEnabled = YES;
        
        [self.authorIcon addGestureRecognizer:tapGest1];
        [self.recommendCollectionAuthor addGestureRecognizer:tapGest2];
        
    }

}

#pragma mark -- collectionView Cell 点击用户头像手势动作
- (void)TapUserViewAction:(id)sender{

    
//    if (self.userDelegate && [self.userDelegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
//        [self.userDelegate didTapedUserViewWithUserId:self.dataModel.memberId userName:self.dataModel.autherName];
//    }
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    
    if (!self.dataModel.member.memberId) {
        
        return;
    }
    rootVc.userId = self.dataModel.member.memberId;
    rootVc.userName = self.dataModel.member.name;
    
    [[self viewController].navigationController pushViewController:rootVc animated:YES];
    
}

- (IBAction)zan:(id)sender {
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [[self viewController]presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    [self getNetData];
    
}

//调用点赞接口
- (void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"/b82/api/v5/thumb?type=collocation";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.dataModel.collocationId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.dataModel.collocationId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {

                //NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                weakSelf.zanBtn.selected = thumb;
                
                //10.5
                weakSelf.dataModel.thumbsup = [NSNumber numberWithBool:thumb];

            }
            else if (state.intValue == 1){
              
                [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:responseObject[@"msg"] hideDelay:1];
                
            }
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:[error localizedDescription] hideDelay:1];
        
    }];
}


- (IBAction)addToTheme:(id)sender {
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [[self viewController]presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC.collectionID = self.dataModel.collocationId;
    
    
    [[self viewController].navigationController pushViewController:getToThemeVC animated:YES];
    
//    [[self viewController] presentViewController:getToThemeVC animated:YES completion:nil];
}
@end
