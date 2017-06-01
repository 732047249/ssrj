//
//  MFDAfterSalesOrderDetailViewController.m
//  ssrj
//
//  Created by YiDarren on 16/12/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDAfterSalesOrderDetailViewController.h"
#import "LocalDefine.h"
#import "EMIMHelper.h"
#import "ChatViewController.h"


@interface MFDAfterSalesOrderDetailViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

//申请服务
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
//更换尺码
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
//申请原因
@property (weak, nonatomic) IBOutlet UILabel *seasonLabel;
//上门取货时间
@property (weak, nonatomic) IBOutlet UILabel *timeLabel; 
//订单状态
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;


//====上门取货收货地址
//姓名
@property (weak, nonatomic) IBOutlet UILabel *userDoorNameLabel;
//电话
@property (weak, nonatomic) IBOutlet UILabel *userDoorPhoneLabel;
//取货地址
@property (weak, nonatomic) IBOutlet UILabel *userDoorDestinationLabel;


//====换货商品取货地址
//姓名
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
//电话
@property (weak, nonatomic) IBOutlet UILabel *userPhoneLabel;
//取货地址
@property (weak, nonatomic) IBOutlet UILabel *userDestinationLabel;



//====商品信息
//图片
@property (weak, nonatomic) IBOutlet UIImageView *goodsImageView;
//名称
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
//英文名
@property (weak, nonatomic) IBOutlet UILabel *goodsBrandNameLabel;
//尺码
@property (weak, nonatomic) IBOutlet UILabel *goodsSizeLabel;
//颜色图片
@property (weak, nonatomic) IBOutlet UIImageView *goodsColorImageView;
//当前价格
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
//之前价格
@property (weak, nonatomic) IBOutlet UILabel *prePriceLabel;

//在线客服
@property (weak, nonatomic) IBOutlet UIButton *onLineServerButton;


@property (strong, nonatomic) NSMutableArray *dataArr;
//用于给客服UI传值
@property (strong, nonatomic) AfterSalesOrderModel *model;

@end

@implementation MFDAfterSalesOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addBackButton];
    
    self.title = @"售后换货订单详情";
    
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
        self.sizeLabel.text = model.size?:@"";
        self.seasonLabel.text = model.reason?:@"";
        self.timeLabel.text = model.time?:@"";
        self.statusLabel.text = model.status?:@"";
        self.userDoorNameLabel.text = model.userDoorName?:@"";
        self.userDoorPhoneLabel.text = model.userDoorPhone?:@"";
        self.userDoorDestinationLabel.text = model.userDoorDestination?:@"";
        self.userNameLabel.text = model.userName?:@"";
        self.userPhoneLabel.text = model.userPhone?:@"";
        self.userDestinationLabel.text = model.userDestination?:@"";
        [self.goodsImageView sd_setImageWithURL:[NSURL URLWithString:model.goodsImage?:@""] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
        self.goodsNameLabel.text = model.goodsName?:@"";
        self.goodsBrandNameLabel.text = model.brandName?:@"";
        self.goodsSizeLabel.text = model.goodsSize?:@"";
        [self.goodsColorImageView sd_setImageWithURL:[NSURL URLWithString:model.goodsImage?:@""] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
        self.currentPriceLabel.text = model.currentPrice;
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
                
                weakSelf.model = model;
                
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
    
    [MobClick beginLogPageView:@"我的订单售后换货页面"];
    [TalkingData trackPageBegin:@"我的订单售后换货页面"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"我的订单售后换货页面"];
    [TalkingData trackPageEnd:@"我的订单售后换货页面"];
    
}

- (void)onLineServerButtonClicked {
    
    [HTUIHelper addHUDToView:self.view withString:@"跳往在线客服" hideDelay:1];
    [[EMIMHelper defaultHelper] loginEasemobSDK];
    NSString *cname = @"mfd2016ssrj";
    ChatViewController *chatViewController = [[ChatViewController alloc]initWithChatter:cname type:eSaleTypeNone];
    chatViewController.title = @"时尚客服";
    
    /**
     *       
     
     NSArray *items = self.model.orderItemList;
     if (items.count) {
     PayOrderDeatailItemModel *itemModel = [items firstObject];
     NSString *colseName =[NSString stringWithFormat:@"%@ 共%lu件商品",itemModel.name,(unsigned long)items.count]; ;
     NSString *price = [NSString stringWithFormat:@"¥%@",self.model.amount.stringValue];
     chatVC.commodityInfo = @{@"type":@"order", @"title":self.model.statusStr?:@"", @"order_title":[NSString stringWithFormat:@"订单号:%@",self.model.sn?:@"无"], @"imageName":@"mallImage1.png", @"desc":colseName, @"price":price, @"img_url":itemModel.product.image, @"item_url":@""};
     }
     */
    AfterSalesOrderModel *model = _model;
    
    NSString *colseName = [NSString stringWithFormat:@"%@ 共1件商品",model.goodsName?:@""];
    
    NSString *price = [NSString stringWithFormat:@"¥%@",model.currentPrice];
    
    chatViewController.commodityInfo = @{@"type":@"order", @"title":model.status?:@"申请退换货", @"order_title":[NSString stringWithFormat:@"申请原因:%@",model.reason]?:@"", @"imageName":model.goodsName?:@"", @"desc":colseName?:@"", @"price":price?:@"", @"img_url":model.goodsImage?:@"", @"item_url":@""};
    
    [self.navigationController pushViewController:chatViewController animated:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end






@implementation AfterSalesOrderModel

@end
