//
//  CategoryFenLeiViewController.m
//  ssrj
//
//  Created by MFD on 16/5/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CategoryFenLeiViewController.h"
#import "categoryTableViewCell.h"
#import "GoodsDetailViewController.h"
#import "HomeGoodListViewController.h"
#import "CollectionsViewController.h"
#import "RJCategoryModel.h"
#import "ThemeDetailVC.h"
#import "MFDMineOrdersViewController.h"
#import "SearchGoodsViewController.h"


static NSString *CellID = @"CellID";
@interface CategoryFenLeiViewController ()<UITabBarDelegate,UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) UIView *searchBgView;

@end

@implementation CategoryFenLeiViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"分类页面"];
    [TalkingData trackPageBegin:@"分类页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"分类页面"];
    [TalkingData trackPageEnd:@"分类页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray array];
    [self.tableView registerClass:[categoryTableViewCell class] forCellReuseIdentifier:CellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
//    self.tableView.tableHeaderView = _searchBgView;
    
    [self.view addSubview:self.tableView];
    __weak __typeof(&*self)weakSelf = self;
    
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    [self.tableView.mj_header beginRefreshing];
    
}
- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    requestInfo.URLString = @"api/v5/product/listProductCategory.jhtml";
//    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [RJCategoryModel class];

    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
//            NSLog(@"------%@",responseObject);
            RJCategoryModel *model = responseObject;
//            if ([model.msg isEqualToString:@"请求成功"]) {
            if (model.state.intValue == 0) {
                
                [weakSelf.dataArray removeAllObjects];
                weakSelf.dataArray = [NSMutableArray arrayWithArray:[model.data copy]];
                [weakSelf.tableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];

    }];
}

#pragma mark --UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    categoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    RJCategoryItemModel *model = self.dataArray[indexPath.row];
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.itemId.intValue];
    
    if (indexPath.row %2 == 0) {
        if (indexPath.row == 0) {
            cell.categoryLabel.frame = CGRectMake(0, 150/2-30, SCREEN_WIDTH, 30);
            cell.categoryLabel.text = model.name;
            cell.engCategoryLabel.text = model.nameen;
            cell.engCategoryLabel.frame = CGRectMake(0, 150/2, SCREEN_WIDTH, 30);
        }else{
            cell.categoryLabel.frame = CGRectMake(0, 150/2-30, SCREEN_WIDTH/2, 30);
            cell.categoryLabel.text = model.name;
            cell.engCategoryLabel.text = model.nameen;
            cell.engCategoryLabel.frame = CGRectMake(0, 150/2, SCREEN_WIDTH/2, 30);
        }
    }else{
        
        cell.categoryLabel.frame = CGRectMake(SCREEN_WIDTH/2, 150/2-30, SCREEN_WIDTH/2, 30);
        cell.categoryLabel.text = model.name;
        cell.engCategoryLabel.text = model.nameen;
        cell.engCategoryLabel.frame = CGRectMake(SCREEN_WIDTH/2, 150/2, SCREEN_WIDTH/2, 30);

    }
//    cell.picture.image = [UIImage imageNamed:[NSString stringWithFormat:@"分类_0%ld",indexPath.row]];
    [cell.picture sd_setImageWithURL:[NSURL URLWithString:model.categoryImg1] placeholderImage:GetImage(@"640X425")];

    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeGoodListViewController *goodListVc = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
    RJCategoryItemModel *model = self.dataArray[indexPath.row];

    NSDictionary *dic = @{@"classifys":model.itemId};
    goodListVc.parameterDictionary = [dic copy];
    goodListVc.titleStr = model.name;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodListVc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1021];
//    statisticalDataModel.entranceTypeId = [dic objectForKey:@"classifys"];
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:goodListVc animated:YES];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull categoryTableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{

    [cell cellOffset];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray<categoryTableViewCell *> *array =  [self.tableView visibleCells];
    [array enumerateObjectsUsingBlock:^(categoryTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cellOffset];
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return  150;
}
/**
 *  添加搜索入口
 */

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    _searchBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _searchBgView.backgroundColor = [UIColor whiteColor];

    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(8, 5, SCREEN_WIDTH - 16, 30)];
    searchView.layer.cornerRadius = 5.0;
    searchView.layer.masksToBounds = YES;
    searchView.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    
    UILabel *searchLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 150, 30)];
    searchLabel.center = CGPointMake(SCREEN_WIDTH/2, 20);
    CGRect rect = searchLabel.frame;
    rect.size.height = 20;
    searchLabel.frame = rect;
    searchLabel.text = @"搜索单品、搭配、合辑、资讯";
    searchLabel.font = [UIFont systemFontOfSize:13];
    searchLabel.textColor = [UIColor lightGrayColor];
    searchLabel.textAlignment = NSTextAlignmentLeft;
    
    [searchView addSubview:searchLabel];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-95, 8, 15, 15)];
    imageView.image = [UIImage imageNamed:@"sousuo_gray"];
    [searchView addSubview:imageView];
    
    [_searchBgView addSubview:searchView];
    
    UIButton *topButton = [UIButton buttonWithType:UIButtonTypeCustom];
    topButton.frame = _searchBgView.frame;
    [_searchBgView addSubview:topButton];
    [topButton addTarget:self action:@selector(topButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    topButton.trackingId = [NSString stringWithFormat:@"%@&topButton",NSStringFromClass([self class])];
    
    return _searchBgView;
}

- (void)topButtonClicked {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    SearchGoodsViewController *searchVC = [story instantiateViewControllerWithIdentifier:@"SearchGoodsViewController"];
    
    [self.navigationController pushViewController:searchVC animated:YES];
}

@end
