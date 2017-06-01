//
//  SMSearchDetailController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/17.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMSearchDetailController.h"
#import "SMCreateMatchController.h"
#import "SMGoodsDetailController.h"
#import "SMMyGoodsCell.h"
#import "Masonry.h"
NSString * const SearchGoodsNameUrl = @"/b180/api/v1/goodsinfor/goods_search";
@interface SMSearchDetailController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIView *navBar;
//导航条的返回按钮
@property (nonatomic,strong)UIButton *backBtn;
//导航条的取消按钮
@property (nonatomic,strong)UIButton *cancelBtn;

@end

@implementation SMSearchDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [NSMutableArray array];
    [self configNavBar];
    [self configCollectionView];
    
    __weak __typeof(&*self)weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetData];
    }];
    [self.collectionView.mj_header beginRefreshing];
    [self addNotification];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [MobClick beginLogPageView:@"创建资讯-搜索详情页面"];
    [TalkingData trackPageBegin:@"创建资讯-搜索详情页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"创建资讯-搜索详情页面"];
    [TalkingData trackPageEnd:@"创建资讯-搜索详情页面"];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(controllerDidScrollNotification:) name:@"ControllerScrollNotification" object:nil];
}
#pragma mark - UI
- (void)configNavBar {
    self.navigationController.navigationBarHidden = YES;
    UIView *navBar = [[UIView alloc]init];
    navBar.backgroundColor = APP_BASIC_COLOR;
    navBar.frame = CGRectMake(0, 0, kScreenWidth, 64);
    [self.view addSubview:navBar];
    _navBar = navBar;
    
    _backBtn = [[UIButton alloc]init];
    [_backBtn setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
    [_backBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:_backBtn];
    
    UIButton *searchBtn = [[UIButton alloc]init];
    searchBtn.backgroundColor = [UIColor whiteColor];
    searchBtn.layer.cornerRadius = 5;
    searchBtn.layer.masksToBounds = YES;
    [searchBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchDown];
    [navBar addSubview:searchBtn];
    
    UIImageView *searchImageView = [[UIImageView alloc]initWithImage:GetImage(@"search_icon2")];
    [searchBtn addSubview:searchImageView];
    
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont systemFontOfSize:15];
    label.text = self.searchName;
    label.textColor = [UIColor grayColor];
    [searchBtn addSubview:label];
    
    _cancelBtn = [[UIButton alloc]init];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [_cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:_cancelBtn];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(navBar);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_backBtn.mas_right);
        make.bottom.equalTo(navBar).offset(-7);
        make.right.equalTo(navBar).offset(-50);
        make.height.mas_equalTo(30);
    }];
    [searchImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchBtn).offset(10);
        make.centerY.equalTo(searchBtn);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchImageView.mas_right).offset(10);
        make.right.equalTo(searchBtn);
        make.bottom.top.equalTo(searchBtn);
    }];
    [_cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(searchBtn.mas_right);
        make.right.equalTo(navBar);
        make.bottom.top.equalTo(searchBtn);
    }];
}
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = (self.view.bounds.size.width) / 3.0;
    layout.itemSize = CGSizeMake(cellWidth, (cellWidth-50) + 40 + 20);
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
        make.top.equalTo(_navBar.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    
}


#pragma mark --请求非缓存网络数据
- (void)getNetData {
    
    if (self.searchName.length == 0) {
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = SearchGoodsNameUrl;
    [requestInfo.getParams addEntriesFromDictionary:@{@"name" : self.searchName}];
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                [weakSelf.dataArray removeAllObjects];
                NSArray *arr = [responseObject objectForKey:@"data"];
                for (NSDictionary *tempDic in arr) {
                    RJBaseGoodModel *model = [[RJBaseGoodModel alloc] initWithDictionary:tempDic error:nil];
                    [weakSelf.dataArray addObject:model];
                }
                [weakSelf.collectionView reloadData];
            }
            else if (state.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        }
        
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];
    }];
    
}
#pragma mark - event
- (void)cancelBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)controllerDidScrollNotification:(NSNotification *)notification {
    NSString *stateString = notification.object;
    if ([stateString isEqualToString:@"top"]) {
        [UIView animateWithDuration:0.3 animations:^{
            _navBar.frame = CGRectMake(0, 0, kScreenWidth, 64);
        } completion:^(BOOL finished) {
            [_backBtn setImage:[UIImage imageNamed:@"back_icon"] forState:UIControlStateNormal];
            _navBar.backgroundColor = APP_BASIC_COLOR;
            [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }];
    }else {
        [UIView animateWithDuration:0.3 animations:^{
            _navBar.frame = CGRectMake(0, 0, kScreenWidth, 44);
        } completion:^(BOOL finished) {
            [_backBtn setImage:[UIImage imageNamed:@"match_jiantou1"] forState:UIControlStateNormal];
            _navBar.backgroundColor = [UIColor colorWithHexString:@"#e6e6e6"];
            [_cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }];
        
    }
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMMyGoodsCell *cell = (SMMyGoodsCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"SMMyGoodsCell" forIndexPath:indexPath];
    if (self.isFromAllGoods) {
        
        RJBaseGoodModel *model = self.dataArray[indexPath.row];
        cell.model = model;
        
        /**
         *  统计ID
         */
        cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
        
        
    }else {
        SMStuffDetailModel *model = self.dataArray[indexPath.row];
        cell.stuffModel = model;
        
        /**
         *  统计ID
         */
        cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.ID.intValue];
        
    }
    if (indexPath.row % 3 != 0) {
        [cell hiddenLeftLine];
    }
    if (indexPath.row != 0 && indexPath.row != 1 && indexPath.row != 2) {
        [cell hiddenTopLine];
    }
    cell.clickAddBtnBlock = ^ {
        if ([self.navigationController.parentViewController isKindOfClass:[SMCreateMatchController class]]) {
            SMCreateMatchController *createMatchVC = (SMCreateMatchController *)self.navigationController.parentViewController;
            
            RJBaseGoodModel *model = self.dataArray[indexPath.row];
            SMGoodsModel *goodsModel = [[SMGoodsModel alloc] init];
            goodsModel.name = model.name;
            goodsModel.ID = model.goodId;
            goodsModel.image = model.image;
            [createMatchVC addGoodsOrSourceWithModel:goodsModel];
        }
    };
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //进入商品详情
    if (self.isFromAllGoods) {
        
        RJBaseGoodModel *model = self.dataArray[indexPath.row];
        SMGoodsDetailController *detail = [[SMGoodsDetailController alloc]init];
        detail.goodsId = model.goodId;
        detail.model = model;
        [self.navigationController pushViewController:detail animated:YES];
    }

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
