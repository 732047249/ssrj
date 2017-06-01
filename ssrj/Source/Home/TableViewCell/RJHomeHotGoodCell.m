
#import "RJHomeHotGoodCell.h"
#import "HomeGoodListCollectionViewCell.h"
#import "RJHomeHotGoodModel.h"
#import "GoodsDetailViewController.h"
#import "HomeGoodListViewController.h"
@interface RJHomeHotGoodCell ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,HomeGoodListCollectionViewCellDelegate>
@end

@implementation RJHomeHotGoodCell
- (void)awakeFromNib{
    [super awakeFromNib];
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    self.collectionView.scrollsToTop = NO;
}
- (void)prepareForReuse{
    [super prepareForReuse];
}
- (void)setModel:(RJHomeHotGoodModel *)model{

    _model = model;
    self.dataArray = [NSMutableArray arrayWithArray:[model.goodsList mutableCopy]];
    [self.collectionView reloadData];
    
    NSString *vcName = [[RJAppManager sharedInstance] currentViewControllerName];
    self.topButton.trackingId = [NSString stringWithFormat:@"%@&RJHomeHotGoodCell&topButton&id=%@",vcName,model.id];

}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeGoodListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell2" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    /**
     *  统计ID
     */
    
    NSString *str = [[RJAppManager sharedInstance]currentViewControllerName];
    cell.trackingId = [NSString stringWithFormat:@"%@&%@&id:%@",str,NSStringFromClass([self class]),model.goodId];
    
    cell.model = model;
    cell.contentView.tag = indexPath.row;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    //li
    cell.zanImageView.highlighted = model.isThumbsup.boolValue;
    cell.likeButton.selected = model.isThumbsup.boolValue;
    cell.likeButton.trackingId = [NSString stringWithFormat:@"%@&%@&likeButton&id:%@",str,NSStringFromClass([self class]),model.goodId];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
    CGFloat height = imageWid + 10 +15 + 69;
    return CGSizeMake(imageWid+10+10, height);
}

- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    RJBaseGoodModel *model = self.dataArray[tag];
    NSNumber *goodId = (NSNumber *)model.goodId;
    /**
     *  统计上报
     */
    NSString *trackingId = [NSString stringWithFormat:@"%@&%@&id:%@",[[RJAppManager sharedInstance]currentViewControllerName],NSStringFromClass([self class]),model.goodId];
    [[RJAppManager sharedInstance]trackingWithTrackingId:trackingId];
    
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = goodId;
    
    goodsDetaiVC.zanBlock = ^(NSInteger buttonState){
        RJBaseGoodModel *model = self.dataArray[tag];
        model.isThumbsup = [NSNumber numberWithInteger:buttonState];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];
    };
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = @"HomeViewController";
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1020];
//    statisticalDataModel.entranceTypeId = goodId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    
    [[[RJAppManager sharedInstance]currentViewController].navigationController pushViewController:goodsDetaiVC animated:YES];
//    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
- (void)likeButtonAction:(UIButton *)sender{
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [[[RJAppManager sharedInstance]currentViewController].navigationController presentViewController:loginNav animated:YES completion:^{
            
        }];
        
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=goods"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    RJBaseGoodModel *model = self.dataArray[sender.tag];
    
    if (model.goodId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.goodId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumb = [responseObject[@"data"] objectForKey:@"thumb"];
                
                sender.selected = thumb.boolValue;
                
                model.isThumbsup = thumb;
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]]];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.contentView withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.contentView withString:responseObject[@"msg"]  hideDelay:1];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.contentView withString:@"Error" hideDelay:1];
        
    }];
    

}
- (IBAction)topButtonAction:(id)sender {
    NSDictionary *dic = @{@"upTime":@"new"};
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    HomeGoodListViewController *goodListVc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
    goodListVc.parameterDictionary = [dic copy];

    goodListVc.titleStr = @"新品";
    [[[RJAppManager sharedInstance]currentViewController].navigationController pushViewController:goodListVc animated:YES];
}

@end
