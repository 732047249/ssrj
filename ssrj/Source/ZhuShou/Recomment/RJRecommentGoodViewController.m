
#import "RJRecommentGoodViewController.h"
#import "GoodsListModel.h"
#import "FilterNavigationController.h"
#import "FilterListViewController.h"
#import "HomeGoodListViewController.h"
#import "HomeGoodListCollectionViewCell.h"
#import "GoodsDetailViewController.h"
#import "CCGoodOrderView.h"
#import "ZanModel.h"
#import "GuideView.h"
#import "RJZhuShouViewController.h"
//static NSString * const RecommentGoodNetUrl  = @"/b82/api/v3/clad-aide/find-goods";
#define RecommentGoodNetUrl @"/b82/api/v5/clad-aide/find-goods"
@interface RJRecommentGoodViewController ()<UICollectionViewDelegateFlowLayout,HomeGoodListCollectionViewCellDelegate,FilterListViewDelegate,CCGoodOrderViewDelegate,STCollectionViewDataSource,STCollectionViewDelegate>
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) GoodsListModel * model;
@property (strong, nonatomic) NSNumber * startNumber;
@property (strong, nonatomic) NSArray * sortArray;
@property (strong, nonatomic) NSMutableArray * filterArray;
@property (strong, nonatomic) NSString * selectSortStr;
@property (strong, nonatomic) FilterNavigationController * filterViewController;
/**
 *  筛选传递的参数
 */
@property (strong, nonatomic) NSMutableDictionary *filterDictionary;

@property (strong, nonatomic) CCGoodOrderView *orderView;


@end

@implementation RJRecommentGoodViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self commonInit];

    self.orderView.delegate = self;
    self.dataArray = [NSMutableArray array];
    self.filterDictionary  = [NSMutableDictionary dictionary];
    
    [self.filterDictionary addEntriesFromDictionary:@{@"Category":[NSMutableArray array],
                                                      @"Brand":[NSMutableArray array],
                                                      @"Price":[NSMutableArray array],
                                                      @"Color":[NSMutableArray array]}];
    
    __weak __typeof(&*self)weakSelf = self;
    
//    NSArray *arr1 = @[@"默认",@"最新",@"综合排序",@"按价格升序",@"按价格降序",@"按上架时间升序",@"按上架时间降序"];
//    NSArray *arr2 = @[@"goodsOrder_desc",@"createDate_desc",@"isTop_desc",@"price_asc",@"price_desc",@"upTime_asc",@"upTime_desc"];
//    NSMutableArray *arr = [NSMutableArray array];
//    
//    [arr1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        RJSorteModel *model = [[RJSorteModel alloc]initWithName:arr1[idx] value:arr2[idx]];
//        [arr addObject:model];
//    }];
//    self.sortArray = [NSMutableArray arrayWithArray:[arr copy]];
//    self.selectSortModel = self.sortArray[1];
    

    
    self.sortArray = [NSMutableArray arrayWithObjects:@"goodsOrder_desc",@"promotionPrice_asc",@"promotionPrice_desc",@"goodsOrder3_desc", nil];
    
    self.selectSortStr = self.sortArray[0];
    
    self.stCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetDataWithHUD:NO];
        
    }];
    [self.stCollectionView.mj_header beginRefreshing];
    
//    [self.stCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    
    [self addGuideView];
    
    self.orderView.buttonOne.trackingId = [NSString stringWithFormat:@"%@&orderView&buttonOne",NSStringFromClass(self.class)];
    self.orderView.buttonTwo.trackingId = [NSString stringWithFormat:@"%@&orderView&buttonTwo",NSStringFromClass(self.class)];
    self.orderView.buttonThree.trackingId = [NSString stringWithFormat:@"%@&orderView&buttonThree",NSStringFromClass(self.class)];
    self.orderView.filterButton.trackingId = [NSString stringWithFormat:@"%@&orderView&filterButton",NSStringFromClass(self.class)];

 
}
- (void)commonInit {
    
    self.stCollectionView =(STCollectionView *)self.collectionView;
    STCollectionViewFlowLayout * layout = self.st_collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(50, 0, 0, 0);
    
    
//    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
//    CGFloat height = imageWid + 10 +15 + 69;
//    
//    layout.itemSize = CGSizeMake(SCREEN_WIDTH/2, height);
    
    
    NSArray *arr = [[NSBundle mainBundle]loadNibNamed:@"CCGoodOrderView" owner:nil options:nil];
    
    if (arr.count) {
        
        self.orderView = arr.firstObject;
        
        self.orderView.frame = CGRectMake(0, (86 - 15)*(SCREEN_WIDTH/320) +15 + 40, SCREEN_WIDTH, 50);
        
        
        self.orderView.delegate = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView addSubview:self.orderView];
            
        });
        
    }
    
    self.stCollectionView.stDelegate = self;
    self.stCollectionView.stDataSource = self;
}
- (STCollectionViewFlowLayout *)st_collectionViewLayout {
    return (STCollectionViewFlowLayout *)self.collectionViewLayout;
}

#pragma mark - CCGoodOrderViewDelegate
- (void)changeOrderWithOrderType:(CCOrderType)type{
    
    self.selectSortStr = self.sortArray[type];
//    NSLog(@"%@",self.selectSortStr);
    [self.collectionView.mj_header beginRefreshing];
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

#pragma mrak -
- (void)sceneDataChanged:(NSMutableArray *)arr{
    self.sceneArray = [NSMutableArray arrayWithArray:[arr mutableCopy]];
//    [self.collectionView.mj_header beginRefreshing];
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self getNetDataWithHUD:YES];
    
}
#pragma mark -
- (void)getNetDataWithHUD:(BOOL)flag{
    self.startNumber = [NSNumber numberWithInt:0];

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = RecommentGoodNetUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":@"0",@"rows":@"10"}];
    [requestInfo.getParams addEntriesFromDictionary:@{@"orderStr":self.selectSortStr}];
    if (self.sceneArray.count) {
        NSString *str = [self.sceneArray componentsJoinedByString:@","];
        [requestInfo.getParams addEntriesFromDictionary:@{@"scene":str}];
//        NSLog(@"scene =  %@",str);
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
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.model = model;
                weakSelf.startNumber = model.start;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                
                
                if (self.model.goodsTotal) {
                    [self.delegate changeTopNumberWithNumber:self.model.goodsTotal.integerValue index:0];
                }
                if (self.model.collocationTotal) {
                    [self.delegate changeTopNumberWithNumber:self.model.collocationTotal.integerValue index:1];
                }
                
                if (flag) {
                    [[HTUIHelper shareInstance]removeHUD];
                }
                [weakSelf.collectionView reloadData];
                if (model.data.count) {
                    weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextNetData];
                    }];
                }else{
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                }
            }else{
                if (flag) {
                    [[HTUIHelper shareInstance]removeHUD];
                }
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }else{
            if (flag) {
                [[HTUIHelper shareInstance]removeHUD];

            }
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            
        }
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [weakSelf.collectionView.mj_header endRefreshing];
        if (flag) {
            [[HTUIHelper shareInstance]removeHUD];
        }
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];
        
    }];


}
- (void)getNextNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = RecommentGoodNetUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@"10"}];
    [requestInfo.getParams addEntriesFromDictionary:@{@"orderStr":self.selectSortStr}];
    if (self.sceneArray.count) {
        NSString *str = [self.sceneArray componentsJoinedByString:@","];
        [requestInfo.getParams addEntriesFromDictionary:@{@"scene":str}];
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
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                [weakSelf.collectionView.mj_footer endRefreshing];
                
            }
            
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            [weakSelf.collectionView.mj_footer endRefreshing];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];
        [weakSelf.collectionView.mj_footer endRefreshing];
        
    }];
}


- (NSInteger)stCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  
    return self.dataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(STCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section {
    return 2;
}
- (UICollectionViewCell *)stCollectionView:(STCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeGoodListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommentGoodCell" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    cell.fatherViewControllerName = NSStringFromClass(self.class);
    
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
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    if (kind == UICollectionElementKindSectionHeader) {
//        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
//        view.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
//        return view;
//    }
//    return nil;
//}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
    CGFloat height = imageWid + 10 +15 + 69;
    return CGSizeMake(imageWid+10+10, height);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
//    return CGSizeMake(SCREEN_WIDTH, 10);
//}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark - HomeGoodListCollectionViewCellDelegate
- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    RJBaseGoodModel *model = self.dataArray[tag];
    NSNumber *goodId = (NSNumber *)model.goodId;
    
    NSString *trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    [[RJAppManager sharedInstance]trackingWithTrackingId:trackingId];
    

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = goodId;
    
//    HomeGoodListCollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:tag inSection:0]];
    
    goodsDetaiVC.zanBlock = ^(NSInteger buttonState){
        RJBaseGoodModel *model = self.dataArray[tag];
        model.isThumbsup = [NSNumber numberWithInteger:buttonState];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];
        //        [self.collectionView reloadData];
    };
    
    [self.fatherViewController.navigationController pushViewController:goodsDetaiVC animated:YES];
}
- (void)getNetData {
    [self getNetDataWithHUD:NO];
}
#pragma mark - FilterListViewDelegate
- (void)filiterDownWithDictionary:(NSMutableDictionary *)dic shouldReload:(BOOL)flag{
    
    self.filterDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (flag) {
        //重新请求数据
        //        [self.collectionView.header endRefreshing];
        //        [self.collectionView.footer endRefreshing];
//        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
        [self getNetDataWithHUD:YES];
        //        [self.collectionView.header beginRefreshing];
    }
}
#pragma mark - 点赞 喜欢
- (void)likeButtonAction:(UIButton *)sender{
//    NSLog(@"点赞");
    
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
        [HTUIHelper addHUDToView:self.view withString:@"Net Error" hideDelay:1];
        
    }];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[SDImageCache sharedImageCache]clearMemory];
    
    [MobClick beginLogPageView:@"穿衣助手推荐单品页面"];
    [TalkingData trackPageBegin:@"穿衣助手推荐单品页面"];

    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"穿衣助手推荐单品页面"];
    [TalkingData trackPageEnd:@"穿衣助手推荐单品页面"];

}
- (void)addGuideView{
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:RJFirstInChuanDa]) {
        GuideView *guidView = [[GuideView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        guidView.identifier = RJFirstInChuanDa;
        if (DEVICE_IS_IPHONE4) {
            guidView.localImage = @"chuanda_4";
        }
        if (DEVICE_IS_IPHONE5) {
            guidView.localImage = @"chuanda_5";
        }
        if (DEVICE_IS_IPHONE6) {
            guidView.localImage = @"chuanda_6";
        }
        if (DEVICE_IS_IPHONE6Plus) {
            guidView.localImage = @"chuanda_6p";
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:guidView];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RJFirstInChuanDa];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
}
@end
