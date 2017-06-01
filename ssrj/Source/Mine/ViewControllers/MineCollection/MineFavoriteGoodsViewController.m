//
//  MineFavoriteGoodsViewController.m
//  ssrj
//
//  Created by YiDarren on 16/8/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//



/**
 *  我的合辑页面
 *
 */

#import "MineFavoriteGoodsViewController.h"
#import "MineDaPeiModel.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "ThemeDetailVC.h"
#import "CartViewController.h"
#import "MineThumbupedCollectionsViewController.h"
#import "RJHomeNewSubjectAndCollectionCell.h"
#import "CollectionsViewController.h"
@interface MineFavoriteGoodsViewController ()<UITableViewDataSource, UITableViewDelegate,ThemeDetailVCDelegate,RJTapedUserViewDelegate,RJHomeNewSubjectAndCollectionCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
//section==1时的cell数据
@property (strong, nonatomic) NSMutableArray *dataArr;
//section==0时的cell数据
@property (strong, nonatomic) NSMutableArray *headerDataArr;

@property (assign, nonatomic) int pageNumber;

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;

@end

@implementation MineFavoriteGoodsViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [MobClick beginLogPageView:@"我的收藏－合辑页面"];
    [TalkingData trackPageBegin:@"我的收藏－合辑页面"];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"我的收藏－合辑页面"];
    [TalkingData trackPageEnd:@"我的收藏－合辑页面"];

}


//我的合辑（搭配）cell点击进入合辑详情，合辑详情header点赞或取消点赞代理通知上级UI（本UI）刷新对应cell数据
//该方法为合辑详情VC的代理方法，应只考虑了首页的刷新，故方法名称只与首页相关，不影响代理方法实现
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    
    RJHomeItemTypeFourModel *model = self.dataArr[_indexPath.row];
    model.isThumbsup = [NSNumber numberWithBool:btnSelected];
    
    if (btnSelected) {
        
        model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue +1];
    
    } else {
        
        if (model.thumbsupCount.intValue <= 0) {
            
            model.thumbsupCount = [NSNumber numberWithInt:0];
        
        } else {
            
            model.thumbsupCount = [NSNumber numberWithInt:model.thumbsupCount.intValue -1];
        }
    }
    
    //局部刷新
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"收藏的合辑";
    [self addBackButton];
    NSArray *btnArray = @[@1];
    [self addBarButtonItems:btnArray onSide:RJNavRightSide];
    
    self.dataArr = [NSMutableArray array];//section == 1
    self.headerDataArr = [NSMutableArray array];//section == 0
    
    __weak __typeof (&*self)weakSelf = self;
    
    weakSelf.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetData];
    }];
    
    [weakSelf.tableView.mj_header beginRefreshing];
}


- (void)cartButtonClickedButton {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CartViewController *vc = [story instantiateViewControllerWithIdentifier:@"CartViewController"];
    [self.navigationController pushViewController:vc animated:YES];

}


//section == 1时的数据
- (void)getNetData{
    _pageNumber = 1;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    //11.28
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/find-thumb-list?pageIndex=%d&pageSize=10&type=theme_item", _pageNumber];
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
         
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                NSArray *tempArr = [responseObject objectForKey:@"data"];
                
                if (tempArr.count) {
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getNextPageData];
                    }];
                    
                }
                _pageNumber++;
                
                NSError *error = nil;
                NSMutableArray *array = [NSMutableArray array];
                
                //                [weakSelf.dataArr removeAllObjects];
                for (NSDictionary *dic in tempArr) {
                    
                    RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc] initWithDictionary:dic error:&error];
                    [array addObject:model];
                }

                weakSelf.dataArr = array;
                [weakSelf.tableView reloadData];
                
            }
            else if (state .intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            [weakSelf.tableView.mj_header endRefreshing];
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];

        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}



#pragma mark --翻页
- (void)getNextPageData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    // add 11.28
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/find-thumb-list?pageIndex=%d&pageSize=10&type=theme_item", _pageNumber];
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *tempArr = [responseObject objectForKey:@"data"];
                
                if (tempArr.count == 0) {
                    
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                
                _pageNumber++;
                
                NSError *error = nil;

                for (NSDictionary *dic in tempArr) {
                    
                    RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc] initWithDictionary:dic error:&error];

                    [weakSelf.dataArr addObject:model];
                }
                
                [weakSelf.tableView reloadData];
                
            } else if (state.intValue == 1) {
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            [weakSelf.tableView.mj_footer endRefreshing];
            
        }
        
        else {
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];

        }
        [weakSelf.tableView.mj_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
}


#pragma mark -- UITableViewDelegate&DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArr.count;

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RJHomeItemTypeFourModel *model = self.dataArr[indexPath.row];
    
    CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell" configuration:^(RJHomeNewSubjectAndCollectionCell * cell) {
        cell.subjectDescLabel.text = model.memo;
        cell.buttonViewHieghtConstraint.constant = 35;
    }];
    return hei;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0) {
        
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
    
    RJHomeNewSubjectAndCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeNewSubjectAndCollectionCell"];
    RJHomeItemTypeFourModel *model = self.dataArr[indexPath.row];
    cell.model = model;
    //        cell.delagate = self;
    cell.buttonViewHieghtConstraint.constant = 35;
    cell.buttonView.hidden = NO;
    //        cell.userDelegate = self;
    cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
    cell.likeButton.selected = model.isThumbsup.boolValue;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    //    [cell.bigButton addTarget:self action:@selector(goSubjectListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    return cell;
}

- (void)likeButtonClicked:(UIButton *)sender{
    
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=theme_item"];
    
    RJHomeItemTypeFourModel *model = self.dataArr[sender.tag];
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

                //点赞数更新
                RJHomeItemTypeFourModel *model = weakSelf.dataArr[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;
                
                [weakSelf.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
                
            }
        }
        
        else {
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

    }];

    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    _indexPath = indexPath;
    
    RJHomeItemTypeFourModel *model = self.dataArr[indexPath.row];
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
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1034];
//    statisticalDataModel.entranceTypeId = model.id;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:vc animated:YES];
    
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
//    statisticalDataModel.entranceType = [NSNumber numberWithInt:1035];
//    statisticalDataModel.entranceTypeId = number;
//    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}
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
