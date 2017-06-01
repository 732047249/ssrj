//
//  MFDAfterSalesReturnGoodsViewController.m
//  ssrj
//
//  Created by YiDarren on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDAfterSalesReturnGoodsViewController.h"
//取model用
#import "MFDAfterSalesOrderDetailViewController.h"
#import "LocalDefine.h"
#import "EMIMHelper.h"
#import "ChatViewController.h"

@interface MFDAfterSalesReturnGoodsViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDoorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDoorPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDoorDestinationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsSizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsColorImageView;
@property (weak, nonatomic) IBOutlet UILabel *currenPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *prePriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *onLineServerButton;
//用于给客服UI传值
@property (strong, nonatomic) AfterSalesOrderModel *model;


@end

@implementation MFDAfterSalesReturnGoodsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackButton];
    
    self.title = @"售后退货订单详情";
    self.goodsColorImageView.layer.cornerRadius = 8.0;
    self.goodsColorImageView.layer.masksToBounds = YES;
    
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, SCREEN_HEIGHT*0.3, 0);
    
    [self.onLineServerButton addTarget:self action:@selector(onLineServerButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    __weak __typeof(&*self)weakSelf = self;
    
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetData];
        
    }];
    
    [self.scrollView.mj_header beginRefreshing];
    
}

- (void)setAfterSalesUIDataWithModel:(AfterSalesOrderModel *)model {
    
    self.serverLabel.text = model.server?:@"";
    self.reasonLabel.text = model.reason?:@"";
    self.timeLabel.text = model.time?:@"";
    self.statusLabel.text = model.status?:@"";
    self.userDoorNameLabel.text = model.userDoorName?:@"";
    self.userDoorPhoneLabel.text = model.userDoorPhone?:@"";
    self.userDoorDestinationLabel.text = model.userDoorDestination?:@"";
    [self.goodsImageView sd_setImageWithURL:[NSURL URLWithString:model.goodsImage?:@""] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    self.goodsNameLabel.text = model.goodsName?:@"";
    self.goodsBrandLabel.text = model.brandName?:@"";
    self.goodsSizeLabel.text = model.goodsSize?:@"";
    [self.goodsColorImageView sd_setImageWithURL:[NSURL URLWithString:model.goodsColorImage?:@""] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    self.currenPriceLabel.text = model.currentPrice;
    self.prePriceLabel.text = model.prePrice;
}


- (void)getNetData {
    
    __weak typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"api/v5/member/customerService/view.jhtml?id=%@",_afterSalesId];

//    NSString *urlStr = [NSString stringWithFormat:@"http://192.168.1.29/api/v5/member/customerService/view.jhtml?id=%@",_afterSalesId];
    
    requestInfo.URLString = urlStr;
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                AfterSalesOrderModel *model = [[AfterSalesOrderModel alloc] initWithDictionary:responseObject[@"data"] error:nil];
                
                [weakSelf setAfterSalesUIDataWithModel:model];
                
                
            } else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        }
        else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.scrollView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.scrollView.mj_header endRefreshing];
        
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"我的订单售后退货页面"];
    [TalkingData trackPageBegin:@"我的订单售后退货页面"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的订单售后退货页面"];
    [TalkingData trackPageEnd:@"我的订单售后退货页面"];
    
}

- (void)onLineServerButtonClicked {
    
    [HTUIHelper addHUDToView:self.view withString:@"跳往在线客服" hideDelay:1];
    [[EMIMHelper defaultHelper] loginEasemobSDK];
    NSString *cname = @"mfd2016ssrj";
    ChatViewController *chatViewController = [[ChatViewController alloc]initWithChatter:cname type:eSaleTypeNone];
    chatViewController.title = @"时尚客服";
    
    AfterSalesOrderModel *model = _model;
    
    NSString *colseName = [NSString stringWithFormat:@"%@ 共1件商品",model.goodsName?:@""];
    
    NSString *price = [NSString stringWithFormat:@"¥%@",model.currentPrice];
    
    chatViewController.commodityInfo = @{@"type":@"order", @"title":model.status?:@"申请退换货", @"order_title":[NSString stringWithFormat:@"申请原因:%@",model.reason]?:@"", @"imageName":model.goodsName?:@"", @"desc":colseName?:@"", @"price":price?:@"", @"img_url":model.goodsImage?:@"", @"item_url":@""};
    
    [self.navigationController pushViewController:chatViewController animated:YES];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
