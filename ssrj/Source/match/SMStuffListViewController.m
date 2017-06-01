//
//  SMStuffListViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 17/1/6.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "SMStuffListViewController.h"
#import "SMCreateMatchController.h"

#import "GoodsListModel.h"

#import "SMMyGoodsCell.h"

#import "Masonry.h"


static NSString * const StuffUrl = @"/b180/api/v1/collocation/stuff/";

@interface SMStuffListViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger stuffPage;
@property (nonatomic, assign) NSInteger pagesize;

@end

@implementation SMStuffListViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"创建搭配-素材详情页面"];
    [TalkingData trackPageBegin:@"创建搭配-素材详情页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建搭配-所有单品详情页面"];
    [TalkingData trackPageEnd:@"创建搭配-所有单品详情页面"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataArray = [NSMutableArray array];
    _pagesize = 30;
    
    [self configCollectionView];
    
}

#pragma mark - network
/** http://ugcapp.ssrj.com/api/v1/collocation/stuff/?appVersion=2.2.0&category=5&pagenum=33&pagesize=10&token=daf1a91acee1be236510cc2bd1873b49
 
 "data":[
 {
 "source":"http://www.ssrj.com/upload/image/201509/7a68dd84-cbee-4c23-9d06-22d29337c3e9.png",
 "src":"http://www.ssrj.com/upload/image/201509/7a68dd84-cbee-4c23-9d06-22d29337c3e9.png",
 "type":"5",
 "id":"566",
 "title":"双肩背"
 },
 */
//搜索首页素材
- (void)getStuffData {
    _stuffPage= 1;
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = StuffUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(_stuffPage) forKey:@"pagenum"];
    [dict setObject:@(_pagesize) forKey:@"pagesize"];
    if (self.ID.length) {
        [dict setObject:self.ID forKey:@"category"];
    }
    requestInfo.getParams = dict;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"]intValue] == 0) {
            _stuffPage++;
            [weakSelf.dataArray removeAllObjects];
            for (NSDictionary *stuffDict in responseObject[@"data"]) {
                NSError *error;
                SMStuffDetailModel *model = [[SMStuffDetailModel alloc] initWithDictionary:stuffDict error:&error];
                if (!error) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [weakSelf.collectionView reloadData];
            [weakSelf.collectionView.mj_header endRefreshing];
            if (weakSelf.dataArray.count < _pagesize) {
                [weakSelf.collectionView.mj_footer setHidden:YES];
            }else {
                [weakSelf.collectionView.mj_footer resetNoMoreData];
            }
        }else {
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.collectionView.mj_header endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}
- (void)getStuffNextData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = StuffUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(_stuffPage) forKey:@"pagenum"];
    [dict setObject:@(_pagesize) forKey:@"pagesize"];
    if (self.ID.length) {
        [dict setObject:self.ID forKey:@"category"];
    }
    requestInfo.getParams = dict;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject[@"state"]intValue] == 0) {
//            NSLog(@"%zd == %zd",_stuffPage , [responseObject[@"data"] count]);
            _stuffPage++;
            for (NSDictionary *stuffDict in responseObject[@"data"]) {
                NSError *error;
                SMStuffDetailModel *model = [[SMStuffDetailModel alloc] initWithDictionary:stuffDict error:&error];
                if (!error) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [weakSelf.collectionView reloadData];
            if ([responseObject[@"data"] count] < _pagesize ) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
        }else {
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
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
    [_collectionView registerClass:[SMMyGoodsCell class] forCellWithReuseIdentifier:@"SMMyGoodsCell"];
    [self.view addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getStuffData];
    }];
    _collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [self getStuffNextData];
    }];
    [_collectionView.mj_footer setAutomaticallyHidden:YES];
    [_collectionView.mj_header beginRefreshing];
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMMyGoodsCell *cell = (SMMyGoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SMMyGoodsCell" forIndexPath:indexPath];
    
    SMStuffDetailModel *model = self.dataArray[indexPath.row];
    cell.stuffModel = model;
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.ID.intValue];
    if (indexPath.row % 3 != 0) {
        [cell hiddenLeftLine];
    }
    if (indexPath.row != 0 && indexPath.row != 1 && indexPath.row != 2) {
        [cell hiddenTopLine];
    }
    __weak __typeof(&*self)weakSelf = self;
    cell.clickAddBtnBlock = ^ {
        if ([weakSelf.navigationController.parentViewController isKindOfClass:[SMCreateMatchController class]]) {
            SMCreateMatchController *createMatchVC = (SMCreateMatchController *)weakSelf.navigationController.parentViewController;
            
            //素材不用传id
            SMStuffDetailModel *model = weakSelf.dataArray[indexPath.row];
            SMGoodsModel *goodsModel = [[SMGoodsModel alloc] init];
            goodsModel.name = model.title;
            goodsModel.image = model.source;
            [createMatchVC addGoodsOrSourceWithModel:goodsModel];
        }
        
    };
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
@end
