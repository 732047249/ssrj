//
//  RJUserCentePublishTableViewController.m
//  ssrj
//
//  Created by CC on 16/9/21.
//  Copyright (c) 2016年 ssrj. All rights reserved.
//

#import "RJUserCentePublishTableViewController.h"
#import "RJUserCenteRootViewController.h"


#import "HomeTopicTableViewCell.h"

#import "RJHomeTopicModel.h"
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

#import "GetToThemeViewController.h"
#import "RJHomeItemTypeTwoModel.h"
#import "RJHomeNewSubjectAndCollectionCell.h"

#import "EditPublishThemeViewController.h"
#import "EditCollocationViewController.h"
#import "EditThemeManagerViewController.h"
//带评论的搭配cell
#import "RJHomeCollectionAndGoodAndCommentCell.h"

#import "RJNewSubjectAndCollectionWithCommentCell.h"

@interface RJUserCentePublishTableViewController ()<RJHomeNewSubjectAndCollectionCellDelegate,ThemeDetailVCDelegate,CollectionsViewControllerDelegate,RJHomeCollectionAndGoodCellDelegate,RJTapedUserViewDelegate,EditPublishThemeViewControllerDelegate,EditCollocationViewControllerDelegate,EditThemeManagerViewControllerDelegate,GetToThemeViewControllerDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (assign, nonatomic) NSInteger pageIndex;
@property (strong, nonatomic) NSIndexPath *indexPath;
@property (strong, nonatomic) IBOutlet UIView *emptyFooterView;
//记录编辑搭配的index
@property (nonatomic) NSInteger editIndex;

@end

@implementation RJUserCentePublishTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    
    /**
     *  3.0.0搭配编辑功能
     */
    _isSelf = NO;
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        if ([_userId isEqualToNumber:[RJAccountManager sharedInstance].account.id]) {
            
            _isSelf = YES;
        }
        else {
            _isSelf = NO;
        }
    }
   
    
    __weak __typeof(&*self)weakSelf = self;
    /**
     *  注册Xib
     */
    
    [self.tableView registerNib:[UINib nibWithNibName:@"HomeTopicTableViewCell" bundle:nil] forCellReuseIdentifier:@"HomeTopicTableViewCell5"];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.fatherViewController getUserHeaderData];
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
    [HTUIHelper addHUDToWindowWithString:@"加载中..."];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"用户中心的发布界面"];
    [TalkingData trackPageBegin:@"用户中心的发布界面"];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"用户中心的发布界面"];
    [TalkingData trackPageEnd:@"用户中心的发布界面"];

}

- (void)getNetData{

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    __weak __typeof(&*self)weakSelf = self;
    self.pageIndex = 1;
    
    if (_isSelf) {
        
        //v1 --> v2
        requestInfo.URLString = @"/b180/api/v2/content/publish/list/";

    }else {
        
        requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v2/content/publish/list/user/%@/",_userId.stringValue];
    }
    
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"page_index":[NSNumber numberWithInteger:_pageIndex],@"page_size":@"10",@"appVersion":VERSION}];
    
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
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
                    weakSelf.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
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
                            [model upDateLayout];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 4:{
                            RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            [model upDateLayout];
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
    
    if (_isSelf) {
        
        requestInfo.URLString = @"/b180/api/v2/content/publish/list/";
        
    }else {
        
        requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v2/content/publish/list/user/%@/",_userId.stringValue];
    }
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"page_index":[NSNumber numberWithInteger:_pageIndex],@"page_size":@"10",@"appVersion":VERSION}];
    
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
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
                            //资讯
                            RJHomeTopicModel *model = [[RJHomeTopicModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 2:{
                            //搭配
                            RJHomeItemTypeTwoModel *model = [[RJHomeItemTypeTwoModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            [model upDateLayout];
                            if (model) {
                                [weakSelf.dataArray addObject:model];
                            }
                        }
                            break;
                        case 4:{
                            //主题（合辑）
                            RJHomeItemTypeFourModel *model = [[RJHomeItemTypeFourModel alloc]initWithDictionary:dic[@"data"] error:nil];
                            [model upDateLayout];

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

#pragma mark -合辑详情删除合辑代理刷新
- (void)reloadUserCenterPublishTableViewData {

    [self.dataArray removeObjectAtIndex:_indexPath.row];
    
    [self.tableView reloadData];
    
    [self.fatherViewController getUserHeaderData];

    
}


#pragma mark -管理合辑内容刷新
-(void)reloadManagerThemeDataWithIndex:(NSInteger)index {
    
//    [self getNetData];

}

#pragma mark - 搭配详情删除搭配完成代理刷新本UI
- (void)reloadUserCenterPublishDataWithDelete {
    
    [self.dataArray removeObjectAtIndex:_indexPath.row];
    
    [self.tableView reloadData];
    
    [self.fatherViewController getUserHeaderData];
    
}

#pragma mark -编辑搭配刷新-直接在用户中心列表中点击cell跳往搭配详情后点击编辑请况的代理刷新
- (void)reloadUserCenterPublishDataWithReWriteDic:(NSDictionary *)dic {
    
    [self reloadEditedThemeOrCollocationDataWithDic:dic];
}

#pragma mark -点击cell进入详情后点击加入合辑代理刷新，二级刷新
- (void)reloadUserCenterPublishDataWithCollocationModel:(RJHomeItemTypeTwoModel *)collocationModel {
    
    if (collocationModel) {
        
        [self.dataArray replaceObjectAtIndex:_indexPath.row withObject:collocationModel];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark -编辑搭配刷新-直接在用户中心列表中刷新指定cell
- (void)reloadEditedCollocationDataWithCollocationModel:(RJHomeItemTypeTwoModel *)model {
    
    if (model) {
        
        [self.dataArray replaceObjectAtIndex:_indexPath.row withObject:model];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark -加入合集UI代理刷新 getToThemeViewController
- (void)reloadCollocationViewCollocationCellDataWithModel:(RJHomeItemTypeTwoModel *)collocationModel {
    
    if (collocationModel) {
        
        [self.dataArray replaceObjectAtIndex:_indexPath.row withObject:collocationModel];
    }
    
    [self.tableView reloadRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.fatherViewController getUserHeaderData];

}


#pragma mark -编辑搭配刷新-直接在用户中心列表的cell里点击编辑未跳往搭配详情请况的代理刷新
-(void)reloadEditedCollocationDataWithDic:(NSDictionary *)dic {
    
    //有数据删除，自动刷新
    [self reloadEditedThemeOrCollocationDataWithDic:dic];
}

#pragma mark -编辑合辑刷新
- (void)reloadEditedThemeDataWithDic:(NSDictionary *)dic {
    
    [self reloadEditedThemeOrCollocationDataWithDic:dic];
}

#pragma mark -编辑完后的刷新方法 （非代理刷新方法）
- (void)reloadEditedThemeOrCollocationDataWithDic:(NSDictionary *)dic {
    
    id model = self.dataArray[_editIndex];
    
    //搭配
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){
        
//        [self getNetData];
    
    }
    //主题（合辑）
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        
        RJHomeItemTypeFourModel *model = self.dataArray[_editIndex];
        //编辑合辑页定好的字段
        model.name = [dic objectForKey:@"name"];
        model.memo = [dic objectForKey:@"describe"];
    }
    [self.tableView reloadData];
    
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
        
        RJNewSubjectAndCollectionWithCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJNewSubjectAndCollectionWithCommentCell"];
        RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
        cell.fatherViewControllerName = @"RJUserCentePublishTableViewController";
        cell.model = model;
      
        cell.buttonViewHieghtConstraint.constant = 35;
        cell.buttonView.hidden = NO;
        cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        cell.likeButton.tag = indexPath.row;
        [cell.likeButton addTarget:self action:@selector(subjectLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.bigButton addTarget:self action:@selector(goSubjectListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.delegate = self;
        cell.trackingId = [NSString stringWithFormat:@"RJUserCentePublishTableViewController&RJNewSubjectAndCollectionWithCommentCell&id=%@",model.id];
        /**
         *  3.0.0编辑功能
         */
        if (_isSelf) {
            
            [cell.dropDownBgView setHidden:NO];
            cell.dropDownButton.tag = indexPath.row;
            [cell.dropDownButton addTarget:self action:@selector(themeDropDownButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            //是否发布
            if (model.is_publish.intValue == 0) {
                
                //未发布标签显示
                [cell.unPublishLabel setHidden:NO];
            }
            else {
                
                //未发布标签隐藏
                [cell.unPublishLabel setHidden:YES];
            }
            
        }
        else {
            [cell.dropDownBgView setHidden:YES];

        }
        
        /**
         *  3.0.1
         */
        
        NSString *timeString = [model.create_date stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:@" "];
        timeString = [timeString substringToIndex:19];
        cell.timeLabel.text = timeString;//model.create_date;

        cell.actionLabel.hidden = NO;
        if (model.event.intValue == 0) {
            
            cell.actionLabel.text = @"创建了";
        }
        else if (model.event.intValue == 1) {
            
            cell.actionLabel.text = @"发布了";
        }
        else if (model.event.intValue == 2) {
            
            cell.actionLabel.text = @"点赞了";
        }
        [cell setNeedsLayout];
        return cell;


    }
    /**
     *  搭配带单品Cell
     */
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]) {
        
        RJHomeCollectionAndGoodAndCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RJHomeCollectionAndGoodAndCommentCell"];
        cell.topViewHieghtConstraint.constant = 35;
        cell.topView.hidden = NO;
        RJHomeItemTypeTwoModel *model = self.dataArray[indexPath.row];
        cell.fatherViewControllerName = @"RJUserCentePublishTableViewController";
        cell.model = model;
        cell.likeButton.titleLabel.text = [NSString stringWithFormat:@"%d",model.thumbsupCount.intValue];
        cell.likeButton.selected = model.isThumbsup.boolValue;
        cell.likeButton.tag = indexPath.row;
        [cell.likeButton addTarget:self action:@selector(collectionLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.userDelegate = self;
        cell.delegate = self;
        [cell.topViewButton addTarget:self action:@selector(goCollectionListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.putIntoThemeButton.tag = indexPath.row;
        [cell.putIntoThemeButton addTarget:self action:@selector(putIntoThemeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.trackingId = [NSString stringWithFormat:@"RJUserCentePublishTableViewController&RJHomeCollectionAndGoodAndCommentCell&id=%@",model.id];
        /**
         *  3.0.0编辑功能
         */
        if (_isSelf) {
            
            [cell.dropDownBgView setHidden:NO];
            cell.dropDownButton.tag = indexPath.row;
            [cell.dropDownButton addTarget:self action:@selector(collocationDropDownButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            [cell.dropDownBgView setHidden:YES];
        }
        
        /**
         *  3.0.1
         */
        
        NSString *timeString = [model.create_date stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:@" "];
        timeString = [timeString substringToIndex:19];

        cell.timeLabel.text = timeString;//model.create_date;
        
        cell.actionLabel.hidden = NO;
        if (model.event.intValue == 0) {
            
            cell.actionLabel.text = @"创建了";
        }
        else if (model.event.intValue == 1) {
            
            cell.actionLabel.text = @"发布了";
        }
        else if (model.event.intValue == 2) {
            
            cell.actionLabel.text = @"点赞了";
        }
        [cell layoutSubviews];

        return cell;
        
    }
    /**
     *  资讯Cell
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        HomeTopicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeTopicTableViewCell5"];
        cell.fatherViewControllerName = @"RJUserCentePublishTableViewController";
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
        cell.categoryView.hidden = YES;
        cell.delegate = self;
        /**
         *  3.0.0编辑功能
         */
        if (_isSelf) {
            
            [cell.dropDownBgView setHidden:NO];
            cell.dropDownButton.tag = indexPath.row;
            [cell.dropDownButton addTarget:self action:@selector(topicDropDownButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        else {
            
            [cell.dropDownBgView setHidden:YES];
        }
        
        if (model.categoryId) {
            cell.categoryView.hidden = NO;
            cell.categoryNameLabel.text = model.categoryName;
            cell.categoryButton.tag = indexPath.row;
            [cell.categoryButton addTarget:self action:@selector(goTopicCategoryListButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        /**
         *  3.0.1  只在用户中心发布列表的资讯cell中打开
         */
        NSString *timeString = [model.create_date stringByReplacingCharactersInRange:NSMakeRange(10, 1) withString:@" "];
        timeString = [timeString substringToIndex:19];

        cell.timeLabel.text = timeString;//model.create_date;
        cell.timeLabel.hidden = NO;
        cell.actionlabel.hidden = NO;
        if (model.event.intValue == 0) {
            
            cell.actionlabel.text = @"创建了";
        }
        else if (model.event.intValue == 1) {
            
            cell.actionlabel.text = @"发布了";
        }
        else if (model.event.intValue == 2) {
            
            cell.actionlabel.text = @"点赞了";
        }
        [cell layoutSubviews];
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
        CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJNewSubjectAndCollectionWithCommentCell" configuration:^(RJNewSubjectAndCollectionWithCommentCell * cell) {
            cell.buttonViewHieghtConstraint.constant = 35;
            cell.subjectDescLabel.text = model.memo;

            if (model.comment.countComment.intValue == 0) {
                cell.commentSuperViewHeiConstraint.constant = model.commentHeight.intValue;
            }else{
                cell.commentThreeHeiConstraint.constant = model.commentThreeHeight.intValue;
                cell.commentOneHeiConstraint.constant =  model.commentOneHeight.intValue;
                cell.commentTwoHeiConstraint.constant = model.commentTwoHeight.intValue;
                cell.commentSuperViewHeiConstraint.constant = model.commentHeight.intValue;
            }
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
        CGFloat hei = [tableView fd_heightForCellWithIdentifier:@"RJHomeCollectionAndGoodAndCommentCell" configuration:^(RJHomeCollectionAndGoodAndCommentCell * cell) {
            cell.topViewHieghtConstraint.constant = 35;
            cell.collectionDesLabel.text = model.memo;
            cell.tagHeightConstraint.constant = 0;
            if (model.themeTagList.count) {
                cell.tagHeightConstraint.constant = 38;
                
            }
            if (model.comment.countComment.intValue == 0) {
                cell.commentSuperViewHeiConstraint.constant = model.commentHeight.intValue;
            }else{
                cell.commentThreeHeiConstraint.constant = model.commentThreeHeight.intValue;
                cell.commentOneHeiConstraint.constant =  model.commentOneHeight.intValue;
                cell.commentTwoHeiConstraint.constant = model.commentTwoHeight.intValue;
                cell.commentSuperViewHeiConstraint.constant = model.commentHeight.intValue;
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
        collectionViewController.isSelf = _isSelf;
        collectionViewController.event = model.event;
        collectionViewController.homeItemTypeTwoModel = model;
        [self.fatherViewController.navigationController pushViewController:collectionViewController animated:YES];
    }
    /**
     *  去主题详情界面（合辑详情界面）
     */
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        RJHomeItemTypeFourModel *model = self.dataArray[indexPath.row];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
        vc.themeItemId = model.id;
        vc.delegate = self;//add 8.13
        vc.event = model.event;
        
        if (_isSelf) {
            
            vc.isSelf = _isSelf;
            
        }else {
            
            vc.isSelf = NO;
        }
        if (model.is_publish.intValue == 0) {
            
            vc.isPublished = NO;
        }
        else {
            
            vc.isPublished = YES;
        }
        
        [self.fatherViewController.navigationController pushViewController:vc animated:YES];
    }
    /**
     *  去资讯详情界面
     */
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        
        HHTopicDetailViewController *vc = [[HHTopicDetailViewController alloc] init];
//        UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        RJTopicDetailViewController *vc = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicDetailViewController"];
        __block RJHomeTopicModel *model = self.dataArray[indexPath.row];
        vc.shareModel = model.inform;
        vc.informId = model.informId;
        vc.isThumbUp = model.isThumbsup;
        vc.event = model.event;
        
        vc.zanBlock = ^(NSInteger state){
            model.isThumbsup = [NSNumber numberWithInteger:state];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        };
        
        [self.fatherViewController.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - 用于对用户自己发布的合辑进行编辑功能
- (void)themeDropDownButtonClicked:(UIButton *)sender {
    
    RJHomeItemTypeFourModel *model = self.dataArray[sender.tag];
    ///3.0.1
    if (model.event.intValue == 2) {
        //TODO:点赞
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:model.isThumbsup.boolValue?@"取消点赞":@"点赞",nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];
        menu.tag = sender.tag;
        
    }
    else {
        
        if (model.is_publish.intValue == 0) {
            
            UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发布",@"编辑",@"管理合辑内容",@"删除合辑",nil];
            menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [menu showInView:self.view];
            menu.tag = sender.tag;
            
        }
        else {
            
            UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"管理合辑内容",@"删除合辑",nil];
            menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [menu showInView:self.view];
            menu.tag = sender.tag;
            
        }

    }

}


#pragma mark - 用于对自己发布的搭配进行编辑功能
- (void)collocationDropDownButtonClicked:(UIButton *)sender {
    
    _indexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    ///3.0.1
    RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];

    if (model.event.intValue == 2) {
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:model.isThumbsup.boolValue?@"取消点赞":@"点赞",nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];
        menu.tag = sender.tag;
        
    }
    else {
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑",@"删除搭配",nil];
        
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];
        menu.tag = sender.tag;

    }
    
}


#pragma mark - 用于对自己发布的资讯进行删除功能
- (void)topicDropDownButtonClicked:(UIButton *)sender {
    
    ///3.0.1
    RJHomeTopicModel *model = self.dataArray[sender.tag];

    if (model.event.intValue == 2) {
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:model.isThumbsup.boolValue?@"取消点赞":@"点赞",nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];
        menu.tag = sender.tag;
       
    }
    else {
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除资讯",nil];
        
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];
        menu.tag = sender.tag;

    }
   
}

#pragma mark -UIActionSheetDelegate－－clickedButtonAtIndex
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    _editIndex = actionSheet.tag;

    id model = self.dataArray[actionSheet.tag];
    
    //搭配
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){

        RJHomeItemTypeTwoModel *model = self.dataArray[actionSheet.tag];
        
        if (model.event.intValue == 2) {
            
            if (buttonIndex == 0) {
                
                //TODO:调用取消点赞方法
                CCButton *sender = [CCButton new];
                sender.tag = actionSheet.tag;
                [self collectionLikeButtonAction:sender];
            
            }
            
        }
        else {
            
            if (buttonIndex == 0) {
                
                //编辑搭配
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                
                EditCollocationViewController *editVC = [sb instantiateViewControllerWithIdentifier:@"EditCollocationViewController"];
                
                editVC.collectionID = model.id;
                editVC.collocationTitStr = model.name;
                editVC.collocationDesStr = model.memo;
                editVC.homeItemTypeTwoModel = model;
                editVC.delegate = self;
                
                [self.fatherViewController.navigationController pushViewController:editVC animated:YES];
                
                
            }
            else if (buttonIndex == 1) {
                
                //删除提示
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除图片后，其他用户将看不到此搭配，真的要删除吗?" delegate:self cancelButtonTitle:@"我再思考一下" otherButtonTitles:@"确定", nil];
                alert.tag = actionSheet.tag;
                [alert show];
            }

        }
        
    }
    
    //主题（合辑）
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        
        RJHomeItemTypeFourModel *model = self.dataArray[actionSheet.tag];
        
        
        if (model.event.intValue == 2) {
            
            if (buttonIndex == 0) {
                
                //TODO:调用取消点赞方法
                CCButton *sender = [CCButton new];
                sender.tag = actionSheet.tag;
                [self subjectLikeButtonAction:sender];

            }
            
        }
        else {
            
            if (model.is_publish.intValue == 0) {
                
                if (buttonIndex == 0 || buttonIndex == 1) {
                    
                    //编辑合辑
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                    
                    EditPublishThemeViewController *editThemeVC = [sb instantiateViewControllerWithIdentifier:@"EditPublishThemeViewController"];
                    
                    editThemeVC.creatThemeID = model.id;
                    editThemeVC.themeName = model.name;
                    editThemeVC.themeDescribe = model.memo;
                    editThemeVC.delegate = self;
                    
                    [self.fatherViewController.navigationController pushViewController:editThemeVC animated:YES];
                    
                }
                else if (buttonIndex == 2) {
                    
                    //管理合辑内容
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                    
                    EditThemeManagerViewController *editMVC = [sb instantiateViewControllerWithIdentifier:@"EditThemeManagerViewController"];
                    editMVC.themeId = model.id;
                    editMVC.delegate = self;
                    [self.fatherViewController.navigationController pushViewController:editMVC animated:YES];
                    
                }
                else if (buttonIndex == 3) {
                    
                    //删除提示
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除合辑后将无法找回，确认要删除吗?" delegate:self cancelButtonTitle:@"再思考一下" otherButtonTitles:@"确定", nil];
                    alert.tag = actionSheet.tag;
                    [alert show];
                }
                
            }
            else {
                
                if (buttonIndex == 0) {
                    
                    //管理合辑内容
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                    
                    EditThemeManagerViewController *editMVC = [sb instantiateViewControllerWithIdentifier:@"EditThemeManagerViewController"];
                    editMVC.themeId = model.id;
                    editMVC.delegate = self;
                    [self.fatherViewController.navigationController pushViewController:editMVC animated:YES];
                    
                }
                else if (buttonIndex == 1) {
                    
                    //删除提示
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除合辑后将无法找回，确认要删除吗?" delegate:self cancelButtonTitle:@"再思考一下" otherButtonTitles:@"确定", nil];
                    alert.tag = actionSheet.tag;
                    [alert show];
                }
            }
            
        }
        
    }
    //资讯
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
        HHTopicDetailViewController *vc = [[HHTopicDetailViewController alloc]init];
//        UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        RJTopicDetailViewController *vc = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicDetailViewController"];
        __block RJHomeTopicModel *model = self.dataArray[actionSheet.tag];
        vc.shareModel = model.inform;
        vc.informId = model.informId;
        vc.isThumbUp = model.isThumbsup;
        
        if (model.event.intValue == 2) {
            
            if (buttonIndex == 0) {
                
                ///调用取消点赞方法
                CCButton *sender = [CCButton new];
                sender.tag = actionSheet.tag;
                [self topicLikeButtonAction:sender];
                
            }
            
        }
        else {
            
            if (buttonIndex == 0) {
                
                //删除提示
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除资讯后，其他用户将看不到此资讯，真的要删除吗?" delegate:self cancelButtonTitle:@"再思考一下" otherButtonTitles:@"确定", nil];
                alert.tag = actionSheet.tag;
                [alert show];
                
            }
            
        }
        
    }
}

#pragma mark - UIAlertViewDelegate方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //判断要删除的是什么类型的cell
    id model = self.dataArray[alertView.tag];
    
    //搭配
    if ([model isKindOfClass:[RJHomeItemTypeTwoModel class]]){
        
        RJHomeItemTypeTwoModel *model = self.dataArray[alertView.tag];
        
        if (buttonIndex == 1) {
            
            [self deleteSelfPublishWithUrlstring:[NSString stringWithFormat:@"/b180/api/v1/content/publish/collocation/detail/%@/",model.id] index:alertView.tag];
        }
    }
    
    //主题（合辑）
    if ([model isKindOfClass:[RJHomeItemTypeFourModel class]]) {
        
        RJHomeItemTypeFourModel *model = self.dataArray[alertView.tag];
        
        if (buttonIndex == 1) {
            
            [self deleteSelfPublishWithUrlstring:[NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/detail/%@/",model.id] index:alertView.tag];

        }
    }
    
    //资讯
    if ([model isKindOfClass:[RJHomeTopicModel class]]) {
     
        RJHomeTopicModel *model = self.dataArray[alertView.tag];
        
        if (buttonIndex == 1) {
            
            [self deleteSelfPublishWithUrlstring:[NSString stringWithFormat:@"/b180/api/v1/content/publish/info/detail/%@/",model.id] index:alertView.tag];
        }
    }
}



#pragma mark -删除合辑、搭配、资讯方法
- (void)deleteSelfPublishWithUrlstring:(NSString *)urlStr index:(NSInteger) index {

    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    requestInfo.URLString = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    [[ZHNetworkManager sharedInstance] deleteWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
                [weakSelf.dataArray removeObjectAtIndex:index];
                
                [weakSelf.tableView reloadData];
                
                [self.fatherViewController getUserHeaderData];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
            //[[HTUIHelper shareInstance] removeHUD];
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
        //[[HTUIHelper shareInstance] removeHUD];

        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //[[HTUIHelper shareInstance] removeHUD];
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

    }];
    
}



#pragma mark - 加入合辑点击事件
- (void)putIntoThemeButtonClicked:(UIButton *)sender {
    
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
    [self.fatherViewController.navigationController pushViewController:getToThemeVC animated:YES];
}


#pragma mark - RJHomeNewSubjectAndCollectionCellDelegate
- (void)collectionSelectWithId:(NSNumber *)number{
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = number;
    
    [self.fatherViewController.navigationController pushViewController:collectionViewController animated:YES];
    
}
- (void)collectionTapedWithTagId:(NSString *)tagId{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
    vc.themeItemId = [NSNumber numberWithInt:[tagId intValue]];
//    vc.parameterDictionary = @{@"thememItemId":tagId};
    
    [self.fatherViewController.navigationController pushViewController:vc animated:YES];
}
#pragma mark -
- (BOOL)ifHasLogin{
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        [self.fatherViewController.navigationController presentViewController:loginNav animated:YES completion:^{
            
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
                
                //判断是不是用户自己的点赞数据

                if (_isSelf && model.event.intValue == 2) {
                    
                    [weakSelf.dataArray removeObjectAtIndex:sender.tag];
                    [weakSelf.tableView reloadData];
                    [weakSelf.fatherViewController getUserHeaderData];
                    return ;
                }
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                RJHomeItemTypeFourModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
                
                [weakSelf.tableView reloadData];
                
                [weakSelf.fatherViewController getUserHeaderData];
                
            }
            
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Net Error" hideDelay:2];
        
    }];
}

- (void)collectionLikeButtonAction:(CCButton *)sender{
    
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
                
                //判断是不是用户自己的点赞数据
                
                if (_isSelf && model.event.intValue == 2) {
                    
                    [weakSelf.dataArray removeObjectAtIndex:sender.tag];
                    [weakSelf.tableView reloadData];
                    [weakSelf.fatherViewController getUserHeaderData];
                    
                    return ;
                }
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                RJHomeItemTypeTwoModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@", thumbCount];
                
                [weakSelf.tableView reloadData];

                [weakSelf.fatherViewController getUserHeaderData];
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Net Error" hideDelay:2];
        //        [weakSelf.tableView.mj_header endRefreshing];
        
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
                
                
                //判断是不是用户自己的点赞数据

                if (_isSelf && model.event.intValue == 2) {
                    
                    [weakSelf.dataArray removeObjectAtIndex:sender.tag];
                    [weakSelf.tableView reloadData];
                    
                    [weakSelf.fatherViewController getUserHeaderData];

                    return ;
                }
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                sender.selected = thumb;
                
                RJHomeTopicModel *model = self.dataArray[sender.tag];
                
                model.isThumbsup = [NSNumber numberWithBool:thumb];
                
                model.thumbsupCount = thumbCount;

                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
                
                [weakSelf.tableView reloadData];
                
                [weakSelf.fatherViewController getUserHeaderData];
                
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
    
    [self.fatherViewController.navigationController pushViewController:themeVc animated:YES];
}
#pragma mark - 去搭配List
- (void)goCollectionListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RJDiscoveryMatchViewController *macthVc = [storyBorad instantiateViewControllerWithIdentifier:@"RJDiscoveryMatchViewController"];
    
    [self.fatherViewController.navigationController pushViewController:macthVc animated:YES];
    
}
#pragma mark -RJHomeCollectionAndGoodCellDelegate
- (void)collectionTapedWithGoodId:(NSString *)goodId fromCollectionId:(NSNumber *)collectionId{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    NSNumber *goodId2 = (NSNumber *)goodId;
    goodsDetaiVC.goodsId = goodId2;
    goodsDetaiVC.fomeCollectionId = collectionId;

    [self.fatherViewController.navigationController pushViewController:goodsDetaiVC animated:YES];
}

#pragma mark - 去资讯列表
- (void)goTopicListButtonAction:(id)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RJTopicListViewController *topicList = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicListViewController"];
    
    
    [self.fatherViewController.navigationController pushViewController:topicList animated:YES];
}
- (void)goTopicCategoryListButtonAction:(UIButton *)sender{
    UIStoryboard *storyBorad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    RJTopicListViewController *topicList = [storyBorad instantiateViewControllerWithIdentifier:@"RJTopicListViewController"];
    RJHomeTopicModel *model = self.dataArray[sender.tag];
    topicList.selectCategoryId = model.categoryId;
    topicList.selectCategoryTitle = model.categoryName;
    

    [self.fatherViewController.navigationController pushViewController:topicList animated:YES];
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
    
    [self.fatherViewController.navigationController pushViewController:rootVc animated:YES];
}
@end
