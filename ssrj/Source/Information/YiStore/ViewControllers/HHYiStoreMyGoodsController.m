//
//  HHYiStoreMyGoodsController.m
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHYiStoreMyGoodsController.h"
#import "HHYiStoreAddGoodsController.h"

#import "HHYiStoreMyGoodsCell.h"
#import "RJBaseGoodModel.h"
#import "GoodsListModel.h"
#import "Masonry.h"
NSString * const yiStoreGoodsUrl = @"http://192.168.1.173:8888/api/v1/mshop/goods/list";
NSString * const deleteGoodsUrl = @"http://192.168.1.173:8888/api/v1/mshop/goods/delete";
//NSString * const yiStoreGoodsUrl = @"http://192.168.1.252:8000/api/v1/mshop/goods/list";
//NSString * const deleteGoodsUrl = @"http://192.168.1.252:8000/api/v1/mshop/goods/delete";
@interface HHYiStoreMyGoodsController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HHYiStoreAddGoodsControllerDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation HHYiStoreMyGoodsController {
    int pagesize;
    int pagenumber;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"微店-我的商品页"];
    [TalkingData trackPageBegin:@"微店-我的商品页"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"微店-我的商品页"];
    [TalkingData trackPageEnd:@"微店-我的商品页"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configUI];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(BOOL)hidesBottomBarWhenPushed {
    
    return YES;
}

- (void)configUI {
    [self addBackButton];
    self.title = @"我的商品";
    UIButton *addButton = [[UIButton alloc] init];
    [addButton setTitle:@"+添加商品" forState:UIControlStateNormal];
    [addButton sizeToFit];
    addButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [addButton addTarget:self action:@selector(addGoodsButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    addButton.trackingId = @"HHYiStoreMyGoodsController&addButton";
    
    [self configCollectionView];
    
}
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = (self.view.bounds.size.width-0.2) / 2.0;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth - 20 + 10 + 83);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[HHYiStoreMyGoodsCell class] forCellWithReuseIdentifier:@"HHYiStoreMyGoodsCell"];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    __weak __typeof(&*self)weakSelf = self;
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getNextData];
    }];
    [self.collectionView.mj_header beginRefreshing];
    self.collectionView.mj_footer.automaticallyHidden = YES;
}

#pragma mark - net
- (void)getNetData{
    if (![self.userId intValue]) {
        [self.collectionView.mj_header endRefreshing];
        return;
    }
    pagesize = 10;
    pagenumber = 1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = yiStoreGoodsUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"member": self.userId,@"pagenum":@(pagenumber),@"pagesize":@(pagesize)}];
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                pagenumber++;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                [weakSelf.collectionView reloadData];
                if (weakSelf.dataArray.count < pagesize) {
                    [weakSelf.collectionView.mj_footer setHidden:YES];
                }else {
                    [weakSelf.collectionView.mj_footer resetNoMoreData];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:0.5];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUD];
            
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:0.5];
            
        }
        
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:0.5];
        
    }];
    
}

- (void)getNextData{
    if (![self.userId intValue]) {
        [self.collectionView.mj_footer setHidden:YES];
        [self.collectionView.mj_footer endRefreshing];
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = yiStoreGoodsUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"member": self.userId,@"pagenum":@(pagenumber),@"pagesize":@(pagesize)}];
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                pagenumber++;
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                [weakSelf.collectionView reloadData];
                [weakSelf.collectionView.mj_footer endRefreshing];
                if (model.data.count < pagesize) {
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                }else {
                    [weakSelf.collectionView.mj_footer endRefreshing];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:0.5];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUD];
            
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:0.5];
            
        }
        
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:0.5];
        
    }];
    
}

#pragma mark - events
- (void)addGoodsButtonClick {
    HHYiStoreAddGoodsController *vc = [HHYiStoreAddGoodsController new];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    __weak __typeof(&*self)weakSelf = self;
    
    HHYiStoreMyGoodsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHYiStoreMyGoodsCell" forIndexPath:indexPath];
    cell.goodsModel = self.dataArray[indexPath.row];
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),cell.goodsModel.goodId.intValue];
    cell.deleteBlcok = ^(NSString *goodsId){
        [weakSelf deleteGoods:goodsId];
    };
    
    if (indexPath.row % 2 == 1) {
        [cell hiddenLeftLine];
    }
    if (indexPath.row != 0 && indexPath.row != 1) {
        [cell hiddenTopLine];
    }
    return cell;
}
- (void)deleteGoods:(NSString *)goodsId {
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = deleteGoodsUrl;
    [requestInfo.postParams addEntriesFromDictionary:@{@"goods": goodsId}];
    [[ZHNetworkManager sharedInstance] postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableArray *tempArray = [NSMutableArray array];
        if ([responseObject[@"state"] intValue] == 0) {
            for (RJBaseGoodModel *model in weakSelf.dataArray) {
                if (![model.goodId isEqualToString:goodsId]) {
                    [tempArray addObject:model];
                }
            }
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.dataArray addObjectsFromArray:tempArray];
            [weakSelf.collectionView reloadData];
            
            [[HTUIHelper shareInstance] removeHUD];
        }else {
            [[HTUIHelper shareInstance] removeHUDWithEndString:responseObject[@"msg"] image:nil delyTime:0.2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance] removeHUDWithEndString:@"error" image:nil delyTime:0.3];
    }];
    
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)yiStoreAddGoodsContollerDidFinishedChooseGoods {
    [self getNetData];
}
#pragma mark - get
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}
@end
