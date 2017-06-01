
#import "RJBrandDetailGoodsViewController.h"
#import "CCGoodOrderView.h"
#import "HomeGoodListCollectionViewCell.h"
#import "GoodsListModel.h"
#import "FilterNavigationController.h"
#import "FilterListViewController.h"
#import "HomeGoodListCollectionViewCell.h"
#import "ZanModel.h"
#import "GoodsDetailViewController.h"
#import "RJBrandDetailRootViewController.h"
@interface RJBrandDetailGoodsViewController ()<UICollectionViewDelegateFlowLayout,STCollectionViewDataSource,STCollectionViewDelegate,CCGoodOrderViewDelegate,HomeGoodListCollectionViewCellDelegate,FilterListViewDelegate>{
    NSInteger count;
}
@property (strong, nonatomic) CCGoodOrderView * orderView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) GoodsListModel * model;
@property (strong, nonatomic) NSNumber * startNumber;
@property (strong, nonatomic) NSMutableArray * sortArray;
@property (strong, nonatomic) NSMutableArray * filterArray;
@property (strong, nonatomic) FilterNavigationController * filterViewController;
/**
 *  筛选传递的参数
 */
@property (strong, nonatomic) NSMutableDictionary *filterDictionary;
@property (strong, nonatomic) NSString * selectSortStr;
@end

@implementation RJBrandDetailGoodsViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self commonInit];
    __weak __typeof(&*self)weakSelf = self;
    self.stCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.stCollectionView.mj_header beginRefreshing];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"品牌界面单品列表"];
    [TalkingData trackPageBegin:@"品牌界面单品列表"];

    
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"品牌界面单品列表"];
    [TalkingData trackPageEnd:@"品牌界面单品列表"];

    
}
- (void)commonInit {
    
    self.stCollectionView =(STCollectionView *)self.collectionView;
    STCollectionViewFlowLayout * layout = self.st_collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(50, 0, 0, 0);
    self.stCollectionView.stDelegate = self;
    self.stCollectionView.stDataSource = self;
    
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:@"CCGoodOrderView" owner:nil options:nil];
    
    if (arr.count) {
        
        self.orderView = arr.firstObject;
        self.orderView.frame = CGRectMake(0, SCREEN_WIDTH/64*27 +40, SCREEN_WIDTH, 50);
        self.orderView.delegate = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView addSubview:self.orderView];

        });

    }
    self.dataArray = [NSMutableArray array];
    
    self.filterDictionary  = [NSMutableDictionary dictionary];
    // add 1.17
    NSMutableArray *brandArray = [NSMutableArray arrayWithObjects:_brandId.stringValue, nil];

    [self.filterDictionary addEntriesFromDictionary:@{@"Category":[NSMutableArray array],
                                                      @"Brand":brandArray,//add 1.17
                                                      @"Price":[NSMutableArray array],
                                                      @"Color":[NSMutableArray array]}];
    self.sortArray = [NSMutableArray arrayWithObjects:@"goodsOrder_desc",@"promotionPrice_asc",@"promotionPrice_desc",@"goodsOrder3_desc", nil];
    self.selectSortStr = self.sortArray[0];


}
- (void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/product/list.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":@"0",@"rows":@"10",@"orderStr":self.selectSortStr}];
    
    if (self.parameterDictionary) {
        
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
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
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.model = model;
                weakSelf.startNumber = model.start;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
         
                [weakSelf.collectionView reloadData];
                if (model.data.count) {
                    weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextNetData];
                    }];
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
//        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];

        [HTUIHelper addHUDToView:self.collectionView withString:@"加载失败,请稍后再试" hideDelay:2];
        
    }];

}
- (void)getNextNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"api/v5/product/list.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@"10",@"orderStr":self.selectSortStr}];
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.parameterDictionary) {
        
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
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
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                //                weakSelf.model = model;
                //                NSLog(@"%@",model.start);
                weakSelf.startNumber = model.start;
                if (model.data.count) {
                    [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                    
                    [weakSelf.collectionView.mj_footer endRefreshing];
                    
                    [weakSelf.collectionView reloadData];
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
    HomeGoodListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    cell.fatherViewControllerName = @"RJBrandDetailGoodsViewController";
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
#pragma mark -品牌单品代理刷选
//- (void)

#pragma mark - CCGoodOrderViewDelegate

- (void)changeOrderWithOrderType:(CCOrderType)type{
    self.selectSortStr = self.sortArray[type];
//    NSLog(@"%@",self.selectSortStr);
    [self.collectionView.mj_header beginRefreshing];
}
- (void)filterButtonTapAction{
    //    NSLog(@"筛选");
    if (!self.filterViewController) {
        self.filterViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"FilterNavigationController"];
    }
    FilterListViewController *vc = [self.filterViewController.viewControllers firstObject];
    /**
     *  把这个界面的筛选dic 赋值给筛选界面
     */
    vc.dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.filterDictionary mutableCopy]];
    vc.parameterDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.parameterDictionary mutableCopy]];
    vc.delegate = self;
    [vc updateFilterDic];
    [self presentViewController:self.filterViewController animated:YES completion:^{
        
    }];
}
- (STCollectionViewFlowLayout *)st_collectionViewLayout {
    return (STCollectionViewFlowLayout *)self.collectionViewLayout;
}
#pragma mark - FilterListViewDelegate
- (void)filiterDownWithDictionary:(NSMutableDictionary *)dic shouldReload:(BOOL)flag{
    
    self.filterDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (flag) {
        //重新请求数据
        //        [self.collectionView.header endRefreshing];
        //        [self.collectionView.footer endRefreshing];
        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
        [self getNetData];
        
        //赋值 筛选条件
        self.fatherViewController.filterDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
        [self.fatherViewController getBrandHeanderData];
        //        [self.collectionView.header beginRefreshing];
    }
}
- (void)filterButtonTaped{
    if (!self.filterViewController) {
        UIStoryboard *storyboard =[UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.filterViewController = [storyboard instantiateViewControllerWithIdentifier:@"FilterNavigationController"];
    }
    FilterListViewController *vc = [self.filterViewController.viewControllers firstObject];
    /**
     *  把这个界面的筛选dic 赋值给筛选界面
     */
    vc.dictionary = [NSMutableDictionary dictionaryWithDictionary:[self.filterDictionary mutableCopy]];
    vc.parameterDictionary = [NSMutableDictionary dictionaryWithDictionary:[self.parameterDictionary mutableCopy]];
    vc.delegate = self;
    [vc updateFilterDic];
    [self.fatherViewController presentViewController:self.filterViewController animated:YES completion:^{
        
    }];
}

#pragma mark - 品牌筛选代理
- (void)filiterRJBrandRootVCInGoodVC {
        
    if (self.delegate) {
        if ([self.delegate isKindOfClass:NSClassFromString(@"RJBrandDetailRootViewController")]) {
            
            if ([self.delegate respondsToSelector:@selector(reloadRJBrandRootVCData)]) {
                
                [self.delegate reloadRJBrandRootVCData];
            }
        }
    }
    
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%f",collectionView.contentInset.top);
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
    
    //    HomeGoodListCollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tag inSection:1]];
    
    goodsDetaiVC.zanBlock = ^(NSInteger buttonState){
        RJBaseGoodModel *model = self.dataArray[tag];
        model.isThumbsup = [NSNumber numberWithInteger:buttonState];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];
        //        [self.collectionView reloadData];
    };
    
    [self.fatherViewController.navigationController pushViewController:goodsDetaiVC animated:YES];
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
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]]];
                
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
