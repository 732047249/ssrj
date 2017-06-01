//
//  ServerAfterSaleViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/28.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ServerAfterSaleViewController.h"
#import "ZHPickView.h"

#import "DestinationManageViewController.h"
//申请售后服务条目模型
#import "ApplyReturnModel.h"


@interface ServerAfterSaleViewController ()<UITextFieldDelegate,ZHPickViewDelegate, DestinationManageViewControllerDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) id keyboardShowObserver;
@property (strong, nonatomic) id keyboardHideObserver;


@property (weak, nonatomic) IBOutlet UIView *serverBg;
@property (weak, nonatomic) IBOutlet UIView *reasonBg;
@property (weak, nonatomic) IBOutlet UIView *sizeBg;
@property (weak, nonatomic) IBOutlet UIView *getGoodsBg;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *serverImageView;
//服务类型
@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
//服务原因
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
//更换尺码
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
//选择时间
@property (weak, nonatomic) IBOutlet UILabel *chooseTimeLabel;


//换货收货地址label
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userPhoneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *userDestinationLabel;

//上门取货地址label
@property (weak, nonatomic) IBOutlet UILabel *userHomeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userHomePhoneNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *userHomeDestinationLabel;

//判断取货地址类型（上门取货或者默认下单地址）
@property (assign, nonatomic) BOOL isFirstDestination;


//换货收货地址model
@property (strong, nonatomic) RJAddressModel *exchangeGoodsDestiModel;
//上门取货地址model
@property (strong, nonatomic) RJAddressModel *doorDestiModel;




//申请服务button
@property (weak, nonatomic) IBOutlet UIButton *chooseServerButton;
//申请原因button
@property (weak, nonatomic) IBOutlet UIButton *whyChooseServerButton;
//申请尺码button
@property (weak, nonatomic) IBOutlet UIButton *sizeChooseServerButton;
//上门取货时间
@property (weak, nonatomic) IBOutlet UIButton *returnGoodsTimeButton;




@property (weak, nonatomic) IBOutlet UIImageView *resonImageView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *getGoodsTimeConstraint;

//申请售后说明
@property (weak, nonatomic) IBOutlet UITextField *describeTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *describeTextTopconstraint;



//提交
@property (weak, nonatomic) IBOutlet UIButton *commitButton;
@property (strong, nonatomic) ZHPickView *pickerView;


//尺寸
@property (strong, nonatomic) NSArray *sizeArray;
//尺寸model
@property (strong, nonatomic) NSMutableArray *sizeModelArray;
//上门取货时间 add 11.15
@property (strong, nonatomic) NSArray *timeArray;

//申请服务ID
@property (strong, nonatomic) NSString *serverID;
//申请原因ID
@property (strong, nonatomic) NSString *reasonID;

//换货商品id
@property (strong, nonatomic) NSNumber *exchangeProductId;

//add 12.2
//申请售后服务条目模型数组
@property (strong, nonatomic) NSMutableArray *applyServiceArray;
//用于选择器的申请服务类型数组
@property (strong, nonatomic) NSMutableArray *serverArray;
//用于选择器的申请原因数组
@property (strong, nonatomic) NSMutableArray *reasonArray;
//记录选中的服务类型model
@property (strong, nonatomic) ApplyReturnModel *pickedReturnModel;

@end

@implementation ServerAfterSaleViewController


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    UIScrollView *sv = self.scrollView;

    self.keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        
        CGRect keyBoardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        CGFloat keyboardHeight = keyBoardFrame.size.height;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        //界面拉长键盘弹出高度改变
        sv.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight +40, 0);
        [UIView commitAnimations];
    }];
    
    self.keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        sv.contentInset = UIEdgeInsetsZero;
        
        [UIView commitAnimations];
    }];
    
    [MobClick beginLogPageView:@"申请售后页面"];
    [TalkingData trackPageBegin:@"申请售后页面"];
    


}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardHideObserver];
    self.keyboardShowObserver = nil;
    self.keyboardHideObserver = nil;
    
    [_pickerView remove];
    
    [MobClick endLogPageView:@"申请售后页面"];
    [TalkingData trackPageEnd:@"申请售后页面"];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"申请售后";
    
    _reasonID = @"";
    _serverID = @"";
    
    __weak typeof(&*self)weakSelf = self;
    _serverBg.layer.cornerRadius = 5.0;
    _serverBg.layer.masksToBounds = YES;
    _reasonBg.layer.cornerRadius = 5.0;
    _reasonBg.layer.masksToBounds = YES;
    _sizeBg.layer.cornerRadius = 5.0;
    _sizeBg.layer.masksToBounds = YES;
    _getGoodsBg.layer.cornerRadius = 5.0;
    _getGoodsBg.layer.masksToBounds = YES;

    _getGoodsTimeConstraint.constant = 0;
    _describeTextTopconstraint.constant = 0;
    
    _serverLabel.text = @"请选择申请服务";
    _reasonLabel.text = @"请选择申请原因";
    
    //地址信息label高度属性
    _userDestinationLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 60;
    _userHomeDestinationLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 60;
    
    _isFirstDestination = YES;
    
    
    [_commitButton addTarget:self action:@selector(commitButtonClickedAction) forControlEvents:UIControlEventTouchUpInside];
    
//    _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 120, 0);
//    if (DEVICE_IS_IPHONE5) {
//        
//        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 230, 0);
//    }
//    if (DEVICE_IS_IPHONE4) {
//        
//        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, 280, 0);
//    }
    
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        //获取尺码数据请求
        //从后台获取退换货文案
        [weakSelf getApplyModelData];
        [weakSelf getSizeDataFromNet];
        [weakSelf getGoodsTimeDataFromNet];
        
    }];
    
    [weakSelf.scrollView.mj_header beginRefreshing];
    //设置用户下单地址数据
    [self setDestinationData];
    
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


#pragma mark -- 地址选择VC代理刷新本UI的地址信息
-(void)reloadDestinationDataWithDestinationModel:(DestinationModel *)model {
    //快递上门取货地址
    if (_isFirstDestination) {
        
        _doorDestiModel = (RJAddressModel *)model;
        _userHomeNameLabel.text = model.consignee;
        _userHomePhoneNumLabel.text = model.phone;
        _userHomeDestinationLabel.text = model.fullName;

    }
    //换货商品收货地址
    else {
        
        _exchangeGoodsDestiModel = (RJAddressModel *)model;
        _userNameLabel.text = model.consignee;
        _userPhoneNumLabel.text = model.phone;
        _userDestinationLabel.text = model.fullName;
    }
    
}

#pragma mark --获取退换货文案模型数据
- (void)getApplyModelData {
    
    __weak __typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v2/user/findcustomer";
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *array = [responseObject objectForKey:@"data"];
                NSMutableArray *temServiceArray = [NSMutableArray array];
                NSMutableArray *temServerArray = [NSMutableArray array];
                
                for (NSDictionary *dic in array) {
                    
                    ApplyReturnModel *model = [[ApplyReturnModel alloc]initWithDictionary:dic error:nil];
                    
                    if (model) {
                        
                        [temServiceArray addObject:model];
                        [temServerArray addObject:model.name];
                    }
                }
                
                _applyServiceArray = temServiceArray.mutableCopy;
                _serverArray = temServerArray.mutableCopy;
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
        [weakSelf.scrollView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [weakSelf.scrollView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];
}


#pragma mark -- 获取尺码数据请求
- (void)getSizeDataFromNet {
    
    __weak typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //https://api.ssrj.com/api/v4/member/returns/getSpecification.jhtml?token=xxx&productId=商品ID   GET请求
    
    requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/returns/getSpecification.jhtml?productId=%@",_productid];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }

    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *state =  [responseObject objectForKey:@"state"];
        
        if ([responseObject objectForKey:@"state"]) {
        
            if (state.intValue == 0) {
                
                //获取需要退换货的订单商品的尺码信息
                
                //test 11.15
                NSMutableArray *tempArray = [NSMutableArray array];
                NSMutableArray *sizeMArray = [NSMutableArray array];
                
                
                NSArray *array = [responseObject objectForKey:@"data"];
                
                [_sizeModelArray removeAllObjects];
                
                for (NSDictionary *dic in array) {
                    
                    GoodsInSizeModel *model = [[GoodsInSizeModel alloc] initWithDictionary:dic error:nil];
                    
                    [tempArray addObject:model];
                    [sizeMArray addObject:model.specification];
                    
                }
                _sizeModelArray = tempArray.mutableCopy;
                _sizeArray = sizeMArray.copy;
                
                }
            else if (state.intValue == 1){
                
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

#pragma mark -- 获取网络取货时间接口：
- (void)getGoodsTimeDataFromNet {
    
    __weak typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"/api/v5/member/returns/getClaimGoodsTime.jhtml";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *state =  [responseObject objectForKey:@"state"];
        
        if ([responseObject objectForKey:@"state"]) {
            
            if (state.intValue == 0) {
                
                weakSelf.timeArray = @[];
                weakSelf.timeArray = [responseObject objectForKey:@"data"];
                
            }
            else if (state.intValue == 1){
                
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


#pragma mark -- 设置用户下单地址数据
- (void)setDestinationData{
    
    //换货地址及上门取货地址原始值为传值过来的下单地址
    _exchangeGoodsDestiModel = _addressModel;
    _doorDestiModel = _addressModel;
    
    _userNameLabel.text = _addressModel.consignee;
    _userPhoneNumLabel.text = _addressModel.phone;
    _userDestinationLabel.text = _addressModel.fullName;
    
    _userHomeNameLabel.text = _addressModel.consignee;
    _userHomePhoneNumLabel.text = _addressModel.phone;
    _userHomeDestinationLabel.text = _addressModel.fullName;
    
}


#pragma mark --选择服务
- (IBAction)chooseServerButtonAction:(id)sender {
    
    [_pickerView remove];
    
    //防止键盘挡住pickerView
    if ([_describeTextView isFirstResponder]) {
        [_describeTextView resignFirstResponder];
    }
    
    _describeTextTopconstraint.constant = 0;
    
    NSArray *serverArray = _serverArray.mutableCopy;
    
    _pickerView = [[ZHPickView alloc] initPickviewWithArray:serverArray isHaveNavControler:NO];
    _pickerView.delegate = self;
    _pickerView.tag = 100;
    [_pickerView show];
    
    
    _serverLabel.text = @"";
    _reasonLabel.text = @"";
    _sizeLabel.text = @"";
    
}

#pragma mark --选择原因
- (IBAction)chooseResonButtonAction:(id)sender {
    
    [_pickerView remove];
    
    //防止键盘挡住pickerView
    if ([_describeTextView isFirstResponder]) {
        
        [_describeTextView resignFirstResponder];
    }
    
    if (!_serverLabel.text.length) {
        
        [HTUIHelper addHUDToView:self.view withString:@"请选择服务类型" hideDelay:2];
    }
    
    else {
        
        //选择申请服务类型时已将申请原因数组_reasonArray取好值
        _pickerView = [[ZHPickView alloc] initPickviewWithArray:_reasonArray isHaveNavControler:NO];
        _pickerView.delegate = self;
        _pickerView.tag = 101;
        [_pickerView show];
        
    }
    
}

#pragma mark --选择尺码
- (IBAction)chooseSizeButtonAction:(id)sender {
    
    [_pickerView remove];
    
    //防止键盘挡住pickerView
    if ([_describeTextView isFirstResponder]) {
        
        [_describeTextView resignFirstResponder];
    }
    
    NSArray * sizeArray = [_sizeArray copy];
    
    _pickerView = [[ZHPickView alloc] initPickviewWithArray:sizeArray isHaveNavControler:NO];
    _pickerView.delegate = self;
    _pickerView.tag = 104;
    [_pickerView show];
    
}

#pragma mark -- 选择上门时间
- (IBAction)chooseTimeToGetAction:(id)sender {
    
    [_pickerView remove];
    
    //防止键盘挡住pickerView
    if ([_describeTextView isFirstResponder]) {
        
        [_describeTextView resignFirstResponder];
    }
    
    [self getGoodsTimeDataFromNet];
    
    _pickerView = [[ZHPickView alloc] initPickviewWithArray:_timeArray isHaveNavControler:NO];
    _pickerView.delegate = self;
    _pickerView.tag = 105;
    [_pickerView show];
    
}


#pragma mark -- 选择地址
- (IBAction)chooseDestinationButtonAction:(UIButton *)sender {
    //快递上门取货地址
    if (sender.tag == 200) {
        
        _isFirstDestination = YES;
    }
    //换货商品收货地址
    else if (sender.tag == 201) {
        
        _isFirstDestination = NO;
    }
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    DestinationManageViewController *destinationVC = [story instantiateViewControllerWithIdentifier:@"DestinationManageViewController"];
    destinationVC.destinationDelegate = self;
    [self.navigationController pushViewController:destinationVC animated:YES];
    
}

#pragma mark ZhpickVIewDelegate

-(void)toobarDonBtnHaveClick:(ZHPickView *)pickView resultString:(NSString *)resultString{
    
    //选择服务类型
    if (_pickerView.tag == 100) {
        _serverLabel.text = resultString;
        

        // add 12.2
        for (ApplyReturnModel *model in _applyServiceArray) {
            
            if ([resultString isEqualToString:model.name]) {
                
                _pickedReturnModel = model;
                
                _serverID = model.serviceId.stringValue;
                
                NSMutableArray *temReasonArray = [NSMutableArray array];
                
                for (ApplyReasonModel *reasonModel in model.child) {
                    
                    if (reasonModel) {
                        
                        [temReasonArray addObject:reasonModel.name];
                    }
                }
                _reasonArray = temReasonArray.mutableCopy;
                
                //换货
                if ([_serverID isEqualToString:@"3"]) {
                    
                    [UIView animateWithDuration:1 animations:^{
                        
                        //更换尺码框显示
                        _sizeBg.hidden = NO;
                        _getGoodsTimeConstraint.constant = 52;
                        _describeTextTopconstraint.constant = 118;
                        
                    }];
                }
                else {
                    
                    //隐藏更换尺码框
                    [UIView animateWithDuration:1 animations:^{
                        
                        //更换尺码框显示
                        _sizeBg.hidden = YES;
                        _getGoodsTimeConstraint.constant = 0;
                        _describeTextTopconstraint.constant = 0;
                    }];
                }
            }
        }
    }
    
    
    
    //服务原因选择
    if (_pickerView.tag == 101) {
        _reasonLabel.text = resultString;
        
        
        for (ApplyReasonModel *model in _pickedReturnModel.child) {
            
            if ([resultString isEqualToString:model.name]) {
                
                _reasonID = model.reasonId.stringValue;
            }
        }
    }
    
    //尺码选择
    if (_pickerView.tag == 104) {
        
        _sizeLabel.text = resultString;
        
        for (GoodsInSizeModel *model in _sizeModelArray) {
            
            if ([model.specification isEqualToString:resultString]) {
                
                _exchangeProductId = model.productId;
            }
        }
    }
    
    if (_serverLabel.text.length) {
        _chooseServerButton.titleLabel.text = @"";
    }
    if (_reasonLabel.text.length) {
        _whyChooseServerButton.titleLabel.text = @"";
    }
    if (_sizeLabel.text.length) {
        _sizeChooseServerButton.titleLabel.text = @"";
    }
    
    
    //TODO:上门时间选择
    if (_pickerView.tag == 105) {
        
        _chooseTimeLabel.text = resultString;
    }
    
    
    [_pickerView remove];
}

#pragma mark --提交申请退换货button点击事件
- (void)commitButtonClickedAction {
    
    if ([_describeTextView isFirstResponder]) {
        
        [_describeTextView resignFirstResponder];
    }
    
    //https://api.ssrj.com/api/v4/member/returns/doReturnsApply.jhtml
    //returnsReasonId=退换货原因ID&token=&orderSn=订单编号&areaId=收货地区&orderItemId=订单明细编号&quantity=退换货数量&returnsType=退换货类型&memo=备注&address=收货地址&shipper=收货人名称&phone=收货人电话&claimGoodsTime=上门取货时间    POST请求
    
    
    //判断申请原因对第二个地址信息全置零
    //_serverID = 1,退货
    if ([_serverID isEqualToString:@"1"]) {
        
        if (!_serverLabel.text.length || !_reasonLabel.text.length|| !_chooseTimeLabel.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"信息填写不完全..." hideDelay:1];
            
            return;
        }
        
    }
    //_serverID = 3,换货
    else if ([_serverID isEqualToString:@"3"]) {
        
        if (!_serverLabel.text.length || !_reasonLabel.text.length || !_sizeLabel.text.length || !_chooseTimeLabel.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"信息填写不完全..." hideDelay:1];
            
            return;
        }

    }
    
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    //returnsReasonId=退换货原因ID&token=&orderSn=订单编号&areaId=收货地区&orderItemId=订单明细编号&quantity=退换货数量&returnsType=退换货类型&memo=备注&exchengSpecs=规格&exchengProductId=换货商品ID&address=收货地址&shipper=收货人名称&phone=收货人电话&claimGoodsTime=上门取货时间&claimGoodsAreaId=取货地区&claimGoodsAddress=取货地址&claimGoodsShipper=名称&claimGoodsPhone=电话    POST请求
    
    
    NSString *urlStr = [NSString stringWithFormat:@"/api/v5/member/returns/doApply.jhtml"];


    
    if (!_exchangeProductId) {
        _exchangeProductId = @"";
    }
    if (!_sizeLabel.text.length) {
        _sizeLabel.text = @"";
    }

    
    //_serverID = 1,退货
    if ([_serverID isEqualToString:@"1"]) {
        
        urlStr = @"/api/v5/member/returns/doReturnsApply.jhtml";
        
        //https://api.ssrj.com/api/v4/member/returns/doReturnsApply.jhtml
        //returnsReasonId=退换货原因ID&token=&orderSn=订单编号&orderItemId=订单明细编号&quantity=退换货数量&returnsType=退换货类型&memo=备注&claimGoodsTime=上门取货时间&claimGoodsAreaId=取货地区&claimGoodsAddress=取货地址&claimGoodsShipper=名称&claimGoodsPhone=电话    POST请求
        [requestInfo.postParams addEntriesFromDictionary:@{
                                                           @"returnsReasonId":_reasonID,
                                                           @"orderSn":_orderSn,
                                                           @"orderItemId":_orderItemId,
                                                           @"quantity":_toReturnQuantity,
                                                           @"returnsType":_serverID,
                                                           @"memo":_describeTextView.text,
                                                           @"claimGoodsTime":_chooseTimeLabel.text,
                                                           @"claimGoodsAreaId":_doorDestiModel.areaId,
                                                           @"claimGoodsAddress":_doorDestiModel.fullName,
                                                           @"claimGoodsShipper":_doorDestiModel.consignee,
                                                           @"claimGoodsPhone":_doorDestiModel.phone
                                                           }];
    }
    //_serverID = 3,换货
    else if ([_serverID isEqualToString:@"3"]) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{
                                                           @"returnsReasonId":_reasonID,
                                                           @"orderSn":_orderSn,
                                                           @"areaId":_addressModel.areaId,
                                                           @"orderItemId":_orderItemId,
                                                           @"quantity":_toReturnQuantity,
                                                           @"returnsType":_serverID,
                                                           @"memo":_describeTextView.text,
                                                           @"exchengSpecs":_sizeLabel.text,
                                                           @"exchengProductId":_exchangeProductId,//为空
                                                           @"address":_exchangeGoodsDestiModel.fullName,
                                                           @"shipper":_exchangeGoodsDestiModel.consignee,
                                                           @"phone":_exchangeGoodsDestiModel.phone,
                                                           @"claimGoodsTime":_chooseTimeLabel.text,
                                                           @"claimGoodsAreaId":_doorDestiModel.areaId,
                                                           @"claimGoodsAddress":_doorDestiModel.fullName,
                                                           @"claimGoodsShipper":_doorDestiModel.consignee,
                                                           @"claimGoodsPhone":_doorDestiModel.phone
                                                           }];
    }
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    //token
    
    if ([RJAccountManager sharedInstance].account.token) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:@"提交中..." xOffset:0 yOffset:0];
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            [[HTUIHelper shareInstance] removeHUD];
                NSNumber *state = [responseObject objectForKey:@"state"];
                
                if (state.intValue == 0) {
                    
                    [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];

                    #pragma mark --代理刷新订单详情
                    if ([self.serverDelegate respondsToSelector:@selector(reloadPayOrderDetailData)]) {
                        
                        [self.serverDelegate reloadPayOrderDetailData];
                        
                    }
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                        [self.navigationController popViewControllerAnimated:YES];

                    });

                }
                else if (state.intValue == 1){
                    
                    [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                }
                
        }
        
        else {
            
            [[HTUIHelper shareInstance] removeHUDWithEndString:@"" image:nil];

            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [[HTUIHelper shareInstance] removeHUDWithEndString:[error localizedDescription] image:nil];
        
    }];

}


//手机号码验证
- (BOOL)validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}



#pragma mark --UITextFieldDelegate
-(void)textFieldDidEndEditing:(UITextField *)textField{
    
}


#pragma mark --touches begin
-(void)keyboardHide:(UITapGestureRecognizer*)tap{

    if ([_describeTextView isFirstResponder]) {
        [_describeTextView resignFirstResponder];
    }
    

    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([_describeTextView isFirstResponder]) {
        [_describeTextView resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end








@implementation GoodsInSizeModel


@end







