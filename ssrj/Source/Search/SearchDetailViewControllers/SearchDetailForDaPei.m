//
//  SearchDetailForDaPei.m
//  ssrj
//
//  Created by YiDarren on 16/8/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SearchDetailForDaPei.h"
#import "ThemeDetailModel.h"
#import "CollectionsViewController.h"
#import "ThemeDetailCollectionViewCell.h"
#import "GetToThemeViewController.h"
#import "RJHomeItemTypeTwoModel.h"
#import "RJHomeCollectionAndGoodCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ZanModel.h"
#import "GoodsDetailViewController.h"
#import "ThemeDetailVC.h"
@interface SearchDetailForDaPei ()<UITableViewDataSource, UITableViewDelegate,CollectionsViewControllerDelegate,RJHomeCollectionAndGoodCellDelegate,RJTapedUserViewDelegate,GetToThemeViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) int pageNumber;

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation SearchDetailForDaPei

/**
 *  3.0.0
 */
#pragma mark -加入合辑编辑完成代理刷新
- (void)reloadCollocationViewCollocationCellDataWithModel:(RJHomeItemTypeTwoModel *)collocationModel {
    
    if (collocationModel) {
        
        [self.dataArray replaceObjectAtIndex:_indexPath.row withObject:collocationModel];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];

}

//搭配详情代理方法，通知本合辑详情刷新数据及cell
- (void)reloadZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    //模型重新赋值
    RJHomeItemTypeTwoModel *model = self.dataArray[_indexPath.row];
    model.isThumbsup = [NSNumber numberWithBool:btnSelected];
    if (model.isThumbsup.intValue == 0) {
        
        model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
        if (model.thumbsupCount.intValue < 0) {
            model.thumbsupCount = [NSNumber numberWithInt:0];
        }
        
    } else {
        
        model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
        
    }
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"搜索结果－搭配页面"];
    [TalkingData trackPageBegin:@"搜索结果－搭配页面"];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"搜索结果－搭配页面"];
    [TalkingData trackPageEnd:@"搜索结果－搭配页面"];

    
}





- (void)viewDidLoad {
    [super viewDidLoad];    
    self.dataArray = [NSMutableArray array];
    __weak __typeof (&*self)weakSelf = self;
    
    [_tableView registerNib:[UINib nibWithNibName:@"RJHomeCollectionAndGoodCell" bundle:nil] forCellReuseIdentifier:@"MineThumbupedCollectionsViewControllerCell"];

    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getCacheNetData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}
//用于长按弹出加入购物车页面的修改推荐尺寸的回调
- (void)getNetData {
    [self getCacheNetData];
}
//缓存接口start
- (void)getCacheNetData{
    
    _pageNumber = 0;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/collocation/?pagenum=%d&pagesize=10&search=%@",  _pageNumber,_searchWord];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                NSArray *itemList = responseObject[@"data"];
                
                if (itemList.count) {
                    
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getCacheNextPageData];
                    }];
                }
                _pageNumber++;
                
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
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
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [weakSelf.tableView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

    }];
}

#pragma  mark -- 请求下一页数据
- (void)getCacheNextPageData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/collocation/?pagenum=%d&pagesize=10&search=%@",  _pageNumber,_searchWord];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                NSArray *itemList = responseObject[@"data"];
                
                if (!itemList.count) {
                    
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                
                _pageNumber++;
                
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
            }else if (state.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            
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
    //    HomeCollectionAndGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCollectionAndGoodCell2"];
    //    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    //    cell.model = model;
    //    cell.delegate = self;
    //    return cell;
    
    
    RJHomeCollectionAndGoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineThumbupedCollectionsViewControllerCell"];
    cell.topViewHieghtConstraint.constant = 0;
    cell.topView.hidden = YES;
    [cell layoutSubviews];
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    cell.model = model;
    cell.delegate = self;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeButton.titleLabel.text = model.thumbsupCount.stringValue;
    cell.likeButton.selected = model.isThumbsup.boolValue;
    cell.userDelegate = self;
    [cell.putIntoThemeButton addTarget:self action:@selector(putIntoThemeButtonClickedActionWithButton:) forControlEvents:UIControlEventTouchUpInside];
    cell.putIntoThemeButton.tag = indexPath.row;
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&%@",NSStringFromClass(self.class),NSStringFromClass([RJHomeCollectionAndGoodCell class])];
    
    return cell;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    
    CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"MineThumbupedCollectionsViewControllerCell" configuration:^(RJHomeCollectionAndGoodCell * cell) {
        cell.topViewHieghtConstraint.constant = 0;
        cell.collectionDesLabel.text = model.memo;
        cell.tagHeightConstraint.constant = 0;
        
        if (model.themeTagList.count) {
            cell.tagHeightConstraint.constant = 38;
            
        }
    }];
    return hei;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    //去搭配详情界面
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = model.id;
    collectionViewController.delegate = self;
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1027];
//    statisticalDataModel.entranceTypeId = model.id;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}

//搜索为空时的UIImageView
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

#pragma mark -加入合辑putIntoThemeButtonClickedAction  
- (void)putIntoThemeButtonClickedActionWithButton:(UIButton *)button {
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    _indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    RJHomeItemTypeTwoModel *model = self.dataArray[button.tag];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC.collectionID = model.id;
    
    getToThemeVC.delegate = self;

    getToThemeVC.HomeItemTypeTwoModel = model;

    [self.navigationController pushViewController:getToThemeVC animated:YES];

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
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:1];
        
    }];
    
}


/**
 *  点击单品 去单品详情界面
 */
#pragma mark -
#pragma mark RJHomeCollectionAndGoodCellDelegate
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
//    statisticalDataModel.entranceType = collectionId;
//    statisticalDataModel.entranceTypeId = goodId2;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
- (void)collectionTapedWithTagId:(NSString *)tagId{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
    vc.themeItemId = [NSNumber numberWithInt:[tagId intValue]];
//    vc.parameterDictionary = @{@"thememItemId":tagId};
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1027];
//    statisticalDataModel.entranceTypeId = (NSNumber *)tagId;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:vc animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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
