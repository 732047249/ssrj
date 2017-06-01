
#import "HomeGoodListViewController.h"
#import "HomeGoodListCollectionViewCell.h"
#import "XLPlainFlowLayout.h"
#import "GoodsListModel.h"
#import "RJGoodDetailModel.h"
#import "GoodsDetailViewController.h"
#import "DOPDropDownMenu.h"
#import "FilterNavigationController.h"
#import "FilterListViewController.h"
#import "ZanModel.h"
#import "CCFirstInView.h"
/**
 *  上方banner的显示状态
 */
typedef NS_ENUM(NSInteger,BannerType) {
    /**
     *  不显示
     */
    RJNoneBannerType = 0,
    /**
     *  分类  640 x 200
     */
    RJCategoryBannerType =1 ,
    /**
     *  品牌 640 x 270
     */
    RJBrandBannerType = 2,
};

@interface HomeGoodListViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,FilterListViewDelegate,HomeGoodListCollectionViewCellDelegate,CCGoodOrderViewDelegate>
//DOPDropDownMenuDelegate 
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) GoodsListModel * model;
@property (strong, nonatomic) NSNumber * startNumber;
@property (strong, nonatomic) NSMutableArray * sortArray;
@property (strong, nonatomic) NSMutableArray * filterArray;
//@property (nonatomic, strong) DOPDropDownMenu *menu;
@property (strong, nonatomic) RJSorteModel * selectSortModel;
@property (strong, nonatomic) FilterNavigationController * filterViewController;
@property (strong, nonatomic) GoodListCollectionBannerView * bannerView;
@property (assign, nonatomic) BannerType  bannerType;
/**
 *  筛选传递的参数
 */
@property (strong, nonatomic) NSMutableDictionary *filterDictionary;
@property (strong, nonatomic) NSString * selectSortStr;
@property (nonatomic,strong) CCFirstInView *firstInView;
@end

@implementation HomeGoodListViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    [self addBarButtonItem:RJNavCartButtonItem onSide:RJNavRightSide];
    [self setTitle:self.titleStr?:@"单品" tappable:NO];
    NSArray *btnArray = @[@1];
    [self addBarButtonItems:btnArray onSide:RJNavRightSide];
    
    
    
    self.dataArray = [NSMutableArray array];
    
    self.filterDictionary  = [NSMutableDictionary dictionary];
    
    [self.filterDictionary addEntriesFromDictionary:@{@"Category":[NSMutableArray array],
                                                      @"Brand":[NSMutableArray array],
                                                      @"Price":[NSMutableArray array],
                                                      @"Color":[NSMutableArray array]}];
    self.bannerType = RJNoneBannerType;

  
//    NSArray *arr1 = @[@"默认",@"最新",@"综合排序",@"按价格升序",@"按价格降序",@"按上架时间升序",@"按上架时间降序"];
//    NSArray *arr2 = @[@"goodsOrder_desc",@"createDate_desc",@"isTop_desc",@"price_asc",@"price_desc",@"upTime_asc",@"upTime_desc"];
//    NSMutableArray *arr = [NSMutableArray array];
//    
//    [arr1 enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        RJSorteModel *model = [[RJSorteModel alloc]initWithName:arr1[idx] value:arr2[idx]];
//        [arr addObject:model];
//    }];
    self.sortArray = [NSMutableArray arrayWithObjects:@"goodsOrder_desc",@"promotionPrice_asc",@"promotionPrice_desc",@"goodsOrder3_desc", nil];
//    self.selectSortModel = self.sortArray[0];
    
    self.selectSortStr = self.sortArray[0];
    if (self.isHot) {
        self.selectSortStr =  self.sortArray.lastObject;
    }
//    self.filterArray = [NSMutableArray arrayWithArray:@[@"筛选"]];
    
    
    __weak __typeof(&*self)weakSelf = self;

    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    [self.collectionView.mj_header beginRefreshing];
    



}
- (void)addGuideView{
    if (![[NSUserDefaults standardUserDefaults]boolForKey:RJFirstInGoodList]) {
        NSMutableArray *arr = [NSMutableArray array];
        if (DEVICE_IS_IPHONE4) {
            [arr addObject:@"danpin1_4"];
            [arr addObject:@"danpin2_4"];
        }
        if (DEVICE_IS_IPHONE5) {
            [arr addObject:@"danpin1_5"];
            [arr addObject:@"danpin2_5"];
        }
        if (DEVICE_IS_IPHONE6) {
            [arr addObject:@"danpin1_6"];
            [arr addObject:@"danpin2_6"];
        }
        if (DEVICE_IS_IPHONE6Plus) {
            [arr addObject:@"danpin1_6p"];
            [arr addObject:@"danpin2_6p"];
        }
        self.firstInView = [[CCFirstInView alloc]initWithImageArray:arr localIdentify:RJFirstInGoodList];
        [self.firstInView show];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[SDImageCache sharedImageCache]clearMemory];
    
    [MobClick beginLogPageView:@"单品列表页面"];
    [TalkingData trackPageBegin:@"单品列表页面"];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"单品列表页面"];
    [TalkingData trackPageEnd:@"单品列表页面"];

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

    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [self addGuideView];
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.model = model;
                weakSelf.startNumber = model.start;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                _bannerType = RJNoneBannerType;
                if (model.categoryImg2.length) {
                    _bannerType = RJCategoryBannerType;
                    
                }else if (model.brandImg2.length){
                    _bannerType = RJBrandBannerType;
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
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUD];

            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];

        }
        
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];

        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];

    }];
    
}
- (void)getNextNetData{

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"api/v5/product/list.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@"10",@"orderStr":self.selectSortStr}];
    
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
    HomeGoodListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%@",NSStringFromClass([self class]),model.goodId];
    cell.likeButton.trackingId = [NSString stringWithFormat:@"%@&likeButton&id:%@",NSStringFromClass([self class]),model.goodId];
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

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        GoodListCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerID" forIndexPath:indexPath];
        
       
//        if (!self.menu) {
//            DOPDropDownMenu *menu = [[DOPDropDownMenu alloc] initWithOrigin:CGPointMake(0, 0) andHeight:50];
//            menu.dataSource = self;
//            menu.delegate = self;
//            [header addSubview:menu];
//            self.menu = menu;
////            self.menu.customSuperView = self.view;
////            self.menu.customHeaderView = self.collectionView;
//            self.menu.customSuperView = self.collectionView;
//            self.menu.customSuperSuperView = self.view;
//        }
        
        header.orderView.delegate = self;
        [header.orderView.filterButton addTarget:self action:@selector(filterButtonTapAction) forControlEvents:UIControlEventTouchUpInside];
        header.orderView.buttonOne.trackingId = [NSString stringWithFormat:@"%@&orderView&buttonOne",NSStringFromClass(self.class)];
        header.orderView.buttonTwo.trackingId = [NSString stringWithFormat:@"%@&orderView&buttonTwo",NSStringFromClass(self.class)];
        header.orderView.buttonThree.trackingId = [NSString stringWithFormat:@"%@&orderView&buttonThree",NSStringFromClass(self.class)];
        header.orderView.filterButton.trackingId = [NSString stringWithFormat:@"%@&orderView&filterButton",NSStringFromClass(self.class)];
        if (self.isHot) {
            header.orderView.buttonThree.selected = YES;
            header.orderView.buttonOne.selected = NO;
            
            self.isHot = NO;
        }
        return header;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        //banner图
        if (!_bannerView) {
            self.bannerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"BannerView" forIndexPath:indexPath];
        }
        if (self.bannerType == RJBrandBannerType) {
            [self.bannerView.bannerView sd_setImageWithURL:[NSURL URLWithString:self.model.brandImg2] placeholderImage:GetImage(@"640X200")];
        }else if(self.bannerType == RJCategoryBannerType){
            [self.bannerView.bannerView sd_setImageWithURL:[NSURL URLWithString:self.model.categoryImg2]placeholderImage:GetImage(@"640X200")];
        }
        return _bannerView;
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return CGSizeZero;
    }
    return CGSizeMake(SCREEN_WIDTH, 44);
   
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (section == 0) {
        if (self.bannerType == RJNoneBannerType) {
            return CGSizeZero;
        }
        if (self.bannerType == RJCategoryBannerType) {
            return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH/64 *20);
        }
        if (self.bannerType == RJBrandBannerType) {
            return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH/64 *27);
        }
    }
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
    CGFloat height = imageWid + 10 +15 + 69;
    return CGSizeMake(imageWid+10+10, height);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    RJBaseGoodModel *model = self.dataArray[indexPath.row];
//    NSNumber *goodId = (NSNumber *)model.goodId;
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
//    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
//    goodsDetaiVC.goodsId = goodId;
// 
//    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    RJBaseGoodModel *model = self.dataArray[tag];
    NSNumber *goodId = (NSNumber *)model.goodId;
    
    /**
     *  3.0.0 此处添加你想统计的打点事件 上报服务器id
     */
    NSString * trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    
    [[RJAppManager sharedInstance]trackingWithTrackingId:trackingId];

    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = goodId;
    
    goodsDetaiVC.zanBlock = ^(NSInteger buttonState){
        RJBaseGoodModel *model = self.dataArray[tag];
        model.isThumbsup = [NSNumber numberWithInteger:buttonState];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:1]]];
    };
    
    
//    /**
//     *  add 12.19 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:0];
//    
//
//    NSNumber *tagsId = [_parameterDictionary objectForKey:@"tagsId"];
//    NSNumber *classifys = [_parameterDictionary objectForKey:@"classifys"];
//    NSNumber *brands = [_parameterDictionary objectForKey:@"brands"];
//
//    if (tagsId) {
//        statisticalDataModel.entranceType = tagsId;
//    }
//    
//    else if (classifys) {
//        statisticalDataModel.entranceType = classifys;
//    }
//    
//    else if (brands) {
//        statisticalDataModel.entranceType = brands;
//    }
//    
//    statisticalDataModel.entranceTypeId = goodId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
#pragma mark - 点赞 喜欢
- (void)likeButtonAction:(UIButton *)sender{
//    NSLog(@"商品点赞");
    
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
                
                [weakSelf.dataArray removeObjectAtIndex:sender.tag];
                
                [weakSelf.dataArray insertObject:model atIndex:sender.tag];
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:1]]];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:weakSelf.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"]  hideDelay:1];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        
    }];
    
}


#pragma mark - DorpMenuDelegate &DataSource
//- (NSInteger)numberOfColumnsInMenu:(DOPDropDownMenu *)menu {
//    return 2;
//}
//
//
//- (NSInteger)menu:(DOPDropDownMenu *)menu numberOfRowsInColumn:(NSInteger)column {
//    if (column == 0) {
//        return self.sortArray.count;
//    }
//    return self.filterArray.count;
//}
//- (NSString *)menu:(DOPDropDownMenu *)menu titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
//    if (indexPath.column == 0) {
//        RJSorteModel *model = self.sortArray[indexPath.row];
//        return model.name;
//    }
//    return self.filterArray[indexPath.row];
//}
//- (void)dismiss:(UIBarButtonItem *)sender {
//    [self.menu dismiss];
//}
//- (void)menu:(DOPDropDownMenu *)menu didSelectRowAtIndexPath:(DOPIndexPath *)indexPath{
//    RJSorteModel *model = self.sortArray[indexPath.row];
////    NSLog(@"%@",model);
//    self.selectSortModel = model;
//    [self.collectionView.mj_header beginRefreshing];
//}


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
#pragma mark - FilterListViewDelegate
- (void)filiterDownWithDictionary:(NSMutableDictionary *)dic shouldReload:(BOOL)flag{
    
    self.filterDictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (flag) {
        //重新请求数据
//        [self.collectionView.header endRefreshing];
//        [self.collectionView.footer endRefreshing];
        [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
        [self getNetData];
//        [self.collectionView.header beginRefreshing];
    }
}



@end





@implementation GoodListCollectionHeaderView
-(void)awakeFromNib{
    [super awakeFromNib];
}


@end


@implementation GoodListCollectionBannerView
-(void)awakeFromNib{
    [super awakeFromNib];
}


@end

@implementation RJSorteModel

-(instancetype)initWithName:(NSString *)name value:(NSString *)value{
    self = [super init];
    if (self) {
        self.name = name;
        self.value = value;
    }
    return self;
}

@end
