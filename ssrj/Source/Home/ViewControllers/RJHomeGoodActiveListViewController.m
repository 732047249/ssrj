
#import "RJHomeGoodActiveListViewController.h"
#import "HomePageFourCell.h"
#import "HomeGoodListViewController.h"
#import "RJBrandDetailRootViewController.h"
#import "GoodsDetailViewController.h"

NSString *const currentUrlString2 = @"/b82/api/v5/index/selectGoods";
//NSString *const currentUrlString = @"/b82/api/v5/index/homeindex";

@interface RJHomeGoodActiveListViewController ()<UITableViewDataSource,UITableViewDelegate,HomePageFourCellDelegate>{
    NSInteger pageIndex;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray * dataArray;

@end

@implementation RJHomeGoodActiveListViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    [self setTitle:@"当季流行"];
    self.dataArray = [NSMutableArray array];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}
- (void)getNetData{
    pageIndex = 1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = currentUrlString2;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"useFor":@"app",@"pageIndex":[NSNumber numberWithInteger:pageIndex],@"pageSize":@"10"}];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.intValue == 0) {
                NSDictionary *data = responseObject[@"data"];
                NSArray *homeList = data[@"homeList"];
                if (homeList.count) {
                    //添加上拉加载更多
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextPageData];
                    }];
                }
                pageIndex += 1;
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary * dic in homeList) {
                    NSNumber *type = [dic objectForKey:@"type"];
                    if (![type isKindOfClass:[NSNumber class]]) {
                        continue;
                    }
                    if (type.intValue == 0) {
                        RJHomeItemTypeZeroModel *model = [[RJHomeItemTypeZeroModel alloc]initWithDictionary:dic[@"data"] error:nil];
                        if (model) {
                            [weakSelf.dataArray addObject:model];
                        }

                    }
                }
                [weakSelf.tableView reloadData];

            }else if(number.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
        [weakSelf.tableView.mj_header endRefreshing];

    }];

}
- (void)getNextPageData{

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = currentUrlString2;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"useFor":@"app",@"pageIndex":[NSNumber numberWithInteger:pageIndex],@"pageSize":@"10"}];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.intValue == 0) {
                NSDictionary *data = responseObject[@"data"];
                NSArray *homeList = data[@"homeList"];
                if (!homeList.count) {
                    //添加上拉加载更多
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                pageIndex += 1;
                for (NSDictionary * dic in homeList) {
                    NSNumber *type = [dic objectForKey:@"type"];
                    if (![type isKindOfClass:[NSNumber class]]) {
                        continue;
                    }
                    if (type.intValue == 0) {
                        RJHomeItemTypeZeroModel *model = [[RJHomeItemTypeZeroModel alloc]initWithDictionary:dic[@"data"] error:nil];
                        if (model) {
                            [weakSelf.dataArray addObject:model];
                        }
                        
                    }
                }
                [weakSelf.tableView reloadData];
                
            }else if(number.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        [weakSelf.tableView.mj_footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
        [weakSelf.tableView.mj_footer endRefreshing];
        
    }];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HomePageFourCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomePageFourCell"];
    RJHomeItemTypeZeroModel *model = self.dataArray[indexPath.row];
    cell.fatherViewClassName = NSStringFromClass(self.class);
    cell.delegate = self;
    cell.model = model;
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageHei = SCREEN_WIDTH/16.0*9.0;
    CGFloat collectionViewHei = SCREEN_WIDTH/320 *114+8+8;
    return imageHei + collectionViewHei +65 + 5;
}
#pragma mark - HomePageFourCellDelegate
- (void)bigImageTapedWithDic:(NSDictionary *)dic{
    
    [self pushToGoodListWithDictionary:dic];
    
}
- (void)bigImageBrandTapedWithDic:(NSDictionary *)dic brandId:(NSNumber *)brandid{
    [self pushToNewBrandDetailWithDictionary:dic brandId:brandid];
}
- (void)collectionTapedWithGoodId:(NSString *)goodId{

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    NSNumber *goodId2 = [NSNumber numberWithInteger:goodId.integerValue];
    goodsDetaiVC.goodsId = goodId2;
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
#pragma mark - ========去往商品列表界面 传递参数============
- (void)pushToGoodListWithDictionary:(NSDictionary *)dic{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    HomeGoodListViewController *goodListVc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
    goodListVc.parameterDictionary = [dic copy];
    
    
    
    [self.navigationController pushViewController:goodListVc animated:YES];
}
- (void)pushToGoodListWithDictionary:(NSDictionary *)dic title:(NSString *)title{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    HomeGoodListViewController *goodListVc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
    goodListVc.parameterDictionary = [dic copy];
    if (title) {
        goodListVc.titleStr = title;
    }
    
    [self.navigationController pushViewController:goodListVc animated:YES];
}
#pragma mark - ===========去往新的品牌界面========
- (void)pushToNewBrandDetailWithDictionary:(NSDictionary *)dic brandId:(NSNumber *)brandid{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
    rootVc.parameterDictionary = dic;
    rootVc.brandId = brandid;
    
    [self.navigationController pushViewController:rootVc  animated:YES];
}

@end
