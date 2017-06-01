//
//  MineThumbupedCollectionsViewController.m
//  ssrj
//  我的搭配
//  Created by YiDarren on 16/8/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MineThumbupedCollectionsViewController.h"
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
@interface MineThumbupedCollectionsViewController ()<UITableViewDataSource, UITableViewDelegate,CollectionsViewControllerDelegate,RJHomeCollectionAndGoodCellDelegate,RJTapedUserViewDelegate,GetToThemeViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@property (assign, nonatomic) int pageNumber;

@end

@implementation MineThumbupedCollectionsViewController


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
    self.navigationController.navigationBarHidden = NO;
    [MobClick beginLogPageView:@"我的收藏－搭配页面"];
    [TalkingData trackPageBegin:@"我的收藏－搭配页面"];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"我的收藏－搭配页面"];
    [TalkingData trackPageEnd:@"我的收藏－搭配页面"];

    
}





- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    NSArray *btnArray = @[@1];
    [self addBarButtonItems:btnArray onSide:RJNavRightSide];
    [self setTitle:@"收藏的搭配" tappable:NO];
    
    self.dataArray = [NSMutableArray array];
    __weak __typeof (&*self)weakSelf = self;
    [_tableView registerNib:[UINib nibWithNibName:@"RJHomeCollectionAndGoodCell" bundle:nil] forCellReuseIdentifier:@"MineThumbupedCollectionsViewControllerCell"];


    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}


- (void)getNetData{

    _pageNumber = 1;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/thumbsupCollocation.jhtml?pageNumber=%d",_pageNumber];

    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.intValue == 0) {
                
                NSArray *itemList = responseObject[@"data"];
                
                if (itemList.count) {
                    
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getNextNetData];
                    }];
                    
                    _pageNumber ++;
                }
                
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in itemList) {
                    RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
            }else if (number.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
}

//请求下一页网络数据
- (void)getNextNetData{
    
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/thumbsupCollocation.jhtml?pageNumber=%d",_pageNumber];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.intValue == 0) {
                
                NSArray *itemList = responseObject[@"data"];
                
                if (itemList.count == 0) {
                    
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
            }else if (number.intValue == 1){
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
    
    //加入合辑button添加点击事件
    cell.putIntoThemeButton.tag = indexPath.row;
    [cell.putIntoThemeButton addTarget:self action:@selector(putIntoThemeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    
    CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"MineThumbupedCollectionsViewControllerCell" configuration:^(RJHomeCollectionAndGoodCell * cell) {
        cell.topViewHieghtConstraint.constant = 0;
        cell.collectionDesLabel.text = model.memo;
    }];
    return hei;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    //去搭配详情界面
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.delegate = self;
    RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
    collectionViewController.collectionId = model.id;
    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}

#pragma mark -加入合辑代理刷新GetToThemeViewControllerDelegate
- (void)reloadCollocationViewCollocationCellDataWithModel:(RJHomeItemTypeTwoModel *)collocationModel {
    
    if (collocationModel) {
        
        [self.dataArray replaceObjectAtIndex:_indexPath.row withObject:collocationModel];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


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
        
        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription] hideDelay:2];
        
    }];
}


#pragma mark - 加入合辑点击事件
- (void)putIntoThemeButtonClicked:(UIButton *)sender {
    
    //用全局变量记录被点击cell的indexPath,用于返回该UI时刷新
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    _indexPath = indexPath;
    
    //添加主题之前用户必须已经登录，需要取用户对应token
    //去登录界面
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [mainStory instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        
        return;
    }
    
    RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    getToThemeVC.HomeItemTypeTwoModel = model;
    getToThemeVC.collectionID = model.id;
    getToThemeVC.parameterDictionary = @{@"colloctionId":model.id};
    getToThemeVC.delegate = self;
    
//    [self presentViewController:getToThemeVC animated:YES completion:^{
//    
//    }];
    
    [self.navigationController pushViewController:getToThemeVC animated:YES];
}



/**
 *  点击单品 去单品详情界面
 */
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
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1033];
//    statisticalDataModel.entranceTypeId = goodId2;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];


    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
- (void)collectionTapedWithTagId:(NSString *)tagId{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
//    vc.parameterDictionary = @{@"thememItemId":tagId};
    vc.themeItemId = [NSNumber numberWithInt:[tagId intValue]];
    
//    /**
//     *  add 12.20 统计上报
//     */
//    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1037];
//    statisticalDataModel.entranceTypeId = (NSNumber *)tagId;
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
