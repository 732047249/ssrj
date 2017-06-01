
#import "CartViewController.h"
#import "CartTableViewCell.h"
#import "CartDataModel.h"
#import "UIImage+New.h"
#import "RJCheckOrderModel.h"
#import "CheckOrderViewController.h"
#import "GoodsDetailViewController.h"
#import "BindTelephoneController.h"

#import "CheckOrderViewController.h"

@interface CartViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *toolBarView;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *allSelectButton;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) IBOutlet UIView *emptyView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CartDataModel *model;
@property (assign, nonatomic) NSInteger  totalCost;

@property (weak, nonatomic) IBOutlet UILabel *totalCostLabel;

@property (strong, nonatomic) UIBarButtonItem * editBarItem;
@property (assign, nonatomic) BOOL isEditState;
@property (weak, nonatomic) IBOutlet UIButton *editDeleteButton;

@property (weak, nonatomic) IBOutlet UIView *priceView;
/**
 *  3.1.0版本 编辑下 加减 返回整个购物车信息 这个商品是否选中这个状态没有和后台交互 建立一个数组保存用户选中的itemId
    和model中customIsChecked 保持一致 方便计算价格
 */
@property (nonatomic,strong) NSMutableArray * selectItemIdArray;
@end

@implementation CartViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.selectItemIdArray = [NSMutableArray array];
    self.totalCost = 0;
    [self.submitButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#5d32b5"] size:self.submitButton.size] forState:0];
    [self.submitButton setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#e5e5e5"] size:self.submitButton.size] forState:UIControlStateDisabled];

    self.dataArray = [NSMutableArray array];
    [self addBackButton];
    [self setTitle:@"购物车" tappable:NO];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    self.tableView.tableHeaderView = nil;
    
    self.tableView.estimatedRowHeight = 117;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    
    UIButton *button = [UIButton buttonWithType:0];
    [button setTitle:@"编辑" forState:0];
    [button setTitle:@"完成" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor whiteColor] forState:0];
    button.frame = CGRectMake(0, 0, 44, 50);
    [button addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.editBarItem = [[UIBarButtonItem alloc]initWithCustomView:button];
//    self.navigationItem.rightBarButtonItem = self.editBarItem;
    self.isEditState = NO;
    __weak __typeof(&*self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.tableView.mj_header beginRefreshing];
    self.submitButton.trackingId = [NSString stringWithFormat:@"%@&submitButton",NSStringFromClass(self.class)];
}


- (void)showToolBar{
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
    self.toolBarView.hidden = NO;
    self.navigationItem.rightBarButtonItem = self.editBarItem;

}
- (void)showNoMoreDataView{
    self.tableView.tableHeaderView = self.emptyView;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.toolBarView.hidden = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    UIButton *button =(UIButton *) self.editBarItem.customView;
    button.selected = YES;
    [button sendActionsForControlEvents:UIControlEventTouchUpInside];
}
- (void)getNetData{
//#warning debug
//    [RJAccountManager sharedInstance].account.token = @"12345";
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"api/v5/member/cart.jhtml"];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                NSDictionary *data = responseObject[@"data"];
                NSError __autoreleasing *e = nil;
                
                self.model = [[CartDataModel alloc]initWithDictionary:data error:&e];
                if (e) {
                    [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                    [self.tableView.mj_header endRefreshing];
                    return ;
                }
                if (self.model.count) {
                    [RJAccountManager sharedInstance].account.cartProductQuantity = self.model.count;
                    [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                    [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
                }
                [self.selectItemIdArray removeAllObjects];
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:[self.model.itemList copy]];
                for (CartItemModel *cartItem in self.dataArray) {
                    cartItem.customIsChecked = [NSNumber numberWithBool:NO];
                }
                if (self.dataArray.count) {
                    [self showToolBar];
                    [self addAllCostCount];
                }else{
                    [self showNoMoreDataView];
                }
                [self.tableView reloadData];
            }else if(state.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];

            }
            //token失效
            else if(state.intValue == 2){
//                if ([RJAccountManager sharedInstance].token) {
//                    [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                }
                [self.navigationController popViewControllerAnimated:NO];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        }
        [self.tableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error);
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [self.tableView.mj_header endRefreshing];

    }];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (self.shouldReloadView) {
        [self getNetData];
        self.shouldReloadView = NO;
    }
    [MobClick beginLogPageView:@"购物车页面"];
    [TalkingData trackPageBegin:@"购物车页面"];

}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"购物车页面"];
    [TalkingData trackPageEnd:@"购物车页面"];


}
#pragma mark - UITableViewDataSource&UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
//    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CartItemModel *model = self.dataArray[indexPath.row];
    /**
     *  售罄状态
     */
    if (model.product.isOutOfStock.boolValue) {
        CartSoldOutTableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartSoldOutCell" forIndexPath:indexPath];
        cell.model = model;
        [cell.choceButton addTarget:self action:@selector(cellChoseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.choceButton.tag = indexPath.row;
        cell.editView.hidden = YES;
//        if (self.isEditState) {
//            cell.editView.hidden = NO;
//        }
        cell.choceButton.selected = NO;
        model.customIsChecked = @(NO);
        if ([self.selectItemIdArray containsObject:model.cartItemId]) {
            cell.choceButton.selected = YES;
            model.customIsChecked = @(YES);
        }
        return cell;
      
    }
    
    /**
     *  正常状态
     */
    CartTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartCell" forIndexPath:indexPath];
    cell.model = model;
    [cell.choceButton addTarget:self action:@selector(cellChoseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.choceButton.tag = indexPath.row;
    cell.editView.hidden = YES;
    if (self.isEditState) {
        cell.editView.hidden = NO;
    }
    cell.preSaleLabel.text = @"";
    cell.preSaleDesLabel.text = model.preSaleDesc;

//    if (model.product.isPreSale.boolValue) {
////        cell.preSaleLabel.text = @"[预售] ";
//        cell.preSaleDesLabel.text = @"现货2件，预售1件 预售预计发货时间为2017-10-11";
//    }
    cell.addButton.tag = indexPath.row;
    cell.subtractButton.tag = indexPath.row;
    [cell.addButton addTarget:self action:@selector(addButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.subtractButton addTarget:self action:@selector(subtractButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.choceButton.selected = NO;
    model.customIsChecked = @(NO);
    if ([self.selectItemIdArray containsObject:model.cartItemId]) {
        cell.choceButton.selected = YES;
        model.customIsChecked = @(YES);
    }
    return cell;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 105;
//}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //调用删除接口
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        CartItemModel *model = self.dataArray[indexPath.row];
//        requestInfo.URLString = [NSString stringWithFormat:@"api/v2/member/cart/delete.jhtml?id=%ld&token=%@",(long)model.cartItemId.integerValue,[RJAccountManager sharedInstance].token];
        requestInfo.URLString = [NSString stringWithFormat:@"api/v5/member/cart/delete.jhtml?id=%ld",(long)model.cartItemId.integerValue];

        [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"删除中..." xOffset:0 yOffset:0];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *number = [responseObject objectForKey:@"state"];
                if (number.boolValue == 0) {
                    [self.dataArray removeObjectAtIndex:indexPath.row];
                    [[HTUIHelper shareInstance]removeHUD];
                    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView reloadData];
                    [self addAllCostCount];
                    if (!self.dataArray.count) {
                        [self showNoMoreDataView];
                    }
                    NSDictionary *dic = [responseObject objectForKey:@"data"];
                    NSNumber *quantity = [dic objectForKey:@"quantity"];
                    
//                    NSDictionary *userInfoDic = @{@"quantity":quantity};
                    if (quantity) {
                        [RJAccountManager sharedInstance].account.cartProductQuantity = quantity;
                        //购物车内商品数量更改（此处为删减）发送通知
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
                        [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                    }
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
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CartItemModel *model = self.dataArray[indexPath.row];
    NSNumber *goodId = model.product.goodsId;
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    NSNumber *goodId2 = goodId;
    goodsDetaiVC.goodsId = goodId2;

    self.shouldReloadView = YES;
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];

}
#pragma mark -
- (void)cellChoseButtonAction:(UIButton *)button{
    CartItemModel *model = self.dataArray[button.tag];
    if ([self.selectItemIdArray containsObject:model.cartItemId]) {
        [self.selectItemIdArray removeObject:model.cartItemId];
        button.selected = NO;
        model.customIsChecked = [NSNumber numberWithBool:NO];
    }else{
        [self.selectItemIdArray addObject:model.cartItemId];
        button.selected = YES;
        model.customIsChecked = [NSNumber numberWithBool:YES];
    }
//    button.selected = !button.selected;
//    model.customIsChecked = [NSNumber numberWithBool:button.selected];
    
    [self addAllCostCount];
}

#pragma mark - 计算总价
- (void)addAllCostCount{
    NSInteger cost = 0;
    BOOL isAllSelected = YES;
    BOOL isSelected = NO;
    for (CartItemModel *model in self.dataArray) {
        if (model.customIsChecked.boolValue) {
            isSelected = YES;
            NSInteger price = model.product.effectivePrice.integerValue;
            cost += (price * model.quantity.integerValue);
        }else{
            isAllSelected = NO;
        }
    }

    self.submitButton.enabled = isSelected;

    if (isAllSelected) {
        self.allSelectButton.selected = YES;
    }else{
        self.allSelectButton.selected = NO;
    }
    self.totalCost = cost;
    self.totalCostLabel.text = [NSString stringWithFormat:@"%ld",(long)self.totalCost];
    

}
#pragma mark - 结算提交
- (IBAction)submitButtonAction:(id)sender {
    /**
     *  结算接口  segue JieSuanSegue
     */

    /**
     * 3.0.1
     */
    RJAccountModel *account = [RJAccountManager sharedInstance].account;
    if (account.isBinding.intValue == 0 || account.isBinding == nil) {
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        BindTelephoneController *bindVC = [sb instantiateViewControllerWithIdentifier:@"BindTelephoneController"];
        bindVC.userIconURL = account.avatar;
        bindVC.userNickName = account.nickname;
        [self presentViewController:bindVC animated:YES completion:nil];
        return;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    for (CartItemModel *model in self.dataArray) {
        if (model.customIsChecked.boolValue) {
            [arr addObject:model.cartItemId];
        }
    }
    if (!arr.count) {
        return;
    }
    ZHRequestInfo *requesInfo = [ZHRequestInfo new];
    NSString *str = [arr componentsJoinedByString:@","];
    /**
     *  2.1.4版本启用V5接口   3.1.0 启用包含预售的版本
     */
    requesInfo.URLString = @"/api/v5/member/order/checkout_orders.jhtml";
    
//    requesInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token,@"ids":str}];
    requesInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"ids":str}];

    
    CheckOrderViewController *checkOrderVc = [self.storyboard instantiateViewControllerWithIdentifier:@"CheckOrderViewController"];

    
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requesInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSDictionary *dic = responseObject[@"data"];
                NSError __autoreleasing *e = nil;
                RJCheckOrderModel *model = [[RJCheckOrderModel alloc]initWithDictionary:dic error:&e];
                if (model) {
                    [[HTUIHelper shareInstance]removeHUD];
                    
                    checkOrderVc.model = model;
                    self.shouldReloadView = YES;

                    [self.navigationController pushViewController:checkOrderVc animated:YES];
                    
//                    [self performSegueWithIdentifier:@"JieSuanSegue" sender:model];
                    
                }else{
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];

                }
                
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
//    if ([segue.identifier isEqualToString:@"JieSuanSegue"]) {
//        CheckOrderViewController *vc = segue.destinationViewController;
//        vc.model = sender;
//        self.shouldReloadView = YES;
//    }
}
#pragma mark - 全选
- (IBAction)allSelectButtonAction:(id)sender {
    UIButton *button = sender;
    button.selected = !button.selected;
    if (button.isSelected) {
        for (CartItemModel *model in self.dataArray) {
            model.customIsChecked = [NSNumber numberWithBool:YES];
            if (![self.selectItemIdArray containsObject:model.cartItemId]) {
                [self.selectItemIdArray addObject:model.cartItemId];
            }
            [self addAllCostCount];
            [self.tableView reloadData];
        }
    }else{
        //处于全选状态 取消全选
        for (CartItemModel *model in self.dataArray) {
            model.customIsChecked = [NSNumber numberWithBool:NO];
            [self addAllCostCount];
            [self.tableView reloadData];
        }
        [self.selectItemIdArray removeAllObjects];
    }
}
#pragma mark -去购物
- (IBAction)emptyButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 编辑
- (void)editButtonAction:(UIButton *)button{
    if (!button.selected&&self.dataArray.count) {
        self.isEditState = YES;
        button.selected = YES;
        [self showEditToolBar];
    }else{
        button.selected = NO;
        [self hideEditToolBar];
        self.isEditState = NO;
    }
    [self.tableView reloadData];
}
- (void)showEditToolBar{
    self.editDeleteButton.hidden = NO;
    self.priceView.hidden = YES;
}
- (void)hideEditToolBar{
    self.editDeleteButton.hidden = YES;
    self.priceView.hidden = NO;
    [self addAllCostCount];
}
- (IBAction)editDeleteButtonAction:(id)sender {
    /**
     *  拿到选中的index 和 cartItemId
     */
    NSMutableArray *selectIds = [NSMutableArray array];
    NSMutableIndexSet *set = [[NSMutableIndexSet alloc]init];
    [self.dataArray enumerateObjectsUsingBlock:^(CartItemModel * model, NSUInteger idx, BOOL * _Nonnull stop) {
        //处于选中状态
        if (model.customIsChecked.boolValue) {
            [selectIds addObject:model.cartItemId];
            [set addIndex:idx];
        }
    }];
    if (!selectIds.count) {
        return;
    }
    /**
     *  调用批量删除接口
     */
    NSString * ids =[selectIds componentsJoinedByString:@","];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
//    requestInfo.URLString = [NSString stringWithFormat:@"/api/v3/member/cart/deleteCartItemIds.jhtml?token=%@&ids=%@",[RJAccountManager sharedInstance].token,ids];
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/cart/deleteCartItemIds.jhtml?ids=%@",ids];

    
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"删除中..." xOffset:0 yOffset:0];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *num = responseObject[@"state"];
            if (num.boolValue == 0 ) {
                [self.dataArray removeObjectsAtIndexes:set];
                [self.tableView reloadData];
                [self addAllCostCount];
                if (!self.dataArray.count) {
                    [self showNoMoreDataView];
                    
                }
                NSDictionary *dic = [responseObject objectForKey:@"data"];
                
                NSNumber *quantity = [dic objectForKey:@"quantity"];
                
                if (quantity) {
                    [RJAccountManager sharedInstance].account.cartProductQuantity = quantity;
                    //购物车内商品数量更改（此处为删减）发送通知
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
                    [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];

                }
                
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
    
   
}



#pragma mark -
#pragma mark 购物车编辑时候 加减商品数量
- (void)addButtonAction:(UIButton *)sender{
    CartItemModel *model = self.dataArray[sender.tag];
//    NSInteger count = model.quantity.integerValue;
    /**
     *  改接口了 count 不用了 加减1 后台处理 库存不足时候往下减不再判断库存 1代表加
     */
//    count ++;
    
    [self editCountWithCountNumber:1 cartItemModel:model];
}

- (void)subtractButtonAction:(UIButton *)sender{
    CartItemModel *model = self.dataArray[sender.tag];
    NSInteger count = model.quantity.integerValue;
    if (count <= 1) {
        sender.enabled = NO;
        return;
    }
//    count --;
    /**
     *  改接口了 count 不用了 加减1 后台处理 库存不足时候往下减不再判断库存 0代表减
     */
    [self editCountWithCountNumber:0 cartItemModel:model];
}
- (void)editCountWithCountNumber:(NSInteger)count cartItemModel:(CartItemModel *)model{
    //请求服务器
    ZHRequestInfo *requstInfo = [ZHRequestInfo new];
//    requstInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/cart/edit.jhtml"];
    //    requstInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{@"id":model.cartItemId,@"quantity":@(count)}];
 
    requstInfo.URLString = [NSString stringWithFormat:@"api/v5/member/cart/update.jhtml"];
    requstInfo.postParams = [NSMutableDictionary dictionaryWithDictionary:@{@"id":model.cartItemId,@"type":@(count)}];

//    NSLog(@"%@",requstInfo.postParams);
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfo:requstInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state.intValue == 0) {
            NSDictionary *data = responseObject[@"data"];
            NSError __autoreleasing *e = nil;
            
            self.model = [[CartDataModel alloc]initWithDictionary:data error:&e];
            if (e) {
                [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
                return ;
            }
            if (self.model.count) {
                [RJAccountManager sharedInstance].account.cartProductQuantity = self.model.count;
                [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationCartNumberChanged object:nil];
            }
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:[self.model.itemList copy]];
            for (CartItemModel *cartItem in self.dataArray) {
                if ([self.selectItemIdArray containsObject:cartItem.cartItemId]) {
                    cartItem.customIsChecked = @(YES);
                }else{
                    cartItem.customIsChecked = [NSNumber numberWithBool:NO];
                }
            }
            if (self.dataArray.count) {
//                [self showToolBar];
                [self addAllCostCount];
            }else{
                [self showNoMoreDataView];
            }
            [[HTUIHelper shareInstance]removeHUD];

            [self.tableView reloadData];
            
        }else if(state.intValue == 1){
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        //        NSLog(@"%@",error);
    }];
}
@end
