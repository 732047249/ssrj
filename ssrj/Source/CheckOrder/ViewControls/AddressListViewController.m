
#import "AddressListViewController.h"
#import "NSAttributedString+YYText.h"
#import "AddAddressViewController.h"
@interface AddressListViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,AddAddressDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSNumber * selectId;
@end

@implementation AddressListViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    [self setTitle:@"地址管理" tappable:NO];
    _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 70;
    self.dataArray = [NSMutableArray array];

    __weak __typeof(&*self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    [self.tableView.mj_header beginRefreshing];
    
    
}
-(void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/list.jhtml"];
    
//    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
    __weak __typeof(&*self)weakSelf = self;

    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *num = [responseObject objectForKey:@"state"];
            if (num.boolValue ==0) {
                NSArray *arr = [NSArray arrayWithArray:[responseObject[@"data"] copy]];
                [weakSelf.dataArray removeAllObjects];
                for (NSDictionary *dic in arr) {
                    RJAddressModel *model = [[RJAddressModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        if (model.id.intValue == self.model.id.intValue) {
                            //每次刷新重新赋值 比如修改了地址 选中了再回去
                            self.model = model;
                        }
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.tableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        }
        [weakSelf.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}
- (IBAction)addButtonAction:(id)sender {
    if (self.dataArray.count >= 10) {
        [HTUIHelper addHUDToView:self.view withString:@"地址信息不能超过10个,请删除后再试" hideDelay:1];
        return;
    }
    
    [self performSegueWithIdentifier:@"AddAddressSegue" sender:nil];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"AddAddressSegue"]) {
        AddAddressViewController *vc = segue.destinationViewController;
        vc.delegate = self;
        if (sender) {
            vc.addressModel = sender;
        }
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AddressListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell" forIndexPath:indexPath];
    cell.rightUtilityButtons = [self addrightButtons];
    RJAddressModel *model = self.dataArray[indexPath.row];
    cell.delegate  = self;
    if (model.isDefault.boolValue) {
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[默认地址]%@",model.fullName]];
        cell.addressLabel.text = [NSString stringWithFormat:@"[默认地址]%@",model.fullName];
        text.yy_font = [UIFont systemFontOfSize:14];
        text.yy_color = [UIColor blackColor];
        [text yy_setColor:[UIColor colorWithHexString:@"#5d32b5"] range:NSMakeRange(0, 6)];
        //    text.yy_lineSpacing = 10;
        cell.yyLabel.attributedText = text;
        
    }else{
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:model.fullName];
        text.yy_font = [UIFont systemFontOfSize:14];
        text.yy_color = [UIColor blackColor];
        //    text.yy_lineSpacing = 10;
        cell.yyLabel.attributedText = text;
        cell.addressLabel.text = model.fullName;
     }
    cell.nameLabel.text = model.consignee;
    cell.phoneLabel.text = model.phone;
    cell.editButton.tag = indexPath.row;
    [cell.editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell hideSelectedLine];
    
    if (self.model.id.integerValue == model.id.integerValue) {
        [cell showSelectedLine];
    }
    
    
    return cell;

}
- (NSArray *)addrightButtons{
    
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                title:@"默认"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"删除"];
    
    return rightUtilityButtons;
}
- (void)editButtonAction:(UIButton *)sender{
    RJAddressModel *model = self.dataArray[sender.tag];
    [self performSegueWithIdentifier:@"AddAddressSegue" sender:model];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.model = self.dataArray[indexPath.row];
    
    [self.tableView reloadData];
    //选中了
    
    [self back:nil];
    
}
#pragma mark -OverRide
- (void)back:(id)sender{
    
    [self.deleagte choseAddressWithModel:self.model];

    [self.navigationController popViewControllerAnimated:YES];
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:{
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            ZHRequestInfo *requestInfo = [ZHRequestInfo new];
            RJAddressModel *model = self.dataArray[cellIndexPath.row];
            requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/setDefault.jhtml?id=%d",model.id.intValue];
//            if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//                [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//            }
            __weak __typeof(&*self)weakSelf = self;

            [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"修改中..." xOffset:0 yOffset:0];
            
            [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject objectForKey:@"state"]) {
                    NSNumber *num = [responseObject objectForKey:@"state"];
                    if (num.boolValue == 0) {
                        for (RJAddressModel * subModel in weakSelf.dataArray) {
                            subModel.isDefault = [NSNumber numberWithBool:NO];
                            if (subModel.id.integerValue == model.id.integerValue) {
                                subModel.isDefault = [NSNumber numberWithBool:YES];
                            }
                        }
                        [weakSelf.tableView reloadData];
                        [[HTUIHelper shareInstance]removeHUDWithEndString:@"修改成功" image:nil];
                    }else{
                        [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                    }
                }else{
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
                    
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];

            }];

        }
            break;
        case 1:
        {
            // Delete button was pressed
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            ZHRequestInfo *requestInfo = [ZHRequestInfo new];
            RJAddressModel *model = self.dataArray[cellIndexPath.row];
            requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/delete.jhtml?id=%d",model.id.intValue];
//            if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//                [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//            }
            [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"删除中..." xOffset:0 yOffset:0];
            [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([responseObject objectForKey:@"state"]) {
                    NSNumber *num = [responseObject objectForKey:@"state"];
                    if (num.boolValue == 0) {
                        if (model.id.intValue == self.model.id.intValue) {
                            self.model = nil;
                        }
                        [_dataArray removeObjectAtIndex:cellIndexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath]
                                              withRowAnimation:UITableViewRowAnimationNone];
                        [self.tableView reloadData];
                        [[HTUIHelper shareInstance]removeHUDWithEndString:@"删除成功" image:nil];
                    }else{
                        [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                    }
                }else{
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
            }];
     
            break;
        }
        default:
            break;
    }
}
#pragma mark -AddAddressDelegate
- (void)reloadNetData{
    [self getNetData];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"地址管理页面"];
    [TalkingData trackPageBegin:@"地址管理页面"];
    [self forbiddenSideBack];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"地址管理页面"];
    [TalkingData trackPageEnd:@"地址管理页面"];
    [self resetSideBack];
}

-(void)forbiddenSideBack{
    
    //关闭ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
    
}
- (void)resetSideBack {
    
    //开启ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
@end


@implementation AddressListTableViewCell
- (void)showSelectedLine{
    self.bgView.layer.borderColor = [UIColor colorWithHexString:@"#5d32b5"].CGColor;
    self.bgView.layer.borderWidth = 2;
}
- (void)hideSelectedLine{
    self.bgView.layer.borderColor = [UIColor clearColor].CGColor;
    self.bgView.layer.borderWidth = 0;

}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.bgView.layer.borderWidth = 2;
    self.bgView.layer.borderColor = [UIColor clearColor].CGColor;

}
@end
