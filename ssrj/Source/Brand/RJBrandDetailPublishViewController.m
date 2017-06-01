
#import "RJBrandDetailPublishViewController.h"
#import "RJHomeCollectionAndGoodCell.h"
#import "HomeTopicTableViewCell.h"
#import "RJHomeActivityTableViewCell.h"


#import "RJHomeTopicModel.h"
#import "RJHomeWebActivityModel.h"
#import "UITableView+FDTemplateLayoutCell.h"


#import "CollectionsViewController.h"
#import "ThemeDetailVC.h"
#import "RJWebViewController.h"
#import "HHTopicDetailViewController.h"
#import "ZanModel.h"
#import "GoodsDetailViewController.h"
#import "RJDiscoveryThemeViewController.h"

#import "RJDiscoveryMatchViewController.h"

#import "RJTopicListViewController.h"
#import "RJBrandDetailRootViewController.h"
#import "RJHomeNewSubjectAndCollectionCell.h"

#define CurrentUrlString @"/b82/api/v5/brand/findbranddynamic"

@interface RJBrandDetailPublishViewController ()<RJHomeCollectionAndGoodCellDelegate,ThemeDetailVCDelegate,CollectionsViewControllerDelegate,RJHomeNewSubjectAndCollectionCellDelegate,RJTapedUserViewDelegate>
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (assign, nonatomic) NSInteger pageIndex;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UIView *emptyFooterView;

@end

@implementation RJBrandDetailPublishViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    //HomeTopicTableViewCell4
    /**
     *  注册Xib
     */
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeTopicTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeTopicTableViewCell4"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"RJHomeCollectionAndGoodCell" bundle:nil] forCellReuseIdentifier:@"RJHomeCollectionAndGoodCell4"];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
    [HTUIHelper addHUDToWindowWithString:@"加载中..."];
 
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"品牌的发布界面"];
    [TalkingData trackPageBegin:@"品牌的发布界面"];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"品牌的发布界面"];
    [TalkingData trackPageEnd:@"品牌的发布界面"];

}
- (void)getNetData{
  
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    __weak __typeof(&*self)weakSelf = self;
    self.pageIndex = 1;
    requestInfo.URLString = CurrentUrlString;
    
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"useFor":@"app",@"pageIndex":[NSNumber numberWithInteger:_pageIndex],@"pageSize":@"10",@"appVersion":VERSION,@"type":@"brand"}];
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.brandId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.brandId}];
    }
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [HTUIHelper removeHUDToWindow];
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *homeList = responseObject[@"data"];
                if (homeList.count) {
                    //添加上拉加载更多
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextPageData];
                    }];
                    weakSelf.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 5)];
                }
                _pageIndex += 1;
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary * dic in homeList) {
                    NSNumber *type = [dic objectForKey:@"type"];
                    if (![type isKindOfClass:[NSNumber class]]) {
                        continue;
                    }
                    switch (type.intValue) {
                          /**
                             *  资讯文章
                             */
                        case 1:{
                            
                            RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                            
                        case 2:{
                            RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 4:{
                            RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 6:{
                            /**
                             *  首页Cell展示H5活动 分享链接固定
                             */
                            RJHomeWebActivityModel *model = [[RJHomeWebActivityModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 7:{
                            /**
                             *  首页展示类似闺蜜节活动 分享链接私有 需要用户登录去调用接口获取分享链接
                             */
                            
                        }
                            break;
                        default:
                            break;
                    }
                }
                [weakSelf.tableView reloadData];
                
                
            }else{
                [HTUIHelper addHUDToWindowWithString:responseObject[@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToWindowWithString:@"error" hideDelay:1];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper removeHUDToWindow];
        [HTUIHelper addHUDToWindowWithString:@"error" hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];

    
}
-(void)getNextPageData{
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = CurrentUrlString;
//#warning debug
//    requestInfo.URLString = @"http://192.168.1.106/api/v4/brand/findbranddynamic";
//    self.brandId = @107;
    
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"useFor":@"app",@"pageIndex":[NSNumber numberWithInteger:_pageIndex],@"pageSize":@"10",@"appVersion":VERSION,@"type":@"brand"}];
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.brandId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.brandId}];
    }
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *homeList = responseObject[@"data"];
                /**
                 *  没有更多数据了 关闭上拉加载更多
                 */
                if (!homeList.count) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return;
                }
                _pageIndex += 1;
                for (NSDictionary * dic in homeList) {
                    NSNumber *type = [dic objectForKey:@"type"];
                    if (![type isKindOfClass:[NSNumber class]]) {
                        continue;
                    }
                    switch (type.intValue) {
                            
                        case 1:{
                            
                            RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 2:{
                            RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 4:{
                            RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 6:{
                            /**
                             *  首页Cell展示H5活动 分享链接固定
                             */
                            RJHomeWebActivityModel *model = [[RJHomeWebActivityModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 7:{
                            /**
                             *  首页展示类似闺蜜节活动 分享链接私有 需要用户登录去调用接口获取分享链接
                             */
                            
                        }
                            break;
                        default:
                            break;
                    }
                }
                [weakSelf.tableView reloadData];
                
            }else{
                [HTUIHelper addHUDToWindowWithString:responseObject[@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToWindowWithString:@"error" hideDelay:1];
        }
        [weakSelf.tableView.mj_footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToWindowWithString:@"error" hideDelay:1];
        [weakSelf.tableView.mj_footer endRefreshing];
        
    }];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.dataArray[indexPath.row];

    /**
     *  主题带搭配Cell
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {

        RJHomeNewSubjectAndCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell"];
        cell.fatherViewControllerName = @"RJBrandDetailPublishViewController";
        RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
        cell.model = model;
        cell.buttonViewHieghtConstraint.constant = 35;
        cell.buttonView.hidden = NO;
        cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        cell.likeButton.tag = indexPath.row;
        [cell.likeButton addTarget:self action:@selector(subjectLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.bigButton addTarget:self action:@selector(goSubjectListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.delegate = self;
        return cell;
    }
    /**
     *  搭配带单品Cell
     */
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]) {

        RJHomeCollectionAndGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeCollectionAndGoodCell4"];
        cell.fatherViewControllerName = @"RJBrandDetailPublishViewController";
        cell.topViewHieghtConstraint.constant = 35;
        cell.topView.hidden = NO;
        [cell layoutSubviews];
        RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
        cell.model = model;
        cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        cell.likeButton.tag = indexPath.row;
        [cell.likeButton addTarget:self action:@selector(collectionLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.delegate = self;
        [cell.topViewButton addTarget:self action:@selector(goCollectionListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.userDelegate = self;
        return cell;
        
    }
    /**
     *  资讯Cell
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        HomeTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTopicTableViewCell4"];
        cell.fatherViewControllerName = @"RJBrandDetailPublishViewController";
        cell.topView.hidden = NO;
        cell.topViewHeightConstraint.constant = 35;
        [cell.topView layoutSubviews];
        [cell.topView setNeedsLayout];
        RJHomeTopicModel *model = self.dataArray[indexPath.row];
        cell.model = model;
        [cell.topicButton addTarget:self action:@selector(goTopicListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.likeButton addTarget:self action:@selector(topicLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.likeButton.tag = indexPath.row;
        cell.likeButton.titleLabel.text =[NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        cell.delegate = self;
        cell.categoryView.hidden = YES;
        if (model.categoryId) {
            cell.categoryView.hidden = NO;
            cell.categoryNameLabel.text = model.categoryName;
            cell.categoryButton.tag = indexPath.row;
            [cell.categoryButton addTarget:self action:@selector(goTopicCategoryListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        return cell;
    }
    /**
     *  首页cell展示H5活动
     */
    if ([model isKindOfClass:[RJHomeWebActivityModel class]]) {
        RJHomeActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeActivityTableViewCell4"];
        cell.normalModel = model;
        return cell;
    }
    return nil;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    id model = self.dataArray[indexPath.row];
    
    /**
     *  主题带搭配Cell
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        
        RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
        CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell" configuration:^(RJHomeNewSubjectAndCollectionCell * cell) {
            cell.subjectDescLabel.text = model.memo;
            cell.buttonViewHieghtConstraint.constant = 35;
            
        }];
        return hei;
    }
    /**
     *  搭配带单品Cell高度
     */
    
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){
        
        RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
        //    CGFloat collectionImageWid = (SCREEN_WIDTH)/4 * 3;
        //    CGFloat collectionViewHei = collectionImageWid + 10 +10 + 69;
        CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeCollectionAndGoodCell4" configuration:^(RJHomeCollectionAndGoodCell * cell) {
            cell.topViewHieghtConstraint.constant = 35;
            cell.collectionDesLabel.text = model.memo;
            cell.tagHeightConstraint.constant = 0;
            
            if (model.themeTagList.count) {
                cell.tagHeightConstraint.constant = 38;
                
            }
        }];
        return hei;
    }
    
    /**
     *  资讯
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        CGFloat imageHei = SCREEN_WIDTH/16*9;
        return imageHei + 6 + 35;
    }
    /**
     *  首页cell 展示活动 h5
     */
    if ([model isKindOfClass:[RJHomeWebActivityModel class]]) {
        CGFloat imageHei = SCREEN_WIDTH/16*9;
        return imageHei + 6;
    }
    return 44;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //用全局变量记录被点击cell的indexPath,用于返回该UI时刷新
    _indexPath = indexPath;
    
    id model = self.dataArray[indexPath.row];
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){
        //去搭配详情界面
        RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
        collectionViewController.collectionId = model.id;
        collectionViewController.delegate = self;//add 8.13
        
//        /**
//         *  add 12.20 统计上报
//         */
//        ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//        statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//        statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//        statisticalDataModel.entranceType = _brandId;
//        statisticalDataModel.entranceTypeId = model.id;
//        [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
        
        
        [self.faterViewController. navigationController pushViewController:collectionViewController animated:YES];
    }
    /**
     *  去主题详情界面（合辑详情界面）
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
        vc.themeItemId = model.id;//用于非首页点击主题cell传主题详情header点赞参数id
        vc.delegate = self;//add 8.13
        
        
//        /**
//         *  add 12.19 统计上报
//         */
//        ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//        statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//        statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//        statisticalDataModel.entranceType = _brandId;
//        statisticalDataModel.entranceTypeId = model.id;
//        [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
        
        [self.faterViewController.navigationController pushViewController:vc animated:YES];
    }
    /**
     *  去资讯详情界面
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        
        HHTopicDetailViewController *vc = [[HHTopicDetailViewController alloc] init];
        __block RJHomeTopicModel *model = self.dataArray[indexPath.row];
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
        
//        UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        RJTopicDetailViewController *vc = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicDetailViewController"];
//        __block RJHomeTopicModel *model = self.dataArray[indexPath.row];
//        vc.shareModel = model.inform;
//        vc.informId = model.informId;
//        vc.isThumbUp = model.isThumbsup;
//        vc.zanBlock = ^(NSInteger state){
//            model.isThumbsup = [NSNumber numberWithInteger:state];
//            
//            if (model.isThumbsup.boolValue) {
//                
//                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue+1];
//            } else {
//                
//                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue-1];
//                if (model.thumbsupCount.intValue<0) {
//                    
//                    model.thumbsupCount = [NSNumber numberWithInt:0];
//                }
//            }
//
//            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//        };
        
        
//        /**
//         *  add 12.20 统计上报
//         */
//        ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//        statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//        statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//        statisticalDataModel.entranceType = _brandId;
//        statisticalDataModel.entranceTypeId = model.informId;
//        [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
        
        
        
        [self.faterViewController.navigationController pushViewController:vc animated:YES];
    }
    /**
     *  H5活动
     */
    if ([model isKindOfClass:[RJHomeWebActivityModel class]]) {
        RJHomeWebActivityModel *model = self.dataArray[indexPath.row];
        if (model.inform) {
            UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

            RJWebViewController *webVc = [storyBorad instantiateViewControllerWithIdentifier:@"RJWebViewController"];
            webVc.urlStr = model.inform.showUrl;
            webVc.shareModel = model.inform;
            webVc.webId = model.id;
            
//            /**
//             *  add 12.20 统计上报
//             */
//            ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//            statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//            statisticalDataModel.NextVCName = NSStringFromClass(webVc.class);
//            statisticalDataModel.entranceType = _brandId;
//            statisticalDataModel.entranceTypeId = model.id;
//            [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

            
            [self.faterViewController.navigationController pushViewController:webVc animated:YES];
        }
    }
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
//    statisticalDataModel.entranceType = _brandId;
//    statisticalDataModel.entranceTypeId = number;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
    

    [self.faterViewController.navigationController pushViewController:collectionViewController animated:YES];
    
}
- (void)collectionTapedWithTagId:(NSString *)tagId{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
    vc.themeItemId = [NSNumber numberWithInt:[tagId intValue]];
    
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = _brandId;
//    statisticalDataModel.entranceTypeId = (NSNumber *)tagId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.faterViewController.navigationController pushViewController:vc animated:YES];
}
#pragma mark -
- (BOOL)ifHasLogin{
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return NO;
    }
    return YES;
}
#pragma mark - 点赞
- (void)subjectLikeButtonAction:(CCButton *)sender{
  
    if ([self ifHasLogin]) {
        [self subjectLikeRequest:sender];
    }
    
}
//主题点赞接口
- (void)subjectLikeRequest:(CCButton *)sender{
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
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:2];
        
    }];
}

- (void)collectionLikeButtonAction:(CCButton *)sender{
    //    NSLog(@"搭配点赞");
    
    if ([self ifHasLogin]) {
        [self collectionLikeRequest:sender];
    }
    
}

//搭配点赞接口
- (void)collectionLikeRequest:(CCButton *)sender{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"/b82/api/v5/thumb?type=collocation";
    
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
                
                RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@", thumbCount];
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:2];
        
    }];
}

- (void)topicLikeButtonAction:(CCButton *)sender{
    if ([self ifHasLogin]) {
        [self topicLikeRequest:sender];
    }
}


//资讯点赞接口
- (void)topicLikeRequest:(CCButton *)sender{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=inform";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    RJHomeTopicModel *model = self.dataArray[sender.tag];
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
//搭配详情的代理方法
//搭配详情header点赞上级UI（本VC）刷新数据
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    
    id model = self.dataArray[_indexPath.row];
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){
        //去搭配详情界面
        RJHomeItemTypeTwoModel *model = self.dataArray[_indexPath.row];
        model.isThumbsup = [NSNumber numberWithBool:btnSelected];
        if (btnSelected) {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
            
        } else {
            
            if (model.thumbsupCount.intValue <=0) {
                
                model.thumbsupCount = [NSNumber numberWithInt:0];
                
            } else{
                
                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    /**
     *  去主题详情界面（合辑详情界面）
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        RJHomeItemTypeFourModel *model = self.dataArray[_indexPath.row];
        model.isThumbsup = [NSNumber numberWithBool:btnSelected];
        
        if (btnSelected) {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
            
        } else {
            
            if (model.thumbsupCount.intValue <=0) {
                
                model.thumbsupCount = [NSNumber numberWithInt:0];
                
            } else{
                
                model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
            }
        }
        
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}
#pragma mark - 去主题List
- (void)goSubjectListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RJDiscoveryThemeViewController *themeVc = [storyBorad instantiateViewControllerWithIdentifier:@"RJDiscoveryThemeViewController"];
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(themeVc.class);
//    statisticalDataModel.entranceType = _brandId;
//    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.faterViewController.navigationController pushViewController:themeVc animated:YES];
}
#pragma mark - 去搭配List
- (void)goCollectionListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RJDiscoveryMatchViewController *macthVc = [storyBorad instantiateViewControllerWithIdentifier:@"RJDiscoveryMatchViewController"];
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(macthVc.class);
//    statisticalDataModel.entranceType = _brandId;
//    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.faterViewController.navigationController pushViewController:macthVc animated:YES];
    
}
#pragma mark -RJHomeCollectionAndGoodCellDelegate
- (void)collectionTapedWithGoodId:(NSString *)goodId fromCollectionId:(NSNumber *)collectionId{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    NSNumber *goodId2 = (NSNumber *)goodId;
    goodsDetaiVC.goodsId = goodId2;
    goodsDetaiVC.fomeCollectionId = collectionId;

    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//    statisticalDataModel.entranceType = _brandId;
//    statisticalDataModel.entranceTypeId = (NSNumber *)goodId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.faterViewController.navigationController pushViewController:goodsDetaiVC animated:YES];
}

#pragma mark - 去资讯列表
- (void)goTopicListButtonAction:(id)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RJTopicListViewController *topicList = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicListViewController"];
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(topicList.class);
//    statisticalDataModel.entranceType = _brandId;
//    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.faterViewController.navigationController pushViewController:topicList animated:YES];
}
- (void)goTopicCategoryListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    RJTopicListViewController *topicList = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicListViewController"];
    
    RJHomeTopicModel *model = self.dataArray[sender.tag];
    topicList.selectCategoryId = model.categoryId;
    topicList.selectCategoryTitle = model.categoryName;
    
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(topicList.class);
//    statisticalDataModel.entranceType = _brandId;
//    statisticalDataModel.entranceTypeId = model.categoryId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
    
    
    [self.faterViewController.navigationController pushViewController:topicList animated:YES];
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
    
    [self.faterViewController.navigationController pushViewController:rootVc animated:YES];
}
@end
