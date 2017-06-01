//
//  RJUserRecommendViewController.m
//  ssrj
//
//  Created by mac on 17/2/20.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "RJUserRecommendViewController.h"
#import "HomeGoodListCollectionViewCell.h"
#import "GoodsDetailViewController.h"
#import "ZanModel.h"
#import "MineBoughtGoodsModel.h"
#import "MineBoughtGoodsCollectionViewCell.h"
#import "GoodsListModel.h"
#import "RJUserCenteRootViewController.h"



@interface RJUserRecommendViewController ()<UICollectionViewDelegateFlowLayout, STCollectionViewDataSource, STCollectionViewDelegate,HomeGoodListCollectionViewCellDelegate>

@property (strong, nonatomic) STCollectionView * stCollectionView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) GoodsListModel * model;
@property (assign, nonatomic) NSInteger pageNumber;

@end

@implementation RJUserRecommendViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self commonInit];
    __weak __typeof(&*self)weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];

    [self getNetData];
    [HTUIHelper addHUDToWindowWithString:@"加载中..."];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"用户中心推荐列表"];
    [TalkingData trackPageBegin:@"用户中心推荐列表"];
    
    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"用户中心推荐列表"];
    [TalkingData trackPageEnd:@"用户中心推荐列表"];
    
    
}
- (void)commonInit {
    self.stCollectionView =(STCollectionView *)self.collectionView;
    STCollectionViewFlowLayout * layout = self.st_collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.stCollectionView.stDelegate = self;
    self.stCollectionView.stDataSource = self;
    
    self.dataArray = [NSMutableArray array];
    
}
- (void)getNetData{
    self.pageNumber = 1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/user/listUserProducts.jhtml?id=%@&pageNumber=%ld",_userId, (long)_pageNumber];
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [HTUIHelper removeHUDToWindow];
        
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.model = model;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                
                [weakSelf.collectionView reloadData];
                if (model.data.count) {
                    weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextNetData];
                    }];
                    
                    _pageNumber += 1;

                }else{
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                }
                
            }else{
                [HTUIHelper addHUDToView:self.collectionView withString:model.msg hideDelay:2];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUD];
            
            [HTUIHelper addHUDToView:self.collectionView withString:@"Error" hideDelay:2];
            
        }
        
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf.collectionView.mj_header endRefreshing];
       
        [HTUIHelper removeHUDToWindow];
        
        [HTUIHelper addHUDToView:self.collectionView withString:@"加载失败,请稍后再试" hideDelay:2];
        
    }];
    
}
- (void)getNextNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/user/listUserProducts.jhtml?id=%@&pageNumber=%ld",_userId, _pageNumber];
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {

                if (model.data.count) {
                    [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                    
                    [weakSelf.collectionView.mj_footer endRefreshing];
                    
                    [weakSelf.collectionView reloadData];
                    
                    _pageNumber += 1;
                    
                }else{
                    //没数据了 关闭上拉加载更多
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                    return;
                }
            }else{
                [HTUIHelper addHUDToView:self.collectionView withString:@"Error" hideDelay:2];
                [weakSelf.collectionView.mj_footer endRefreshing];
                
            }
            
        }else{
            [HTUIHelper addHUDToView:self.collectionView withString:@"Error" hideDelay:2];
            [weakSelf.collectionView.mj_footer endRefreshing];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.collectionView withString:@"加载失败,请稍后再试" hideDelay:2];
        [weakSelf.collectionView.mj_footer endRefreshing];
        
    }];
    
}
- (NSInteger)stCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)stCollectionView:(STCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeGoodListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RJUserCenterRecommendCell" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    cell.fatherViewControllerName = @"RJUserRecommendViewController";
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
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(STCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section {
    return 2;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
    CGFloat height = imageWid + 10 +15 + 69;
    return CGSizeMake(0, height);
}
- (STCollectionViewFlowLayout *)st_collectionViewLayout {
    return (STCollectionViewFlowLayout *)self.collectionViewLayout;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%f",collectionView.contentInset.top);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    RJBaseGoodModel *model = self.dataArray[tag];
    NSNumber *goodId = (NSNumber *)model.goodId;
    
    NSString * trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    [[RJAppManager sharedInstance]trackingWithTrackingId:trackingId];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = goodId;

    [self.fatherViewController.navigationController pushViewController:goodsDetaiVC animated:YES];
    
    goodsDetaiVC.zanBlock = ^(NSInteger buttonState){
        RJBaseGoodModel *model = self.dataArray[tag];
        model.isThumbsup = [NSNumber numberWithInteger:buttonState];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];
    };

}

#pragma mark - 点赞 喜欢
- (void)likeButtonAction:(UIButton *)sender{
    
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self.fatherViewController presentViewController:loginNav animated:YES completion:^{
            
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
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]]];
                
                [weakSelf.fatherViewController getUserHeaderData];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"]  hideDelay:1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Net Error" hideDelay:2];
        
    }];
}

@end
