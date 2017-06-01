//
//  AddDestinationTableViewController.m
//  ssrj
//
//  Created by app on 16/6/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AddDestinationTableViewController.h"
#import "CCCityPickerView.h"

@interface AddDestinationTableViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate, CCCityPickerViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *zipTextField;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet RJTextView *addressTextView;
@property (strong, nonatomic) CCCityPickerView * pickerView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImage;
@property (strong, nonatomic) NSMutableArray * textFieldArray;
@property (assign, nonatomic) BOOL  addressSelect;
@property (assign, nonatomic) BOOL  isDefault;
@property (strong, nonatomic) NSNumber * areaId;


@end

@implementation AddDestinationTableViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    
    self.areaId = [NSNumber numberWithInt:-1];
    
    [self.navigationItem setHidesBackButton:YES animated:YES];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, 30, 30);
    [button setTitle:@"取消" forState:0];
    button.titleLabel.font = GetFont(15);
    
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
    UIButton *saveBtn = [UIButton buttonWithType:0];
    [saveBtn addTarget:self action:@selector(saveButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn setTitle:@"保存" forState:0];
    saveBtn.titleLabel.font = GetFont(15);
    [saveBtn sizeToFit];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:saveBtn];
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    
    [self setTitle:@"创建地址"];
    
    self.addressTextView.delegate = self;
    self.textFieldArray = [NSMutableArray array];
    [self.textFieldArray addObjectsFromArray:@[self.nameTextField,self.phoneTextField,self.zipTextField,self.addressTextView]];
    
//    [self.textFieldArray addObjectsFromArray:@[@"",@"",@"",@""]];
    
    self.pickerView = [[CCCityPickerView alloc]init];
    self.pickerView.delegate = self;
    
    
    if (self.addressModel) {
        
        self.nameTextField.text= self.addressModel.consignee;
        self.phoneTextField.text =  self.addressModel.phone;
        self.zipTextField.text = self.addressModel.zipCode;
        self.addressTextView.text = self.addressModel.address;
        [self didSelectedAddress:self.addressModel.areaName areaId:self.addressModel.areaId];
        self.addressTextView.placehoderLabel.hidden = YES;
        self.isDefault = self.addressModel.isDefault.boolValue;
        self.selectImage.highlighted = self.isDefault;
        
    }
    
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"添加地址页面"];
    [TalkingData trackPageBegin:@"添加地址页面"];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"添加地址页面"];
    [TalkingData trackPageEnd:@"添加地址页面"];

}
- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)textViewDidChange:(UITextView *)textView{
    self.addressTextView.placehoderLabel.hidden = textView.text.length;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 5) {
        self.selectImage.highlighted = !self.selectImage.highlighted;
        self.isDefault = self.selectImage.highlighted;
    }
    if (indexPath.row == 3) {
        [self.pickerView showPickerView];
    }
}
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    for (UIResponder * tt in self.textFieldArray) {
        [tt resignFirstResponder];
    }
}
#pragma mark - CCCityPickerViewDelegate
- (void)didSelectedAddress:(NSString *)address areaId:(NSNumber *)idNum{
    self.cityLabel.text = address;
    self.addressSelect = YES;
    self.cityLabel.textColor = [UIColor blackColor];
    self.areaId = idNum;
    
}
#pragma mark -
- (void)saveButtonAction:(UIButton *)sender {
    
    if ([self checkInfo]) {
        [self.nameTextField resignFirstResponder];
        [self.phoneTextField resignFirstResponder];
        [self.addressTextView resignFirstResponder];
        
        NSString *nameStr = self.nameTextField.text;
        NSString *phoneStr = self.phoneTextField.text;
        NSString * zipStr = self.zipTextField.text?:@"";
        NSString *addressStr = self.addressTextView.text;
        NSNumber *number = [NSNumber numberWithBool:self.isDefault];
        NSNumber *areaId = self.areaId;
        [[HTUIHelper shareInstance ]addHUDToView:self.view withString:@"保存中" xOffset:0 yOffset:0];
        ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc]init];
        requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/add.jhtml"];
        /**
         *  修改信息
         */
        
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"areaId":areaId,
                                                                                @"consignee":nameStr,
                                                                                @"isDefault":number,
                                                                                @"address":addressStr,
                                                                                @"zipCode":zipStr,
                                                                                @"phone":phoneStr,
                                                                                }];
        if (self.addressModel) {
            requestInfo.URLString = [NSString stringWithFormat:@"/api/v5/member/receiver/update.jhtml"];
            
            
            [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.addressModel.id?:@""}];
        }
        
        __weak __typeof(&*self)weakSelf = self;
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *number = [responseObject objectForKey:@"state"];
                if (number.intValue == 0 ) {
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"保存成功" image:nil];
                    if (weakSelf.delegate) {
                        
                        //代理刷新地址管理UI及申请退换货UI
                        if ([weakSelf.delegate respondsToSelector:@selector(reloadDestinationData)]) {
                            
                            [weakSelf.delegate reloadDestinationData];
                        }
                        
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [weakSelf back:nil];
                        });
                        
                    }
                    
                    [weakSelf back:nil];
                    
                }else if (number.intValue == 1){
                    
                    [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                }
            }
            
            else{
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
        }];
        
    }
}

- (BOOL)checkInfo{
    BOOL flag = NO;
    
    if (self.nameTextField.text.length&&self.phoneTextField.text.length>6&&self.addressSelect&&self.addressTextView.text) {
        flag = YES;
        if (self.zipTextField.text.length) {
            if (self.zipTextField.text.length != 6) {
                flag = NO;
                [HTUIHelper addHUDToView:self.view withString:@"邮编不合法" hideDelay:1];
            }
        }
    }else{
        [HTUIHelper addHUDToView:self.view withString:@"收货信息不完整" hideDelay:1];
    }
    return flag;
}
//手机号码验证
- (BOOL) validateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

@end

@implementation RJTextView



@end





