//
//  MFDWriteLogisticsViewController.m
//  ssrj
//
//  Created by YiDarren on 16/11/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "MFDWriteLogisticsViewController.h"
#import "LogisticsCompanyModel.h"
#import "ZHPickView.h"


@interface MFDWriteLogisticsViewController ()<UITextFieldDelegate, ZHPickViewDelegate,UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *firstViewBg;

@property (weak, nonatomic) IBOutlet UIView *secondViewBg;

@property (weak, nonatomic) IBOutlet UITextField *companyText;

@property (weak, nonatomic) IBOutlet UITextField *sheetIdText;

//用于取选择器的公司模型数组
@property (strong, nonatomic) NSMutableArray *companyModelArray;
//用于保存选择器的公司名称数组
@property (strong, nonatomic) NSMutableArray *companyPickerNameArray;

@property (strong, nonatomic) ZHPickView *pickerView;
//记录选择的物流公司的ID
@property (strong, nonatomic) NSNumber *companyID;


@end

@implementation MFDWriteLogisticsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    
    self.title = @"填写物流信息";
    _companyModelArray = @[].mutableCopy;
    _companyPickerNameArray = @[].mutableCopy;
    _companyID = [NSNumber numberWithInt:0];
    
    self.firstViewBg.layer.cornerRadius = 5;
    self.firstViewBg.layer.masksToBounds = YES;
    self.secondViewBg.layer.cornerRadius = 5;
    self.secondViewBg.layer.masksToBounds = YES;
    __weak __typeof(&*self)weakSelf = self;
    self.scrollView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
       
        [weakSelf getCompanyNameNetData];
        
    }];
    
    [self.scrollView.mj_header beginRefreshing];
    self.scrollView.delegate = self;
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];

}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
    [MobClick beginLogPageView:@"填写物流信息页面"];
    [TalkingData trackPageBegin:@"填写物流信息页面"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    self.navigationController.navigationBarHidden = YES;
    
    [MobClick endLogPageView:@"填写物流信息页面"];
    [TalkingData trackPageEnd:@"填写物流信息页面"];
    
    [_pickerView remove];
}


- (void)getCompanyNameNetData {

    //填写物流公司接口：
    //https://api.ssrj.com/api/v4/member/returns/logistics/{id}.jhtml?id=退换货单ID&token=xxx    GET请求
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/returns/logistics/%@.jhtml?id=%@",_goodsId, _goodsId];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                [weakSelf.companyModelArray removeAllObjects];
                
                NSArray *tempArray = [[responseObject objectForKey:@"data"] objectForKey:@"deliveryCorpList"];
                
                for (NSDictionary *dic in tempArray) {
                    
                    LogisticsCompanyModel *model = [[LogisticsCompanyModel alloc] initWithDictionary:dic error:nil];
                    
                    if (model) {
                        
                        [weakSelf.companyModelArray addObject:model];
                        [weakSelf.companyPickerNameArray addObject:model.name];
                    }
                }
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
            [weakSelf.scrollView.mj_header endRefreshing];
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
       
        [weakSelf.scrollView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.scrollView.mj_header endRefreshing];
    }];
    
}


#pragma mark --选择物流公司名称方法
- (IBAction)chooseCompanyButtonAction:(id)sender {
    
    [_pickerView remove];
    
    if ([_companyText isFirstResponder]) {
        
        [_companyText resignFirstResponder];
    }
    
    NSArray *companyNameArray = _companyPickerNameArray.copy;
    
    _pickerView = [[ZHPickView alloc] initPickviewWithArray:companyNameArray isHaveNavControler:NO];
    _pickerView.delegate = self;
    [_pickerView show];
    
}


#pragma mark --pickerDelegate
-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    _companyText.text = resultString;
    
    for (LogisticsCompanyModel *model in _companyModelArray) {
        
        if ([model.name isEqualToString:resultString]) {
            
            _companyID = model.id;
            
            if (_companyID.intValue == 5) {
                
                [_secondViewBg setHidden:YES];
            }
            else {
                
                [_secondViewBg setHidden:NO];
            }
            
        }
    }
    
    [_pickerView remove];
}

#pragma mark --提交物流信息button点击事件
- (IBAction)commitButtonAciton:(id)sender {
    
    //检测数据填写是否为空
    if (!_companyText.text.length) {
    
        [HTUIHelper addHUDToView:self.view withString:@"请选择快递公司" hideDelay:1];
        return;
    }
    if (!_sheetIdText.text.length) {
        
        [HTUIHelper addHUDToView:self.view withString:@"请填写快递单号" hideDelay:1];
        return;
    }
    
    //提交物流信息接口：
    //https://api.ssrj.com/api/v4/member/returns/fillLogistics/{id}.jhtml?id=退换货单ID&token=xxx&trackingNo=运单号&deliveryCorpId=物流公司ID    POST请求
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/returns/fillLogistics/%@.jhtml", _goodsId];
    
    requestInfo.URLString = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"id":_goodsId, @"trackingNo":_sheetIdText.text, @"deliveryCorpId":_companyID}];
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    if ([weakSelf.delegate respondsToSelector:@selector(reloadServiceOrderData)]) {
                    
                        [weakSelf.delegate reloadServiceOrderData];
                    }

                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    
                });
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];

    }];
    
    
}



#pragma mark --UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (_sheetIdText.text.length) {
        
        return YES;
    }
    else {
        
        [HTUIHelper addHUDToView:self.view withString:@"请填写快递单号" hideDelay:1];
        return NO;
    }
}

#pragma mark --touches事件
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    if ([_companyText isFirstResponder]) {
        [_companyText resignFirstResponder];
    }
    else if ([_sheetIdText isFirstResponder]) {
        [_sheetIdText resignFirstResponder];
    }
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if ([_companyText isFirstResponder]) {
        [_companyText resignFirstResponder];
    }
    else if ([_sheetIdText isFirstResponder]) {
        [_sheetIdText resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
