
#import "SearchDetailForHeji.h"
#import "RJHomeItemTypeFourModel.h"

#import "CollectionsViewController.h"
#import "ThemeDetailVC.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ZanModel.h"
#import "CCMatchOrderView.h"
#import "RJHomeNewSubjectAndCollectionCell.h"

@interface SearchDetailForHeji ()<UITableViewDataSource,UITableViewDelegate,RJHomeNewSubjectAndCollectionCellDelegate, ThemeDetailVCDelegate,CCMatchOrderViewDelegate,RJTapedUserViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (assign, nonatomic) int pageNumber;

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;
//@property (assign, nonatomic) NSInteger  orderType;
@end

@implementation SearchDetailForHeji

//该方法为合辑详情VC的代理方法，应只考虑了首页的刷新，故方法名称只与首页相关，不影响代理方法实现
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    
    RJHomeItemTypeFourModel *model = self.dataArray[_indexPath.row];
    model.isThumbsup = [NSNumber numberWithBool:btnSelected];
    
    if (btnSelected) {
        
        model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
    }
    else {
        
        if (model.thumbsupCount.intValue <= 0) {
            
            model.thumbsupCount = [NSNumber numberWithInt:0];
        }
        else {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
        }
    }
    
    //局部刷新
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
}


- (void)viewDidLoad{
    [super viewDidLoad];
    [self setTitleImage:GetImage(@"collcctionshewhite")];
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    self.pageNumber = 0;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getCacheNetData];
        
    }];
    self.tableView.tableHeaderView = nil;
    [self.tableView.mj_header beginRefreshing];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MobClick beginLogPageView:@"搜索结果－合辑页面"];
    [TalkingData trackPageBegin:@"搜索结果－合辑页面"];


}
- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搜索结果－合辑页面"];
    [TalkingData trackPageEnd:@"搜索结果－合辑页面"];


    
}

/**
 *  缓存接口
 */
//start
- (void)getCacheNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    self.pageNumber = 0;

    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/theme/?pagenum=%d&pagesize=10&search=%@",_pageNumber, _searchWord];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                NSArray *itemList = responseObject[@"data"];
                
                if (itemList.count) {
                    //添加上拉加载更多
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getCacheNextPageData];
                    }];
                }
                
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                
                
                weakSelf.pageNumber += 1;
                [weakSelf.tableView reloadData];
            }else if (state.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
}
- (void)getCacheNextPageData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/theme/?pagenum=%d&pagesize=10&search=%@",_pageNumber, _searchWord];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                NSArray *itemList = responseObject[@"data"];
                if (![itemList isKindOfClass:[NSArray class]]) {
                    [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:1];
                    [weakSelf.tableView.mj_footer endRefreshing];
                    return ;
                }
                //没有数据了 关闭上拉加载更多
                if (![itemList count]) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                self.pageNumber += 1;
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
            }else if (state.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            
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
    
//    RJHomeSubjectAndCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchDetailForHejiCell"];
//    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
//    cell.model = model;
//    cell.delagate = self;
//    cell.buttonViewHieghtConstraint.constant = 0;
//    cell.buttonView.hidden = YES;
//    
//    cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
//    cell.likeButton.selected = model.isThumbsup.boolValue;
//    cell.likeButton.tag = indexPath.row;
//    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    cell.userDelegate = self;
//    return cell;
    
    RJHomeNewSubjectAndCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell"];
    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    //        cell.delagate = self;
    cell.buttonViewHieghtConstraint.constant = 35;
    cell.buttonView.hidden = NO;
    //        cell.userDelegate = self;
    cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
    cell.likeButton.selected = model.isThumbsup.boolValue;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    //    [cell.bigButton addTarget:self action:@selector(goSubjectListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    
    cell.trackingId = [NSString stringWithFormat:@"%@&%@&id=%@",NSStringFromClass(self.class),NSStringFromClass([RJHomeNewSubjectAndCollectionCell class]),model.id];
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
    
    CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell" configuration:^(RJHomeNewSubjectAndCollectionCell * cell) {
        cell.subjectDescLabel.text = model.memo;
        cell.buttonViewHieghtConstraint.constant = 35;
    }];
    return hei;
}

#pragma mark - RJHomeNewSubjectAndCollectionCellDelegate
- (void)collectionSelectWithId:(NSNumber *)number{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = number;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1029];
//    statisticalDataModel.entranceTypeId = number;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    
    RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
    vc.delegate = self;
    vc.themeItemId = model.id;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1028];
//    statisticalDataModel.entranceTypeId = model.id;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
//    vc.parameterDictionary = @{@"thememItemId":model.id};
    [self.navigationController pushViewController:vc animated:YES];

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


//点赞
- (void)likeButtonAction:(CCButton *)sender{

    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=theme_item"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];
    
    if (model.id) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.id}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                RJHomeItemTypeFourModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
                
            }
            
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:1];
        
    }];
    
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
@end
