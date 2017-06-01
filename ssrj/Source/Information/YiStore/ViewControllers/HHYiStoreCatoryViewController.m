//
//  HHYiStoreCatoryViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHYiStoreCatoryViewController.h"
#import "HHYiStoreAddGoodsController.h"
#import "HHYiStoreCategoryCell.h"

#import "GoodsListModel.h"

#import "Masonry.h"

static NSString * const GoodsUrl = @"/api/v5/product/list.jhtml";

@interface HHYiStoreCatoryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (strong, nonatomic) NSNumber *startNumber;
@property (nonatomic, assign) NSInteger pagesize;
@end

@implementation HHYiStoreCatoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [NSMutableArray array];
    _pagesize = 30;
    
    [self configCollectionView];
    
}
- (void)reloadData {
    [_collectionView.mj_header beginRefreshing];
}
#pragma mark - ui
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = (self.view.bounds.size.width) / 3.0;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth * 1.3);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[HHYiStoreCategoryCell class] forCellWithReuseIdentifier:@"HHYiStoreCategoryCell"];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getNetData];
    }];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self getNextNetData];
    }];
    [self.collectionView.mj_header beginRefreshing];
    [_collectionView.mj_footer setAutomaticallyHidden:YES];
}
- (NSArray *)choosedGoods {
    NSMutableArray *choosedArr = [NSMutableArray array];
    for (RJBaseGoodModel *model in self.dataArray) {
        if ([model.selected boolValue]) {
            [choosedArr addObject:model];
        }
    }
    return [choosedArr copy];
}
- (void)chooseAll {
    [self.dataArray enumerateObjectsUsingBlock:^(RJBaseGoodModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = @(YES);
    }];
    [self.collectionView reloadData];
}
- (void)clearAll {
    [self.dataArray enumerateObjectsUsingBlock:^(RJBaseGoodModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selected = @(NO);
    }];
    [self.collectionView reloadData];
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HHYiStoreCategoryCell *cell = (HHYiStoreCategoryCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"HHYiStoreCategoryCell" forIndexPath:indexPath];
    
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    if (indexPath.row % 3 != 0) {
        [cell hiddenLeftLine];
    }
    if (indexPath.row != 0 && indexPath.row != 1 && indexPath.row != 2) {
        [cell hiddenTopLine];
    }
    __weak __typeof(&*self)weakSelf = self;
    cell.chooseBlock = ^(NSInteger selected){
        model.selected = @(selected);
        HHYiStoreAddGoodsController *vc = (HHYiStoreAddGoodsController *)weakSelf.parentViewController;
        [vc cancelChooseAllState];
        [vc updateChooseSureBtnNummber];
    };
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - net
- (void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = GoodsUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":@"0",@"rows":@(_pagesize)}];
    if (self.ID.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"classifys": self.ID}];
    }
    //筛选！！！！
    if (self.filterDictionary) {
        NSMutableArray *category = [self.filterDictionary objectForKey:@"Category"];
        if (category.count) {
            NSString *str = [category componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"categoryTag":str}];
        }
        NSMutableArray *brand = [self.filterDictionary objectForKey:@"Brand"];
        if (brand.count) {
            NSString *str = [brand componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"brands":str}];
        }
        NSMutableArray *price = [self.filterDictionary objectForKey:@"Price"];
        if (price.count) {
            NSString *str = [price componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"prices":str}];
        }
        NSMutableArray *color = [self.filterDictionary objectForKey:@"Color"];
        if (color.count) {
            NSString *str = [color componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"colors":str}];
        }
        
    }
    
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [weakSelf.dataArray removeAllObjects];
        GoodsListModel *model = responseObject;
        if (model.state.boolValue == 0) {
            weakSelf.startNumber = model.start;
            [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
        }else{
            [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
        }
        
        [[HTUIHelper shareInstance]removeHUD];
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView.mj_header endRefreshing];
        
        if (weakSelf.dataArray.count < _pagesize) {
            [weakSelf.collectionView.mj_footer setHidden:YES];
        }else {
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        
        HHYiStoreAddGoodsController *vc = (HHYiStoreAddGoodsController *)weakSelf.parentViewController;
        [vc cancelChooseAllState];
        [vc updateChooseSureBtnNummber];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"error" hideDelay:2];
        
    }];
    
}
- (void)getNextNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = GoodsUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@(_pagesize)}];
    
    if (self.ID.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"classifys": self.ID}];
    }
    //筛选！！！！
    if (self.filterDictionary) {
        NSMutableArray *category = [self.filterDictionary objectForKey:@"Category"];
        if (category.count) {
            NSString *str = [category componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"categoryTag":str}];
        }
        NSMutableArray *brand = [self.filterDictionary objectForKey:@"Brand"];
        if (brand.count) {
            NSString *str = [brand componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"brands":str}];
        }
        NSMutableArray *price = [self.filterDictionary objectForKey:@"Price"];
        if (price.count) {
            NSString *str = [price componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"prices":str}];
        }
        NSMutableArray *color = [self.filterDictionary objectForKey:@"Color"];
        if (color.count) {
            NSString *str = [color componentsJoinedByString:@";"];
            [requestInfo.getParams addEntriesFromDictionary:@{@"colors":str}];
        }
        
    }
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        GoodsListModel *model = responseObject;
        if (model.state.boolValue == 0) {
            weakSelf.startNumber = model.start;
            [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
            [weakSelf.collectionView reloadData];
            if (model.data.count < _pagesize) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
        
        HHYiStoreAddGoodsController *vc = (HHYiStoreAddGoodsController *)weakSelf.parentViewController;
        [vc cancelChooseAllState];
        [vc updateChooseSureBtnNummber];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];
        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
}
@end
