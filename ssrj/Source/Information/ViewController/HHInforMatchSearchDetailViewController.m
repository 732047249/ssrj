//
//  HHInforMatchSearchDetailViewController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforMatchSearchDetailViewController.h"
#import "HHInformationViewController.h"
#import "UIImage+New.h"
#import "RJHomeItemTypeTwoModel.h"
#import "HHInforMatchCell.h"
#import "Masonry.h"

static NSString *const searchUrl = @"/b180/api/v1/goodsinfor/collocation_search";

@interface HHInforMatchSearchDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation HHInforMatchSearchDetailViewController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MobClick beginLogPageView:@"创建资讯-搭配搜索详情页面"];
    [TalkingData trackPageBegin:@"创建资讯-搭配搜索详情页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建资讯-搭配搜索详情页面"];
    [TalkingData trackPageEnd:@"创建资讯-搭配搜索详情页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    self.title = self.searchName;
    [self addBackButton];
    [self configTableView];
}

- (void)configTableView {
    _tableView = [[UITableView alloc]init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    __weak __typeof(&*self)weakSelf = self;
    _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [_tableView.mj_header beginRefreshing];
}
- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = searchUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                            @"name" : self.searchName}];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                
                [weakSelf.dataArray removeAllObjects];
                NSArray *itemList = responseObject[@"data"];
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
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

#pragma mark - tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHInforMatchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    if (!cell) {
        cell = [[HHInforMatchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.model = model;
    cell.trackingId = [NSString stringWithFormat:@"HHInforMatchSearchDetailViewController&HHInforMatchCell&id=%@",model.id];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImage *image = [UIImage captureWithView:cell];
    for (UIViewController * vc in self.navigationController.viewControllers) {
        if ([vc isKindOfClass:[HHInformationViewController class]]) {
            HHInformationViewController *infor = (HHInformationViewController *)vc;
            HHImageStyle *style = [HHImageStyle imageStyleWithType:HHImageStyleTypeMatch];
            RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
            style.ID = [model.id intValue];
            style.image = image;
            [infor insertImageWithImageStyle:style];
            [self.navigationController popToViewController:vc animated:YES];
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.dataArray.count - 1) {
        return kScreenWidth + (kScreenWidth / 3.0 + 59) + 1;
    }
    //大图 + 单品 + 灰色空白区
    return kScreenWidth + (kScreenWidth / 3.0 + 59) + 10;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
