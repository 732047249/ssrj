//
//  DestinationManageViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "DestinationManageViewController.h"
#import "NSAttributedString+YYText.h"
#import "AddDestinationTableViewController.h"


@interface DestinationManageViewController ()<UITableViewDataSource, UITableViewDelegate, AddDestinationTableViewControllerDelegate>

@property (strong, nonatomic) DestinationModel *destinationModel;

@property (strong, nonatomic) NSMutableArray *dataArr;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) UIButton *editButton;

@end

@implementation DestinationManageViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"地址管理页面"];
    [TalkingData trackPageBegin:@"地址管理页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"地址管理页面"];
    [TalkingData trackPageEnd:@"地址管理页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"地址管理";
    __weak __typeof(&*self)weakSelf = self;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
        
    }];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 72;
    
}

#pragma mark --AddDestinationTableViewControllerDelegate代理方法
- (void)reloadDestinationData {
    
    [self getData];
}

#pragma mark --获取用户地址信息
- (void)getData{
    
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //token
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/receiver/list.jhtml?pageNumber=20"];
    
    requestInfo.URLString = urlStr;
    
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        if ([responseObject objectForKey:@"state"]) {
                
            NSNumber *state = [responseObject objectForKey:@"state"];
                
            if (state.intValue == 0) {
                    
                NSArray *destinationArr = [responseObject objectForKey:@"data"];
                
                [weakSelf.dataArr removeAllObjects];
                    
                NSMutableArray *arrayModels = [NSMutableArray array];
                    
                for (NSDictionary *tempDic in destinationArr) {
                        
                    DestinationModel *model = [[DestinationModel alloc] initWithDictionary:tempDic error:nil];
                        
                    [arrayModels addObject:model];
                }
                weakSelf.dataArr = [arrayModels mutableCopy];
                [weakSelf.tableView reloadData];
            } else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        }
        
        else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

        [weakSelf.tableView.mj_header endRefreshing];
        
    }];    
}


//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    return 72;
//}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.dataArr.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *destinationCellID = @"DestinationCellID";
    
    DestinationCell *destinationCell = [tableView dequeueReusableCellWithIdentifier:destinationCellID];
    //防止cell重用时字重叠
    destinationCell.destinationLabel.text = @"";

    DestinationModel *model = self.dataArr[indexPath.row];
    
    //hideSelectedLine
    destinationCell.layer.borderColor = [UIColor clearColor].CGColor;
    destinationCell.layer.borderWidth =  0;

    if (model.isDefault.boolValue) {
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[默认地址]%@", model.fullName]];
        
        
        destinationCell.destinationLabel.text = [NSString stringWithFormat:@"[默认地址]%@", model.fullName];// model.fullName;
        
        text.yy_font = [UIFont systemFontOfSize:14];
        text.yy_color = [UIColor blackColor];
        [text yy_setColor:[UIColor colorWithHexString:@"#5d32b5"] range:NSMakeRange(0, 6)];
        destinationCell.yyLabel.attributedText = text;
        
    } else {
        
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:model.fullName];
        text.yy_font = [UIFont systemFontOfSize:14];
        text.yy_color = [UIColor blackColor];
        destinationCell.yyLabel.attributedText = text;
        destinationCell.destinationLabel.text = model.fullName;
    }
    
    destinationCell.userNameLabel.text = model.consignee;
    destinationCell.phoneLabel.text = model.phone;

    
    //toEditDestinationButton
    destinationCell.toEditDestinationButton.tag = indexPath.row;
    [destinationCell.toEditDestinationButton addTarget:self action:@selector(toEditDestinationWithModel:) forControlEvents:UIControlEventTouchUpInside];

    
    return destinationCell;
}

-(void)toEditDestinationWithModel:(UIButton *)sender  {
    //据sender.tag区别cell的model
    DestinationModel *toEditorDestModel = self.dataArr[sender.tag];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    AddDestinationTableViewController *addDestVC = [story instantiateViewControllerWithIdentifier:@"AddDestinationTableViewController"];
    addDestVC.addressModel =(RJAddressModel *)toEditorDestModel;
    addDestVC.delegate = self;
    [self.navigationController pushViewController:addDestVC animated:YES];
}

//未使用
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    DestinationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//
//    _editButton = cell.toEditDestinationButton;
//    
//    [self toEditDestinationButtonClicked];
//    
//}


-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        DestinationModel *model = self.dataArr[indexPath.row];
        
        [self.dataArr removeObjectAtIndex:indexPath.row];
        [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //发往后台删除数据
        [self toDeletDestinationWithPageNumber:model.id];
        
        [self.tableView reloadData];
        
    }];
    deleteRowAction.backgroundColor = [UIColor redColor];
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"默认" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        DestinationModel *model = self.dataArr[indexPath.row];

        //发往后台设置默认地址
        [self toSetDefaultDestinationWithDestinationModel:model];

        
        [self.dataArr exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
        
        
        [self.tableView reloadData];
        
    }];
    topRowAction.backgroundColor = [UIColor lightGrayColor];

    return @[deleteRowAction,topRowAction];
    
}

//删除
- (void)toDeletDestinationWithPageNumber:(NSNumber *)destinationID {
    
    //时间戳
    NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timeIntrl = [timesp timeIntervalSince1970] *1000 *1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
    

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/delete.jhtml?id=%d&timeString=%@",destinationID.intValue, timeString];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"删除中..." xOffset:0 yOffset:0];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
       
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                if (self.destinationModel.id.intValue == destinationID.intValue) {
                    self.destinationModel = nil;
                }
  
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
}


//设置默认地址(修改信息) //未完成默认地址置顶功能
- (void)toSetDefaultDestinationWithDestinationModel:(DestinationModel *)model{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/update.jhtml?id=%d",model.id.intValue];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"areaId":model.areaId,
                                                                            @"consignee":model.consignee,
                                                                            @"isDefault":[NSNumber numberWithBool:1],
                                                                            @"address":model.address,
                                                                            @"zipCode":model.zipCode,
                                                                            @"phone":model.phone
                                                                            }];
    if (self.destinationModel) {
        requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/update.jhtml"];
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.destinationModel.id}];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"设置中..." xOffset:0 yOffset:0];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
               
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"设置成功" image:nil];

                [weakSelf getData];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    if ([self.destinationDelegate respondsToSelector:@selector(reloadDestinationDataWithDestinationModel:)]) {
                        
                        [self.destinationDelegate reloadDestinationDataWithDestinationModel:model];
                    }
                    
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    
                });
                
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.dataArr.count == 0) {
        
        return SCREEN_HEIGHT*0.82;
    } else {
        
        return 0;
    }
}

#pragma mark --添加新地址Button Action

- (IBAction)addNewDestButtonAction:(id)sender {
    
    if (self.dataArr.count >= 10) {
        
        [HTUIHelper addHUDToView:self.view withString:@"地址记录不可超过10条" hideDelay:1];
        return;
    }
    
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    AddDestinationTableViewController *addDestinationVC = [story instantiateViewControllerWithIdentifier:@"AddDestinationTableViewController"];
    addDestinationVC.delegate = self;
    
    [self.navigationController pushViewController:addDestinationVC animated:YES];

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DestinationModel *model = self.dataArr[indexPath.row];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if ([self.destinationDelegate respondsToSelector:@selector(reloadDestinationDataWithDestinationModel:)]) {
            
            [self.destinationDelegate reloadDestinationDataWithDestinationModel:model];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
        
    });
    
}

//-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    
//    if ([segue.identifier isEqualToString:@"AddDestinationTableViewController"]) {
//        
//        AddDestinationTableViewController *addDestinationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddDestinationTableViewController"];
//        addDestinationVC.delegate = self;
//
////        [self.navigationController pushViewController:addDestinationVC animated:YES];
//    }
//    
//}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



#pragma mark --DestinationModel.m
@implementation DestinationModel

@end


#pragma mark --DestinationCell.m
@implementation DestinationCell

-(void)awakeFromNib {
    
}

@end




