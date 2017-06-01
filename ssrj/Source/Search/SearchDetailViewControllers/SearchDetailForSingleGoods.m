//
//  SearchDetailForSingleGoods.m
//  ssrj
//
//  Created by YiDarren on 16/8/5.
//  Copyright © 2016年 ssrj. All rights reserved.



/**
 *  搜索结果－－单品
 */

#import "SearchDetailForSingleGoods.h"
#import "RJBaseGoodModel.h"
#import "HomeGoodListCollectionViewCell.h"
#import "GoodsDetailViewController.h"
#import "SearchDetailSingleHeaderView.h"
#import "ZanModel.h"

@interface SearchDetailForSingleGoods ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, HomeGoodListCollectionViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) RJBaseGoodModel *model;
@property (strong, nonatomic) NSNumber *startNumber;
@property (assign, nonatomic) int pageNumber;
//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation SearchDetailForSingleGoods

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"搜索结果－单品页面"];
    [TalkingData trackPageBegin:@"搜索结果－单品页面"];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"搜索结果－单品页面"];
    [TalkingData trackPageEnd:@"搜索结果－单品页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNumber = 0;
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getCacheNetData];
    }];

    [self.collectionView.mj_header beginRefreshing];
}


#pragma mark -- 请求缓存网络数据start
- (void)getNetData {
    [self getCacheNetData];
}
- (void)getCacheNetData {
    
    _pageNumber = 0;

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/items/?pagenum=%d&pagesize=10&search=%@",_pageNumber,_searchWord];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *arr = [responseObject objectForKey:@"data"];
                
                if (arr.count) {
                    
                    weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getCacheNextPageData];
                    }];
                }
                
                _pageNumber++;
                
                [weakSelf.dataArray removeAllObjects];
                
                for (NSDictionary *tempDic in arr) {
                    RJBaseGoodModel *model = [[RJBaseGoodModel alloc] initWithDictionary:tempDic error:nil];
                    
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

#pragma mark -- 请求缓存链接下一页数据
- (void)getCacheNextPageData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/items/?pagenum=%d&pagesize=10&search=%@",_pageNumber,_searchWord];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *arr = [responseObject objectForKey:@"data"];
                
                if (!arr.count) {
                    
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                
                _pageNumber++;
                
                for (NSDictionary *tempDic in arr) {
                    RJBaseGoodModel *model = [[RJBaseGoodModel alloc] initWithDictionary:tempDic error:nil];
                    
                    [weakSelf.dataArray addObject:model];
                }
                
                [weakSelf.collectionView reloadData];
            }
            
            else if (state.intValue == 1){
                
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
    HomeGoodListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"searchDetailForSingleGoods" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    cell.likeButton.trackingId = [NSString stringWithFormat:@"%@&likeButton&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    
    cell.model = model;
    cell.contentView.tag = indexPath.row;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    
    //li
    cell.zanImageView.highlighted = model.isThumbsup.boolValue;
    cell.likeButton.selected = model.isThumbsup.boolValue;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
    CGFloat height = imageWid + 10 +15 + 69;
    return CGSizeMake(imageWid+10+10, height);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

//collectionView header size   add 9.23
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (section == 0) {
        
        if (!self.dataArray.count) {
            
            return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT*0.5);
        }

    }
    return CGSizeMake(0, 0);
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.dataArray.count) {
        
        if (kind == UICollectionElementKindSectionHeader) {
            
            SearchDetailSingleHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"SearchDetailSingleHeaderView" forIndexPath:indexPath];
            
            return headerView;
            
        }

    }
    
    return nil;
    
}

// 我的搭配cell代理
//- (void)tapGsetureWithIndexRow:(NSInteger)tag{
//    RJBaseGoodModel *model = self.dataArray[tag];
//    NSNumber *goodId = (NSNumber *)model.goodId;
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
//    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
//    goodsDetaiVC.goodsId = goodId;
//    
//    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
//}


- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    RJBaseGoodModel *model = self.dataArray[tag];
    NSNumber *goodId = (NSNumber *)model.goodId;
    
    NSString *trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    [[RJAppManager sharedInstance]trackingWithTrackingId:trackingId];
    

    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = goodId;
    
    goodsDetaiVC.zanBlock = ^(NSInteger buttonState){
        RJBaseGoodModel *model = self.dataArray[tag];
        model.isThumbsup = [NSNumber numberWithInteger:buttonState];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:1]]];
        //        [self.collectionView reloadData];
    };
    
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1026];
//    statisticalDataModel.entranceTypeId = goodId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
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
                
                [self.dataArray removeObjectAtIndex:sender.tag];
                
                [self.dataArray insertObject:model atIndex:sender.tag];
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:1]]];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"]  hideDelay:1];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}




@end
