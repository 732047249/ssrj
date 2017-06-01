//
//  SSClientViewController.m
//  ssrj
//
//  Created by mac on 17/2/15.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "SSClientViewController.h"
#import "SSMyClientModel.h"
#import "RJUserCenteRootViewController.h"

@interface SSClientViewController ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (assign, nonatomic) int pageNumber;

@property (strong, nonatomic) NSMutableArray *dataArr;

@end

@implementation SSClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    self.title = @"我的客户";
    __weak __typeof(&*self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       
        [weakSelf getNetData];
        
    }];
    
    [self.tableView.mj_header beginRefreshing];

}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [MobClick beginLogPageView:@"我的客户"];
    [TalkingData trackPageBegin:@"我的客户"];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的客户"];
    [TalkingData trackPageEnd:@"我的客户"];
    
}

- (void)getNetData {
    
    __weak typeof(&*self)weakSelf = self;
    
    _pageNumber = 1;
 
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
 
    NSString *urlStr = [NSString stringWithFormat:@"http://report.ssrj.com:11011/api/v1/yidian/record?pagenum=%d&pagesize=10",_pageNumber];
 
    requestInfo.URLString = urlStr;
 
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
 
        if ([responseObject objectForKey:@"state"]) {
 
            NSNumber *state = [responseObject objectForKey:@"state"];
 
            if (state.intValue == 0) {
 
                //请求成功，后续模型赋值操作
                NSArray *netDataArr = [responseObject objectForKey:@"data"];
 
 
                if (netDataArr.count) {
 
                    weakSelf.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
 
                        [weakSelf getNextPageData];
 
                    }];
                }
 
                _pageNumber++;
 
                [weakSelf.dataArr removeAllObjects];
 
                NSMutableArray *arrayModels = [NSMutableArray array];
 
                for (NSDictionary *tempDic in netDataArr) {
                    SSMyClientModel *model = [[SSMyClientModel alloc] initWithDictionary:tempDic error:nil];
 
                    [arrayModels addObject:model];
                }
 
                weakSelf.dataArr = [arrayModels mutableCopy];
                [weakSelf.tableView reloadData];
 
            }else if(state.intValue == 1){
 
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
 
            }else if(state.intValue == 2){
 
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
 
     NSString *urlStr = [NSString stringWithFormat:@"http://report.ssrj.com:11011/api/v1/yidian/record?pagenum=%d&pagesize=10",_pageNumber];
 
     requestInfo.URLString = urlStr;
 
     [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
 
         if ([responseObject objectForKey:@"state"]) {
 
             NSNumber *state = [responseObject objectForKey:@"state"];
 
             if (state.intValue == 0) {
 
                 //请求成功，后续模型赋值操作
                 NSArray *orderArr = [responseObject objectForKey:@"data"];
 
                 if (!orderArr.count) {
 
                     [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                     return ;
                 }
 
                 _pageNumber++;
 
                 NSMutableArray *arrayModels = [NSMutableArray array];
 
                 for (NSDictionary *tempDic in orderArr) {
                     SSMyClientModel *model = [[SSMyClientModel alloc] initWithDictionary:tempDic error:nil];
 
                     [arrayModels addObject:model];
                 }
 
                 [weakSelf.dataArr addObjectsFromArray:arrayModels];
                 [weakSelf.tableView reloadData];
 
             }else if(state.intValue == 1){
 
                 [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
 
             }else if(state.intValue == 2){
 
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


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if (self.dataArr.count == 0) {
        
        return SCREEN_HEIGHT*0.82;
    } else {
        
        return 0;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SSMyClientModel *model = self.dataArr[indexPath.row];
    
    if ([model.isAllDisplay isEqualToNumber:[NSNumber numberWithInt:1]]) {
        
        
        if (model.ordersQuantity.intValue > 0) {
            
            if (model.ordersQuantity.intValue <= 8) {
                
                return 80 + (SCREEN_WIDTH - 16)*37/152 + 30*(model.ordersQuantity.intValue);
            }
            else {
                
                return 80 + (SCREEN_WIDTH - 16)*37/152 + 30*8;
            }
        }
    }
    
    return 80 + (SCREEN_WIDTH - 16)*37/152 + 22;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"SSMyClientTableViewCell";
    
    SSMyClientModel *model = self.dataArr[indexPath.row];
    
    SSMyClientTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        
        cell = [[SSMyClientTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    cell.model = model;
    if (model.isAllDisplay.intValue == 0) {
        
        cell.orderTableView.userInteractionEnabled = NO;
    }
    else {
        
        cell.orderTableView.userInteractionEnabled = YES;
    }
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImageTap:)];
    imageTap.delegate = self;
    cell.userImageView.tag = indexPath.row;
    cell.userImageView.userInteractionEnabled = YES;
    [cell.userImageView addGestureRecognizer:imageTap];
    
    cell.moreButton.tag = indexPath.row;
    cell.moreButton.selected = [model.isAllDisplay boolValue];
    [cell.moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
    
}

#pragma mark -查看更多button点击事件
- (void)moreButtonClicked:(UIButton *)sender {
    
    SSMyClientModel *model = self.dataArr[sender.tag];

    sender.selected = !sender.selected;
    
    if (sender.selected) {
        
        model.isAllDisplay = [NSNumber numberWithInt:1];
        
    } else {
        
        model.isAllDisplay = [NSNumber numberWithInt:0];
        
    }
    
    [self.tableView reloadData];
}

#pragma mark -点击客户头像
- (void)handleImageTap:(UITapGestureRecognizer *)recognizer {
    
    SSMyClientModel *model = self.dataArr[recognizer.view.tag];

    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    
    RJUserCenteRootViewController *rootVC = [story instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    
    rootVC.userId = model.id;
    rootVC.userName = model.memberName;
    
    [self.navigationController pushViewController:rootVC animated:YES];
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
        //无需跳转
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end







#pragma mark -微店－我的客户－客户tableViewCell


@interface SSMyClientTableViewCell ()<UITableViewDataSource, UITableViewDelegate>
//上半部分
@property (weak, nonatomic) IBOutlet UIView *upBgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fashionMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
//下半部分
@property (weak, nonatomic) IBOutlet UIView *downBgView;

@property (assign,nonatomic) int pageNumber;

@property (strong, nonatomic) ClientOrderInfoModel <Optional>*firstModel;

@end

@implementation SSMyClientTableViewCell

-(void)awakeFromNib {

    self.upBgView.layer.cornerRadius = 10;
    self.downBgView.layer.cornerRadius = 10;
    self.downBgView.layer.masksToBounds = YES;
    self.userImageView.layer.cornerRadius = ((SCREEN_WIDTH-16)*37.0/152.0-20.0)/2.0;
    self.userImageView.layer.masksToBounds = YES;
    
    self.orderTableView.delegate = self;
    self.orderTableView.dataSource = self;
    self.orderDataArr = [NSMutableArray array];
    __weak __typeof(self)weakSelf = self;
    _pageNumber = 1;
    
    self.orderTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetOrderData];
    }];
}




-(void)prepareForReuse {
    
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    self.userNameLabel.text = @"";
    self.fashionMoneyLabel.text = @"";
    self.orderNumLabel.text = @"";
    self.moreButton.selected = NO;
    
}

-(void)setModel:(SSMyClientModel *)model {
    
    _model = model;
    [self.userImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    self.userNameLabel.text = model.memberName;
    self.fashionMoneyLabel.text = [NSString stringWithFormat:@"时尚币:%@",model.totalIntegral];
    self.orderNumLabel.text = model.ordersQuantity.stringValue;
    self.orderDataArr = @[].mutableCopy;
    self.orderTableView.delegate = self;
    self.orderTableView.dataSource = self;
    self.firstModel = model.orderInfor;
    
    if (model.ordersQuantity.intValue == 0) {
        
        self.downBgView.hidden = YES;
    }
    else {
        
        self.downBgView.hidden = NO;
    }
    
    [self getNetOrderData];
}



- (void)getNetOrderData {
    
    __weak typeof(&*self)weakSelf = self;
    _pageNumber = 1;
    //取用户ID
    NSNumber *ID = _model.id;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://report.ssrj.com:11011/api/v1/yidian/customer?member=%@&pagenum=%d&pagesize=10",ID,_pageNumber];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                //请求成功，后续模型赋值操作
                NSArray *netDataArr = [responseObject objectForKey:@"data"];
                
                if (netDataArr.count) {
                    
                    weakSelf.orderTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getNextPageOrderData];
                        
                    }];
                }
                
                _pageNumber++;
                
                [weakSelf.orderDataArr removeAllObjects];
                
                NSMutableArray *arrayModels = [NSMutableArray array];
                
                for (NSDictionary *tempDic in netDataArr) {
                    ClientOrderInfoModel *model = [[ClientOrderInfoModel alloc] initWithDictionary:tempDic error:nil];
                    [arrayModels addObject:model];
                }
                
                weakSelf.orderDataArr = [arrayModels mutableCopy];
                
                [weakSelf.orderTableView reloadData];
                
            }else if(state.intValue == 1){
                
                [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[responseObject objectForKey:@"msg"] hideDelay:1];
                
            }else if(state.intValue == 2){
                
            }
        }
        else {
            
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.orderTableView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[error localizedDescription] hideDelay:1];
        [weakSelf.orderTableView.mj_header endRefreshing];
        
    }];
    
}


-(void)getNextPageOrderData{
    
    __weak typeof(&*self)weakSelf = self;
    
    //取用户ID
    NSNumber *ID = [[RJAccountManager sharedInstance] account].id;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://report.ssrj.com:11011/api/v1/yidian/customer?member=%@&pagenum=%d&pagesize=10",ID,_pageNumber];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                //请求成功，后续模型赋值操作
                NSArray *netDataArr = [responseObject objectForKey:@"data"];
                
                if (!netDataArr.count) {
                    
                    [weakSelf.orderTableView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                
                _pageNumber++;
                
                NSMutableArray *arrayModels = [NSMutableArray array];
                
                for (NSDictionary *tempDic in netDataArr) {
                    ClientOrderInfoModel *model = [[ClientOrderInfoModel alloc] initWithDictionary:tempDic error:nil];
                    
                    [arrayModels addObject:model];
                }
                
                [weakSelf.orderDataArr addObjectsFromArray:arrayModels];
                [weakSelf.orderTableView reloadData];
                
            }else if(state.intValue == 1){
                
                [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[responseObject objectForKey:@"msg"] hideDelay:1];
                
            }else if(state.intValue == 2){
                
            }
            
        }
        
        else {
            
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.orderTableView.mj_footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[error localizedDescription] hideDelay:1];
        [weakSelf.orderTableView.mj_footer endRefreshing];
        
    }];
}




-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 30;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_orderDataArr.count==0) {
        
        return _firstModel? 1:0;
    }
    
    return self.orderDataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    ClientOrderInfoModel *model;
    if (self.orderDataArr.count == 0) {
        
        model = self.firstModel;
    }
    else {
        
        model = self.orderDataArr[indexPath.row];
    }

    SSOrderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SSOrderTableViewCell"];
    
    if (cell == nil) {
        
        cell = [[SSOrderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault    reuseIdentifier:@"SSOrderTableViewCell"];
    }
    
    if (indexPath.row %2 == 0) {

        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    }
    
    cell.orderTimeLabel.text = model.create_date;
    cell.orderMoneyLabel.text = model.money.stringValue;
    cell.orderSSMoneyLabel.text = model.integral.stringValue;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

@end




@implementation SSOrderTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.orderTimeLabel.text = @"";
    self.orderMoneyLabel.text = @"";
    self.orderSSMoneyLabel.text = @"";
    self.contentView.backgroundColor = [UIColor whiteColor];
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.orderTimeLabel.text = @"";
    self.orderMoneyLabel.text = @"";
    self.orderSSMoneyLabel.text = @"";
    self.contentView.backgroundColor = [UIColor whiteColor];

}

@end


