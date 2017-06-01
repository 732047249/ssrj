//
//  SearchDetailForTopic.m
//  ssrj
//
//  Created by YiDarren on 16/12/20.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SearchDetailForTopic.h"
#import "HHTopicDetailViewController.h"
#import "CartViewController.h"
#import "ZanModel.h"
#import "HomeTopicTableViewCell.h"

@interface SearchDetailForTopic ()<UITableViewDelegate, UITableViewDataSource,RJTapedUserViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (assign, nonatomic) NSUInteger pageNumber;

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation SearchDetailForTopic

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    [_tableView registerNib:[UINib nibWithNibName:@"HomeTopicTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeTopicTableViewCell"];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [MobClick beginLogPageView:@"搜索－资讯列表"];
    [TalkingData trackPageBegin:@"搜索－资讯列表"];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"搜索－资讯列表"];
    [TalkingData trackPageEnd:@"搜索－资讯列表"];
    
}


- (void)getNetData {
    //TODO:必须使用已有模型 RJHomeTopicModel 获取数据，要求后台返回的数据格式及字段与 RJHomeTopicModel 内的相同
    
    //https://ssrj.com/b180/api/v1/solr/information?pagenum=1&pagesize=2&search=%E5%A4%96%E5%A5%97&token=0548d3e509cb4ef434cecf9620f39f34

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b180/api/v1/solr/information";
    
    _pageNumber = 1;
    [requestInfo.getParams addEntriesFromDictionary:@{@"pagenum":[NSNumber numberWithInteger:_pageNumber], @"pagesize":@"10", @"search":_searchWord}];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                NSArray *dataArr= responseObject[@"data"];
                if (dataArr.count) {
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextPageData];
                    }];
                    _pageNumber ++;
                    
                }
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in dataArr) {
                    RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [self.tableView reloadData];
                
            }else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}




- (void)getNextPageData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b180/api/v1/solr/information";
    
    [requestInfo.getParams addEntriesFromDictionary:@{@"pagenum":[NSNumber numberWithInteger:_pageNumber], @"pagesize":@"10", @"search":_searchWord}];
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.intValue == 0) {
                NSArray *dataArr= responseObject[@"data"];
                if (dataArr.count == 0) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                
                _pageNumber++;
                
                for (NSDictionary *dic in dataArr) {
                    RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [self.tableView reloadData];
                
            }else if (number.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        else{
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        [weakSelf.tableView.mj_footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}




#pragma mark -- delegate&dataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat imageHei = SCREEN_WIDTH/16*9;
    return imageHei + 6 + 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.dataArray.count == 0) {
        return SCREEN_HEIGHT*0.82;
    } else {
        return 0;
    }
}

//空时的UIImageView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*0.82)];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setFrame:CGRectMake(0, 0, 93, 108)];
    
    imageView.center = CGPointMake(SCREEN_WIDTH/2.0, view.frame.size.height/2.0);
    
    imageView.image = [UIImage imageNamed:@"gouwudai_empty"];
    
    [view addSubview:imageView];
    return view;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HomeTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTopicTableViewCell" forIndexPath:indexPath];
    //    cell.topView.hidden = YES;
    //    cell.topViewHeightConstraint.constant = 0;
    cell.topView.userInteractionEnabled = NO;
    RJHomeTopicModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.delegate = self;
    [cell.likeButton addTarget:self action:@selector(topicLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.tag = indexPath.row;
    cell.likeButton.titleLabel.text =[NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
    cell.likeButton.selected = model.isThumbsup.boolValue;
    cell.categoryView.hidden = YES;
    if (model.categoryId) {
        cell.categoryView.hidden = NO;
        cell.categoryNameLabel.text = model.categoryName;
    }
    return cell;
    
}

- (void)topicLikeButtonAction:(CCButton *)sender{
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=inform";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    __block RJHomeTopicModel *model = self.dataArray[sender.tag];
    if (model.id) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.informId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                RJHomeTopicModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
                
            }
            
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription]  hideDelay:1];
        
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    HHTopicDetailViewController *vc = [[HHTopicDetailViewController alloc]init];
//    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    RJTopicDetailViewController *vc = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicDetailViewController"];
    RJHomeTopicModel *model = self.dataArray[indexPath.row];
    vc.shareModel = model.inform;
    vc.informId = model.informId;
    vc.isThumbUp = model.isThumbsup;
    
    vc.zanBlock = ^(NSInteger state){
        model.isThumbsup = [NSNumber numberWithInteger:state];
        if (model.isThumbsup.boolValue) {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue+1];
        } else {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue-1];
            if (model.thumbsupCount.intValue<0) {
                
                model.thumbsupCount = [NSNumber numberWithInt:0];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    };
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1036];
//    statisticalDataModel.entranceTypeId = model.informId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
    
    
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark -
#pragma mark RJTapedUserViewDelegate
- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString*)userName{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!userId) {
        return;
    }
    rootVc.userId = userId;
    rootVc.userName = userName;
    
    [self.navigationController pushViewController:rootVc animated:YES];
}








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
