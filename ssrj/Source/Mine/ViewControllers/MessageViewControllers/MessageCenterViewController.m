//
//  MessageCenterViewController.m
//  ssrj
//
//  Created by YiDarren on 16/12/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MessageCenterViewController.h"
#import "MsgCenterWithImageTableViewCell.h"
#import "MsgCenterWithOutImgTableViewCell.h"
#import "RJMessageItemModel.h"

//点击消息跳转的VC
#import "RJPayOrderDetailViewController.h"
#import "CollectionsViewController.h"
#import "GoodsDetailViewController.h"
#import "ThemeDetailVC.h"
#import "YuEViewController.h"
#import "RJBrandDetailRootViewController.h"
#import "RJUserCenteRootViewController.h"
#import "RJUserFansListViewController.h"
#import "EMIMHelper.h"
#import "ChatViewController.h"
#import "HongBaoViewController.h"


@interface MessageCenterViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@property (strong, nonatomic) NSMutableArray *dataArr;

@property (assign, nonatomic) int pageNumber;

@end

@implementation MessageCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"消息中心";
    
    __weak __typeof(&*self) weakSelf = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 75;
    self.dataArr = [NSMutableArray array];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [MobClick beginLogPageView:@"消息中心页面"];
    [TalkingData trackPageBegin:@"消息中心页面"];
    
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"消息中心页面"];
    [TalkingData trackPageEnd:@"消息中心页面"];
    
}


-(void)getNetData{
    
    __weak typeof(&*self)weakSelf = self;
    _pageNumber = 1;
    //取用户ID
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"http://192.168.1.173:9999/api/v1/notification/read"];
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"pagenum":@(self.pageNumber),@"pagesize":@"10"}];
    
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                //请求成功，后续模型赋值操作
                NSArray *array = [responseObject objectForKey:@"data"];
                
                
                if (array.count) {
                    
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getNextPageData];
                        
                    }];
                }
                
                _pageNumber++;
                
                [weakSelf.dataArr removeAllObjects];
                
                
                for (NSDictionary *tempDic in array) {
                    RJMessageItemModel *model = [[RJMessageItemModel alloc] initWithDictionary:tempDic error:nil];
                    if (model) {
                        [weakSelf.dataArr addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
                
            }else if(state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            
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


-(void)getNextPageData{
    
    __weak typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"http://192.168.1.173:9999/api/v1/notification/read"];
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"pagenum":@(self.pageNumber),@"pagesize":@"10"}];
    
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                //请求成功，后续模型赋值操作
                NSArray *array = [responseObject objectForKey:@"data"];
                
                if (!array.count) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                _pageNumber++;
                
                
                for (NSDictionary *tempDic in array) {
                    RJMessageItemModel *model = [[RJMessageItemModel alloc] initWithDictionary:tempDic error:nil];
                    if (model) {
                        [weakSelf.dataArr addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
                
            }else if(state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
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



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RJMessageItemModel *itemModel = self.dataArr[indexPath.row];
    if (itemModel.image.length) {
        MsgCenterWithImageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgCenterWithImageTableViewCell"];
        [cell.icon sd_setImageWithURL:[NSURL URLWithString:itemModel.icon] placeholderImage:GetImage(@"default_1x1")];
        cell.nameLabel.text = itemModel.title;
        cell.describeLabel.text = itemModel.content;
        [cell.detailImageView sd_setImageWithURL:[NSURL URLWithString:itemModel.image] placeholderImage:GetImage(@"default_1x1")];
        cell.messageTimeLabel.text = itemModel.create_time;
        return cell;
    }else{
        MsgCenterWithOutImgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MsgCenterWithOutImgTableViewCell"];
        [cell.icon sd_setImageWithURL:[NSURL URLWithString:itemModel.icon] placeholderImage:GetImage(@"default_1x1")];
        cell.nameLabel.text = itemModel.title;
        cell.describeLabel.text = itemModel.content;
        cell.messageTimeLabel.text = itemModel.create_time;
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    RJMessageItemModel *itemModel = self.dataArr[indexPath.row];
    NSString *typeStr = itemModel.type;

    /**
     *
     (0, u"订单状态变化提醒"),
     (1, u"红包提醒"),
     (2, u"客服消息提醒"),
     (3, u"活动推送"),
     (4, u"账户预存款变动提醒"),
     (5, u"被关注"),
     (6, u"发布的东西被删除"),
     (7, u"自己的内容发生变化"),
     (8, u"关注的品牌有了动态"),
     (9, u"微店变化"),
     (10, u"搭配"),
     (11, u"合辑"),
     */
    switch (typeStr.intValue) {
        case 0:{
            //订单详情
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            
            RJPayOrderDetailViewController *orderVC = [story instantiateViewControllerWithIdentifier:@"RJPayOrderDetailViewController"];
            
            orderVC.orderId = [NSNumber numberWithInt:itemModel.info_id.intValue];
            
            [self.navigationController pushViewController:orderVC animated:YES];
            
        }
            break;
        case 1:{
            //红包
            HongBaoViewController *hongBaoVC = [[HongBaoViewController alloc] init];
            
            [self.navigationController pushViewController:hongBaoVC animated:YES];
            
        }
            break;
        case 2:{
            //客服

        }
            break;
        case 3:{
            //活动推送  待定
            [HTUIHelper addHUDToView:self.view withString:@"type3" hideDelay:1];
            
            
        }
            break;
        case 4:{
            //账户余额
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];

            YuEViewController *yuEVC = [story instantiateViewControllerWithIdentifier:@"YuEViewController"];
            
            [self.navigationController pushViewController:yuEVC animated:yuEVC];
        }
            break;
        case 5:{
            //粉丝列表
            UIStoryboard *story= [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
            
            RJUserFansListViewController *fansVc = [story instantiateViewControllerWithIdentifier:@"RJUserFansListViewController"];
            
            NSNumber *userID = [[RJAccountManager sharedInstance] account].id;
            
            fansVc.userId = userID;
            
            fansVc.type = RJFansListUser;
            
            [self.navigationController pushViewController:fansVc animated:YES];

        }
            break;
        case 6:{
            //纯展示，不跳转
            
        }
            break;
        case 7:{
            //暂未用

            }
            break;
        case 8:{
            //品牌
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
            
            RJBrandDetailRootViewController *brandDetailVC = [story instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
            
            brandDetailVC.brandId = [NSNumber numberWithInt:itemModel.info_id.intValue];
            
            [self.navigationController pushViewController:brandDetailVC animated:YES];
            
        }
            break;
        case 9:{
            //微店
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];

            RJUserCenteRootViewController *userCenterVC = [story instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
            
            userCenterVC.userId = [NSNumber numberWithInt:itemModel.info_id.intValue];
            
            [self.navigationController pushViewController:userCenterVC animated:YES];
            
        }
            break;
        case 10:{
            //搭配
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
            
            CollectionsViewController *collectionVC = [story instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
            
            collectionVC.collectionId = [NSNumber numberWithInt:itemModel.info_id.intValue];
            
            [self.navigationController pushViewController:collectionVC animated:YES];

            
        }
            break;
        case 11:{
            //合辑
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
            
            ThemeDetailVC *themeVC = [story instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
            
            themeVC.themeItemId = [NSNumber numberWithInt:itemModel.info_id.intValue];
            
            [self.navigationController pushViewController:themeVC animated:YES];

            
        }
            break;

            
        default:
            break;
    }
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        RJMessageItemModel *itemModel = self.dataArr[indexPath.row];
        
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        
        requestInfo.URLString = [NSString stringWithFormat:@"http://192.168.1.173:9999/api/v1/notification/delete"];
        
        if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
            [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
        }
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"id":itemModel.id}];
        
        __weak __typeof(&*self)weakSelf = self;
        
        [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"删除中..." xOffset:0 yOffset:0];
        
        [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    [self.dataArr removeObjectAtIndex:indexPath.row];
                    [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    [weakSelf.tableView reloadData];
                    [[HTUIHelper shareInstance] removeHUDWithEndString:@"删除成功" image:nil];
                    
                } else if (state.intValue == 1){
                    
                    [[HTUIHelper shareInstance] removeHUDWithEndString:responseObject[@"msg"] image:nil];
                }
                
            }
            
            else {
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
        }];

    }];
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    return @[deleteRowAction];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}
@end
