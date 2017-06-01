//
//  AskForTransPayWayViewController.m
//  ssrj
//
//  Created by YiDarren on 16/9/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AskForTransPayWayViewController.h"
#import "AskForTransSMSViewController.h"

@interface AskForTransPayWayViewController ()<UITextFieldDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//最多可提现金额
@property (weak, nonatomic) IBOutlet UILabel *topAmountLabel;
//可提现积分
@property (weak, nonatomic) IBOutlet UILabel *totalIntegral;
@property (weak, nonatomic) IBOutlet UITextField *moneyToGet;
@property (weak, nonatomic) IBOutlet UIButton *aliPay;
@property (weak, nonatomic) IBOutlet UIButton *wechatPay;
@property (weak, nonatomic) IBOutlet UIView *transToCashBg;
@property (weak, nonatomic) IBOutlet UIView *accountIDBg;
@property (weak, nonatomic) IBOutlet UIView *accountNameBg;
@property (weak, nonatomic) IBOutlet UITextField *accountID;
@property (weak, nonatomic) IBOutlet UITextField *accountName;
@property (weak, nonatomic) IBOutlet UIButton *commit;
@property (weak, nonatomic) IBOutlet UIView *wechatBg;
@property (weak, nonatomic) IBOutlet UITextField *wechatNameText;
//记录支付方式
@property (assign, nonatomic) int payType;
//微信openID
@property (strong, nonatomic) NSString *wxOpenID;

@property (strong, nonatomic) id keyboardShowObserver;
@property (strong, nonatomic) id keyboardHideObserver;

@end

@implementation AskForTransPayWayViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    UIScrollView *sv = self.scrollView;
    self.scrollView.delegate = self;
    
    self.keyboardShowObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillShowNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        CGRect keyboardFrame = [[[note userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardHeight = keyboardFrame.size.height;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo [UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[note.userInfo [UIKeyboardAnimationCurveUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        sv.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        [UIView commitAnimations];
        
    }];
    
    self.keyboardHideObserver = [[NSNotificationCenter defaultCenter] addObserverForName:UIKeyboardWillHideNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:[note.userInfo [UIKeyboardAnimationDurationUserInfoKey] integerValue]];
        [UIView setAnimationBeginsFromCurrentState:YES];
        sv.contentInset = UIEdgeInsetsZero;
        [UIView commitAnimations];
    }];
    
    [MobClick beginLogPageView:@"申请提现页面"];
    [TalkingData trackPageBegin:@"申请提现页面"];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardShowObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self.keyboardHideObserver];
    
    self.keyboardHideObserver = nil;
    self.keyboardShowObserver = nil;
    
    [MobClick endLogPageView:@"申请提现页面"];
    [TalkingData trackPageEnd:@"申请提现页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addBackButton];
    self.title = @"申请提现";
    
    RJAccountModel *account = [RJAccountManager sharedInstance].account;
    if (!account.wxopenid) {
        
        _wechatBg.hidden = YES;
//        _wechatPay.enabled = NO;
        _wechatPay.imageView.image = [UIImage imageNamed:@"close"];
        _aliPay.selected = YES;
        _payType = 1;
        _wechatPay.selected = NO;
    }
    else {
        _wxOpenID = account.wxopenid;
        _wechatBg.hidden = NO;
    }
    
//#warning test
//
//    self.totalPoints = @"3450000";
//    self.topAmount = @"345";
//    self.maxAmount = @"300";
    
    self.totalIntegral.text = self.totalPoints;
    self.topAmountLabel.text = self.topAmount;
    
    _commit.layer.cornerRadius = 20;
    _commit.layer.masksToBounds = YES;
    [_commit addTarget:self action:@selector(commitButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _aliPay.selected = YES;
    _payType = 1;
    _wechatPay.selected = NO;
    _wechatBg.hidden = YES;

    [_aliPay addTarget:self action:@selector(aliPayButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [_wechatPay addTarget:self action:@selector(wechatPayButtonAction) forControlEvents:UIControlEventTouchUpInside];
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}




- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //支付账户
    if (textField.tag == 100) {
        
        if (!textField.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入支付宝账号" hideDelay:1];
            return NO;
        }
        
        [_accountName becomeFirstResponder];
    }
    //用户真实姓名
    else if (textField.tag == 101) {
        
        if (!textField.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入真实姓名" hideDelay:1];
            return NO;
            
        }
        [_accountName resignFirstResponder];
    }
    else if (textField.tag == 102) {
        
        if (textField.text.intValue > self.maxAmount.intValue) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入正确金额" hideDelay:1];
            return NO;
        }
        
        [_moneyToGet resignFirstResponder];
    }
    
    else if (textField.tag == 103) {
        
        if (!textField.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入真实姓名" hideDelay:1];
            return NO;
        }
        [_wechatNameText resignFirstResponder];
    }
    return YES;
}

#pragma mark -- 全部提现
- (IBAction)getAllMoneyButtonAction:(id)sender {
    
    if (!_moneyToGet.text.length) {
        self.moneyToGet.text = self.maxAmount;
    }
    else if (_moneyToGet.text.intValue > self.maxAmount.intValue) {
        
        _moneyToGet.text = self.maxAmount;
        
        [HTUIHelper addHUDToView:self.view withString:[NSString stringWithFormat:@"最多提现%@",self.maxAmount] hideDelay:1];
    }
    else if (_moneyToGet.text.intValue <= self.maxAmount.intValue) {
        
        if (self.maxAmount>0) {
            
            _moneyToGet.text = self.maxAmount;
        }
        else if (self.maxAmount == 0) {
            
            [HTUIHelper addHUDToView:self.view withString:@"时尚币不足，暂不可提现" hideDelay:1];
        }
    }
    
}


#pragma mark --下一步按钮点击
- (void)commitButtonClicked {
    
    if (!_moneyToGet.text.length) {
        
        [HTUIHelper addHUDToView:self.view withString:@"请输入提现金额" hideDelay:1];
        return;
    }
    
    if (_moneyToGet.text.length) {
        
        int money = _moneyToGet.text.intValue;
        if (money >= 100 && money <= _maxAmount.intValue) {
            
            if (money%100) {
                
                [HTUIHelper addHUDToView:self.view withString:@"提现须为整百" hideDelay:1];
                
                money = money/100 *100;
                _moneyToGet.text = [NSString stringWithFormat:@"%d", money];
                
                return;
            }
            
            
        }else if (money < 100) {
            
            [HTUIHelper addHUDToView:self.view withString:@"提现金额须为整百哦" hideDelay:1];
            _moneyToGet.text = @"";
            
            return;
        }else if (money > _maxAmount.intValue) {
            
            [HTUIHelper addHUDToView:self.view withString:[NSString stringWithFormat:@"最多提现%@",_maxAmount] hideDelay:1];
            _moneyToGet.text = _maxAmount;
            
            return;
        }else if (money == 0) {
            
            [HTUIHelper addHUDToView:self.view withString:@"时尚币不足，暂不可提现" hideDelay:1];
        }
        
    }

//    if (_payType == 0) {
//        
//        if (!_wechatNameText.text.length) {
//            
//            [HTUIHelper addHUDToView:self.view withString:@"请输入真实姓名" hideDelay:1];
//            return;
//        }
//    }

    if (_payType == 1) {
        
        if (!_accountName.text.length || !_accountID.text.length) {
            
            [HTUIHelper addHUDToView:self.view withString:@"请输入账号信息" hideDelay:1];
            return;
        }
    }
    
    ///b82/api/v5/user/addcase?account=收款账号&convertAmount=兑换金额&convertPonint=兑换积分&type=支付类型（0 微信，1支付宝）&mobile=手机号&realName=姓名&token=da83e19a50a084522343d96746f0d889&appVersion=2.0
    
    NSString *str = @"/b82/api/v5/user/addcase";
    
    NSDictionary *wechatParaDic = @{@"account":_wxOpenID?:@"", @"convertAmount":_moneyToGet.text, @"convertPonint":[NSNumber numberWithInt:[_moneyToGet.text intValue]*100], @"type":[NSNumber numberWithInt:_payType]};

    NSDictionary *aliyParaDic = @{@"account":_accountID.text, @"convertAmount":_moneyToGet.text, @"convertPonint":[NSNumber numberWithInt:[_moneyToGet.text intValue]*100], @"type":[NSNumber numberWithInt:_payType], @"realName":_accountName.text};
    
    str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    AskForTransSMSViewController *askTransSMSVC = [story instantiateViewControllerWithIdentifier:@"AskForTransSMSViewController"];
    askTransSMSVC.urlString = str;
    
    RJAccountModel *account = [RJAccountManager sharedInstance].account;
    
    if (account.mobile.length) {
        
        askTransSMSVC.isTelephoneRegistered = YES;
    }
    else if (account.email.length && !account.mobile.length) {
        
        askTransSMSVC.isTelephoneRegistered = NO;
    }

    //微信提现
    if (_payType == 0) {
        
        askTransSMSVC.paramDictionary = wechatParaDic.mutableCopy;
    }
    //支付宝提现
    else if (_payType == 1) {

        askTransSMSVC.paramDictionary = aliyParaDic.mutableCopy;
    }
    
    [self.navigationController pushViewController:askTransSMSVC animated:YES];
}



- (void)aliPayButtonAction{

    _aliPay.selected = YES;
    _wechatPay.selected = NO;
    _wechatBg.hidden = YES;
    _payType = 1;
}

- (void)wechatPayButtonAction{

    RJAccountModel *model = [RJAccountManager sharedInstance].account;
    
    if (!model.wxopenid.length) {
        
        [HTUIHelper addHUDToView:self.view withString:@"未绑定微信，请绑定微信..." hideDelay:1];
    }
    else {
        
        _wechatPay.selected = YES;
        _aliPay.selected = NO;
        _wechatBg.hidden = NO;
        _payType = 0;
    }
    
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    if ([_moneyToGet isFirstResponder]) {
        [_moneyToGet resignFirstResponder];
    }
    if ([_accountID isFirstResponder]) {
        [_accountID resignFirstResponder];
    }
    if ([_accountName isFirstResponder]) {
        [_accountName resignFirstResponder];
    }
    if ([_wechatNameText isFirstResponder]) {
        [_wechatNameText resignFirstResponder];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if ([_moneyToGet isFirstResponder]) {
        [_moneyToGet resignFirstResponder];
    }
    if ([_accountID isFirstResponder]) {
        [_accountID resignFirstResponder];
    }
    if ([_accountName isFirstResponder]) {
        [_accountName resignFirstResponder];
    }
    if ([_wechatNameText isFirstResponder]) {
        [_wechatNameText resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
