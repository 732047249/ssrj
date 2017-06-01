//
//  HHInforMatchController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforMatchController.h"
#import "HHInforMatchSearchController.h"
#import "HHInformationViewController.h"
#import "HHInforSearchGoodsOrMatchView.h"
#import "RJHomeItemTypeTwoModel.h"
#import "HHInforMatchCell.h"
#import "UIImage+New.h"
#import "Masonry.h"

static NSString *const currentUrlSting = @"/b180/api/v2/content/publish/collocation/list/order-chosen/";

@interface HHInforMatchController ()<UITableViewDelegate,UITableViewDataSource,HHInforSearchGoodsOrMatchViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) HHInforSearchGoodsOrMatchView *searchView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation HHInforMatchController
{
    int page_index;
    int page_size;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"创建资讯-插入搭配页面"];
    [TalkingData trackPageBegin:@"创建资讯-插入搭配页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建资讯-插入搭配页面"];
    [TalkingData trackPageEnd:@"创建资讯-插入搭配页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    page_size = 20;
    [self configSearchView];
    [self configTableView];
    
}
- (void)configSearchView {
    _searchView = [[HHInforSearchGoodsOrMatchView alloc] init];
    _searchView.delegate = self;
    _searchView.placeHolder = @"搜索您想要的搭配";
    [self.view addSubview:_searchView];
    [_searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
}

- (void)configTableView {
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_searchView.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];
    __weak __typeof(&*self)weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [_tableView.mj_header beginRefreshing];
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getNextPageData];
    }];
    [_tableView.mj_footer setAutomaticallyHidden:YES];
}
/**
 https://ssrj.com/b180/api/v1/content/publish/collocation/list/order-chosen/?appVersion=2.2.0&page_index=1&page_size=10&token=daf1a91acee1be236510cc2bd1873b49
 */
- (void)getNetData{
    page_index = 1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = currentUrlSting;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(page_size) forKey:@"page_size"];
    [dict setObject:@(page_index) forKey:@"page_index"];
    requestInfo.getParams = dict;
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                
                [weakSelf.dataArray removeAllObjects];
                NSArray *itemList = responseObject[@"data"];
                page_index += 1;
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
                
                if (weakSelf.dataArray.count < page_size) {
                    [weakSelf.tableView.mj_footer setHidden:YES];
                }else {
                    [weakSelf.tableView.mj_footer resetNoMoreData];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
}
- (void)getNextPageData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = currentUrlSting;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(page_size) forKey:@"page_size"];
    [dict setObject:@(page_index) forKey:@"page_index"];
    requestInfo.getParams = dict;
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *itemList = responseObject[@"data"];
                page_index += 1;
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
                if (itemList.count < page_size) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }else {
                    [weakSelf.tableView.mj_footer endRefreshing];
                }
                
            }else{
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            [weakSelf.tableView.mj_footer endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.tableView.mj_footer endRefreshing];
        
    }];
}

#pragma mark - tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHInforMatchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.section];
    if (!cell) {
        cell = [[HHInforMatchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.model = model;
    cell.trackingId = [NSString stringWithFormat:@"HHInforMatchController&HHInforMatchCell&id=%@",model.id];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return kScreenWidth + (kScreenWidth / 3.0 + 59);
    
    
//    if (indexPath.row == self.dataArray.count - 1) {
//        return kScreenWidth + (kScreenWidth / 3.0 + 59);
//    }
//    //大图 + 单品 + 灰色空白区
//    return kScreenWidth + (kScreenWidth / 3.0 + 59) + 10;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImage *image = [UIImage captureWithView:cell];
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[HHInformationViewController class]]) {
            HHInformationViewController *infor = (HHInformationViewController *)vc;
            HHImageStyle *style = [HHImageStyle imageStyleWithType:HHImageStyleTypeMatch];
            RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.section];
            style.ID = [model.id intValue];
            style.image = image;
            [infor insertImageWithImageStyle:style];

            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}
#pragma mark - 点击searchView
- (void)didClickSearchView {
    HHInforMatchSearchController *search = [[HHInforMatchSearchController alloc] init];
    [self.navigationController pushViewController:search animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
