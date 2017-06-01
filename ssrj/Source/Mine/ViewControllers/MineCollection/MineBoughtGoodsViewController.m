//
//  MineBoughtGoodsViewController.m
//  ssrj
//
//  Created by YiDarren on 16/8/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MineBoughtGoodsViewController.h"
#import "MineBoughtGoodsModel.h"
#import "MineBoughtGoodsCollectionViewCell.h"
#import "GoodsDetailViewController.h"
#import "ZanModel.h"

@interface MineBoughtGoodsViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MineBoughtGoodsCollectionViewCellDelegate>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) MineBoughtGoodsModel *model;
@property (strong, nonatomic) NSNumber *startNumber;
@property (assign, nonatomic) int pageNumber;

@end

@implementation MineBoughtGoodsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [MobClick beginLogPageView:@"我的收藏－已购买页面"];
    [TalkingData trackPageBegin:@"我的收藏－已购买页面"];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"我的收藏－已购买页面"];
    [TalkingData trackPageEnd:@"我的收藏－已购买页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageNumber = 1;
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetData];
    }];
    
    [self.collectionView.mj_header beginRefreshing];
    
}

- (void)getNetData {
    
    _pageNumber = 1;
    
    //v5
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/goods/findboughtgoods?pageIndex=%d&pageSize=10",_pageNumber];
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *arr = [responseObject objectForKey:@"data"];
                
                if (arr.count) {
                    
                    weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getNextPageData];
                    }];
                }
                
                _pageNumber ++;
                
                [weakSelf.dataArray removeAllObjects];
                
                for (NSDictionary *tempDic in arr) {
                    
                    MineBoughtGoodsModel *model = [[MineBoughtGoodsModel alloc] initWithDictionary:tempDic error:nil];
                    
                    [weakSelf.dataArray addObject:model];
                }
                
                [weakSelf.collectionView reloadData];
                
            }
            else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
            
            [weakSelf.collectionView.mj_header endRefreshing];
            
        }
        [weakSelf.collectionView.mj_header endRefreshing];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
    }];
    
}

#pragma  mark -- 请求下一页数据
- (void)getNextPageData {
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/goods/findboughtgoods?pageIndex=%d&pageSize=10",_pageNumber];
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *arr = [responseObject objectForKey:@"data"];
                
                if (!arr.count) {
                    
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                
                _pageNumber ++;
                
                for (NSDictionary *tempDic in arr) {
                    
                    MineBoughtGoodsModel *model = [[MineBoughtGoodsModel alloc] initWithDictionary:tempDic error:nil];
                    
                    [weakSelf.dataArray addObject:model];
                }
                
                [weakSelf.collectionView reloadData];
                
            }
            else if (state.intValue == 1){  //state.intValue = 1
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
            
            [weakSelf.collectionView.mj_footer endRefreshing];
            
        }
        [weakSelf.collectionView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [weakSelf.collectionView.mj_footer endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
    }];

}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MineBoughtGoodsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MineBoughtGoodsCollectionViewCell" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    MineBoughtGoodsModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.MineBoughtGoodsId.intValue];
    
    cell.model = model;
    cell.contentView.tag = indexPath.row;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    
    //li
    cell.zanImageView.highlighted = model.isThumbsup;
    cell.likeButton.selected = model.isThumbsup;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
    CGFloat height = imageWid + 10 +15 + 69;
    return CGSizeMake(imageWid+10+10, height);
}

- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    MineBoughtGoodsModel *model = self.dataArray[tag];
    NSNumber *goodId = (NSNumber *)model.MineBoughtGoodsId;
    
    NSString *trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.MineBoughtGoodsId.intValue];
    [[RJAppManager sharedInstance]trackingWithTrackingId:trackingId];
    
    
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = goodId;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1032];
//    statisticalDataModel.entranceTypeId = goodId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
    
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - 点赞 喜欢
- (void)likeButtonAction:(UIButton *)sender{
    
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }

    //li
    [self zanNetRequest:sender];
    
}

//li--调用点赞接口
- (void)zanNetRequest:(UIButton *)sender{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=goods"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    MineBoughtGoodsModel *model = self.dataArray[sender.tag];
    if (model.MineBoughtGoodsId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.MineBoughtGoodsId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                //                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                MineBoughtGoodsModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = thumb;
                
                [self.dataArray removeObjectAtIndex:sender.tag];
                
                [self.dataArray insertObject:model atIndex:sender.tag];
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:1]]];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
            
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
