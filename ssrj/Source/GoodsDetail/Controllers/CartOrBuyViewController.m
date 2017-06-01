//
//  CartOrBuyViewController.m
//  ssrj
//
//  Created by MFD on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CartOrBuyViewController.h"
#import "GoodsDetailViewController.h"
#import "CartViewController.h"
#import "CheckOrderViewController.h"
#import "RJAnswerOneViewController.h"
#import "BindTelephoneController.h"
#import "UIImage+New.h"
#import <Masonry.h>


@interface CartOrBuyViewController ()<RJAnswersSavaDelegate>
@property (nonatomic,strong)NSMutableArray *products;
@property (nonatomic,strong)NSMutableArray *colors;

@property (nonatomic,strong)NSMutableArray *sizeBtns;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic,strong)RJGoodDetailProductsModel *selectedProduct;
/**
 *  颜色按钮父视图
 */
@property (weak, nonatomic) IBOutlet UIView *colorButtonView;
/**
 *  上方透明视图 用于点击事件 点击取消当前视图
 */
@property (weak, nonatomic) IBOutlet UIView *topView;

@property (weak, nonatomic) IBOutlet UIView *sizeButtonView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sizeButtonViewHeightConstraint;

/**
 *  记录当前选择的件数
 */
@property (nonatomic, assign) NSInteger choseCount;
@property (nonatomic,assign) BOOL isPreSale;
@property (nonatomic,strong) RJCartOrBuyCustomerButton * selectSizeButton;
@end
/**
 *  部分重构与3.1.0版本  By CC
 */
@implementation CartOrBuyViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.sizeBtns = [NSMutableArray array];
    self.choseCount = 1;
    self.goodsImage.layer.borderWidth = 1;
    self.goodsImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.goodsImage.layer.masksToBounds = YES;
    if (self.datamodel.defaultRecommend.length) {
        self.recommendLabel.text = self.datamodel.defaultRecommend;
    }
    else {
        self.recommendLabel.text = @"无";
    }
    /**
     *  是否是预售
     */
    self.isPreSale = self.datamodel.isPreSale.boolValue;
    
    self.sureBtn.layer.cornerRadius = 6;
    self.sureBtn.layer.masksToBounds = YES;
    [self.sureBtn addTarget:self action:@selector(clickSureBtn:) forControlEvents:UIControlEventTouchUpInside];
    if (self.datamodel.productImages.count) {
        RJGoodDetailProductImagesModel *productImages = self.datamodel.productImages[0];
        [self.goodsImage sd_setImageWithURL:[NSURL URLWithString:productImages.medium]  placeholderImage:GetImage(@"default_1x1")];
    }
    self.goodsName.text = self.datamodel.name;
    self.goodsBrandName.text = self.datamodel.brandName;
    self.price.text = [NSString stringWithFormat:@"¥ %@",self.datamodel.effectivePrice];
    [self.reduceButton addTarget:self action:@selector(clickReduce) forControlEvents:UIControlEventTouchUpInside];
    [self.addButton addTarget:self action:@selector(clickAdd) forControlEvents:UIControlEventTouchUpInside];
    [self.recommentSizeButton addTarget:self action:@selector(recommentSizeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.headerLineHeightConstraint.constant = 0.7;
    
    [self initColorBtns];
    [self initSizeBtns];
    self.preSaleDescription.text = @"";
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.topView addGestureRecognizer:tapGestureRecognizer];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"加入购物车＋立即购买弹出页面"];
    [TalkingData trackPageBegin:@"加入购物车＋立即购买弹出页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"加入购物车＋立即购买弹出页面"];
    [TalkingData trackPageEnd:@"加入购物车＋立即购买弹出页面"];
    
}
- (void)addViewToKeyWindow {
    
    self.view.frame = CGRectMake(0, self.view.height, SCREEN_WIDTH, self.view.height);
    _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0;

    [[UIApplication sharedApplication].keyWindow addSubview:_maskView];
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    
    [UIView animateWithDuration:0.2 animations:^{
        _maskView.alpha = 0.3;
        self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, -self.view.height);
    }];
    
}
- (void)removeViewFromKeyWindow {
    [UIView animateWithDuration:0.2 animations:^{
        _maskView.alpha = 0;
        self.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:self.view]) {
            [self.view removeFromSuperview];
        }
    }];
    
}
- (void)removeViewFromKeyWindowWithBlock: (void (^)())block {
    [UIView animateWithDuration:0.2 animations:^{
        _maskView.alpha = 0;
        self.view.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if ([[UIApplication sharedApplication].keyWindow.subviews containsObject:self.view]) {
            [self.view removeFromSuperview];
            if (block) {
                block();
            }
        }
    }];
}
- (void)tapHandle:(UITapGestureRecognizer *)gesture {
    [self removeViewFromKeyWindow];
}
- (NSMutableArray *)products{
    if (_products == nil) {
        _products = [NSMutableArray arrayWithArray:[self.datamodel.products copy]];
    }
    return _products;
}
- (NSMutableArray *)colors{
    if (_colors == nil) {
        _colors = [NSMutableArray array];
    }
    return _colors;
}

#pragma mark -推荐尺码答题页代理方法
-(void)saveRecommentedSizeInfo {
    
    if ([self.delegate respondsToSelector:@selector(reloadGoodsDetailCloseCoverWithisReload:)]) {
        
        [self.delegate reloadGoodsDetailCloseCoverWithisReload:YES];
    }
}

#pragma mark -点击修改推荐尺码
- (void)recommentSizeButtonClicked {
    __weak __typeof(&*self)weakSelf = self;
    [self removeViewFromKeyWindowWithBlock:^{
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        
        RJAnswerOneViewController * answerVC = [story instantiateViewControllerWithIdentifier:@"RJAnswerOneViewController"];
        answerVC.delegate = weakSelf;
        
        [weakSelf.navigationController pushViewController:answerVC animated:YES];
    }];
}


- (void)initColorBtns{
    
    [self.view layoutIfNeeded];

    CGFloat minWidth = (self.colorButtonView.width - 50)/4;
    
    RJCartOrBuyCustomerButton *colorButton = [RJCartOrBuyCustomerButton buttonWithType:0];
    
    [colorButton setTitle:self.datamodel.colorName forState:0];
    [colorButton setSelected:YES];
    [colorButton sizeToFit];
    [colorButton customInit];
    [self.colorButtonView addSubview:colorButton];

    [colorButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.colorButtonView.mas_left).with.offset(10);
        make.centerY.equalTo(self.colorButtonView.mas_centerY).with.offset(0);
        make.width.mas_greaterThanOrEqualTo(minWidth);
        make.height.mas_equalTo(25);
    }];
    [colorButton sizeToFit];
}

- (void)initSizeBtns{
    [self.view layoutIfNeeded];
//    RJGoodDetailProductsModel *item = [[RJGoodDetailProductsModel alloc]init];
//    item.specification = @"测试";
//    [self.products addObject:item];
//    [self.products addObject:item];
//    [self.products addObject:item];

    CGFloat minWidth = (self.sizeButtonView.width - 42)/4;
    UIButton *lastButton = nil;
    for (int i=0; i<self.products.count; i++) {
        
        RJGoodDetailProductsModel *productItem = self.products[i];
        RJCartOrBuyCustomerButton *sizeButton = [RJCartOrBuyCustomerButton buttonWithType:0];
        sizeButton.tag = i;
        [sizeButton sizeToFit];
        [sizeButton customInit];
        [self.sizeBtns addObject:sizeButton];
        [self.sizeButtonView addSubview:sizeButton];
        
        sizeButton.model = productItem;

//        [sizeButton setNormalSaleState];
        
        [sizeButton addTarget:self action:@selector(selectSize:) forControlEvents:UIControlEventTouchUpInside];
        /**
         *  判断当前商品的状态 是否支持预售 只是初始状态
         */

//        if (self.isPreSale) {
//            //支持预售
//            //现货和预售都卖完了
//            if ((!productItem.isAvailable.boolValue)&&(!productItem.isAvailablePreStock.boolValue)) {
//                sizeButton.enabled = NO;
//            }else{
//                if (productItem.isAvailable.boolValue) {
//                    [sizeButton setNormalSaleState];
//                }else{
//                    [sizeButton setPreSaleState];
//                }
//            }
//        }else{
//            if (!productItem.isAvailable.boolValue) {
//                sizeButton.enabled = NO;
//            }
//        }
        if (i == 0 || i == 4) {
            [sizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.sizeButtonView.mas_left).with.offset(10);
                
                if (i == 4) {
                    make.top.equalTo(lastButton.mas_bottom).with.offset(10);
                }else{
                    make.top.equalTo(self.sizeButtonView.mas_top).with.offset(0);
                }
                make.width.mas_greaterThanOrEqualTo(minWidth);
                make.height.mas_equalTo(25);
            }];
            lastButton = sizeButton;

        }else if(i<=3){
            
            [sizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(lastButton.mas_right).with.offset(5);
                make.top.equalTo(self.sizeButtonView.mas_top).with.offset(0);
                make.width.mas_greaterThanOrEqualTo(minWidth);
                make.height.mas_equalTo(25);
            }];
            lastButton = sizeButton;
        }else if( i >4 && i< 8){
            [sizeButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(lastButton.mas_right).with.offset(5);
                make.centerY.equalTo(lastButton.mas_centerY).with.offset(0);
                make.width.mas_greaterThanOrEqualTo(minWidth);
                make.height.mas_equalTo(25);
            }];
            lastButton = sizeButton;
        }
    }
//    if (self.products.count <= 4) {
//        self.sizeButtonViewHeightConstraint.constant = 25 +15;
//    }else{
//        self.sizeButtonViewHeightConstraint.constant = 25 +15 + 25 +5;
//
//    }
    self.sizeButtonViewHeightConstraint.constant = 25 +15 + 25 +5;
}

#pragma mark 尺寸按钮点击事件
- (void)selectSize:(RJCartOrBuyCustomerButton *)sizeBtn{
    if (sizeBtn.selected) {
        return;
    }
    RJGoodDetailProductsModel *productItem = self.products[sizeBtn.tag];

    
    self.selectedProduct = productItem;
    for (RJCartOrBuyCustomerButton *button in self.sizeBtns) {
        button.selected = NO;
        //重置按钮状态
        RJGoodDetailProductsModel *product = self.products[button.tag];
        button.model = product;
    }
    sizeBtn.selected = YES;
    NSString *recomendSizeStr = self.selectedProduct.sizeRecommend.length?self.selectedProduct.sizeRecommend:@"无";
    self.recommendLabel.text = recomendSizeStr;
    
    self.selectSizeButton = sizeBtn;
    /**
     *  每次选择尺寸先默认设置为1 参照京东
     */
    self.choseCount = 1;
    self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)self.choseCount];
    self.reduceButton.enabled = NO;
    /**
     *  判断预售说明 是否要显示
     */
    self.preSaleDescription.text = @"";

    if (!productItem.isAvailable.boolValue && productItem.isAvailablePreStock.boolValue) {
        self.preSaleDescription.text = productItem.preSaleDesc;
    }
    
    
}

#pragma mark -
#pragma mark 减号
- (void)clickReduce{

    if (self.choseCount == 1) {
        return;
    }
    if(!self.isPreSale){
        NSInteger temp = self.choseCount;
        temp -= 1;
        self.choseCount = temp;
        self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)temp];
        if (self.choseCount == 1) {
            self.reduceButton.enabled = NO;
        }
    }else{
        //预售
        NSInteger temp = self.choseCount;
        temp -= 1;
        NSInteger  stock = self.selectedProduct.availableStock.integerValue;
//        NSInteger preStock = self.selectedProduct.availablePreStock.integerValue;
        if (temp<=stock) {
            [self.selectSizeButton setNormalSaleState];
            self.preSaleDescription.text = @"";
        }else if(temp>stock){
            [self.selectSizeButton setPreSaleState];
            self.preSaleDescription.text = self.selectedProduct.preSaleDesc;
        }
        self.choseCount = temp;
        self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)temp];
        if (self.choseCount == 1) {
            self.reduceButton.enabled = NO;
        }

    }
}

#pragma mark -
#pragma mark 加号
- (void)clickAdd{
    if (!self.selectedProduct) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"请先选择尺码信息" hideDelay:1];
        return;
    }
    /**
     *  校验库存
     */
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"校验库存中" xOffset:0 yOffset:0];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"api/v5/product/check.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"productId":self.selectedProduct.productsId}];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state && state.intValue == 0) {
            NSDictionary *dic = responseObject[@"data"];
            if (dic) {
                NSNumber *availableStock = dic[@"availableStock"];
                self.selectedProduct.availableStock = availableStock;
                NSNumber *availablePreStock = dic[@"availablePreStock"];
                self.selectedProduct.availablePreStock = availablePreStock;
                NSNumber *isAvailable = dic[@"isAvailable"];
                self.selectedProduct.isAvailable = isAvailable;
                NSNumber *isAvailablePreStock = dic[@"isAvailablePreStock"];
                self.selectedProduct.isAvailablePreStock = isAvailablePreStock;
                NSString *preSaleDesc = dic[@"preSaleDesc"];
                self.selectedProduct.preSaleDesc = preSaleDesc;
            }
        }
        [[HTUIHelper shareInstance]removeHUD];;
        [self reloadAddButton];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error);
        [[HTUIHelper shareInstance]removeHUD];
        [self reloadAddButton];

    }];
    
    
    
}
- (void)reloadAddButton{
    if (!self.isPreSale) {
        NSInteger temp = self.choseCount;
        temp += 1;
        NSInteger stock = self.selectedProduct.availableStock.integerValue;
        if (temp > stock) {
            temp = stock;
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"库存不足!" hideDelay:1];
        }
        self.choseCount = temp;
        if (self.choseCount>1) {
            self.reduceButton.enabled = YES;
        }
        self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)self.choseCount];
    }else{
        //支持预售
        NSInteger temp = self.choseCount;
        temp += 1;
        NSInteger  stock = self.selectedProduct.availableStock.integerValue;
        NSInteger preStock = self.selectedProduct.availablePreStock.integerValue;
        if (temp<=stock) {
            self.preSaleDescription.text = @"";
            [self.selectSizeButton setNormalSaleState];
        }else if(temp<= (stock + preStock)){
            self.preSaleDescription.text = self.selectedProduct.preSaleDesc;
            [self.selectSizeButton setPreSaleState];
        }else{
            temp = self.choseCount;
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"库存不足!" hideDelay:1];
            
        }
        self.choseCount = temp;
        if (self.choseCount>1) {
            self.reduceButton.enabled = YES;
        }
        self.countLabel.text = [NSString stringWithFormat:@"%ld",(long)self.choseCount];
    }

    
}


#pragma mark --确定按钮点击事件
- (void)clickSureBtn:(id)sender {
    /**
     * 3.0.1
     */
    RJAccountModel *account = [RJAccountManager sharedInstance].account;

    if (account.isBinding.intValue == 0 || account.isBinding == nil) {  // isBinding=1 绑定， =0 未绑定
        
        [self removeViewFromKeyWindow];
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
            
        BindTelephoneController * bindVC = [story instantiateViewControllerWithIdentifier:@"BindTelephoneController"];
        bindVC.userIconURL = account.avatar;
        bindVC.userNickName = account.nickname;
        
        [self.parentViewController presentViewController:bindVC animated:YES completion:nil];
        
        return;
    }
    if (!self.selectedProduct){
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"请选择颜色或尺码" hideDelay:1];
        return ;
    }
    //按钮tag分别设置为88和99，区分是加入购物车还是立即购买
    [self getNetData];

}

- (void)getNetData{
    [self removeViewFromKeyWindow];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSMutableDictionary *umDic = [NSMutableDictionary dictionary];
    
    if (self.cartOrBuy == 88) {
        //3.1.0 支持预售
        requestInfo.URLString = @"/api/v5/member/cart/add_product.jhtml";
    }else{
        //3.1.0 支持预售
        requestInfo.URLString = @"api/v5/member/cart/buy_product.jhtml";
    }
    requestInfo.modelClass = [cartOrBuyModel class];
    
    
    if (self.selectedProduct && [[RJAccountManager sharedInstance]hasAccountLogin]){
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token,@"productId":self.selectedProduct.productsId,@"quantity":@(self.choseCount)}];
        
        /**
         *  2.2.0新增 如果是从搭配进来的 需要吧搭配Id上传服务器
         */
        if (self.fomeCollectionId) {
            [requestInfo.postParams addEntriesFromDictionary:@{@"collocationId":self.fomeCollectionId}];
        }
        
        [umDic addEntriesFromDictionary:@{@"衣服名称":self.selectedProduct.name?:@"",@"sn":self.selectedProduct.sn?:@"",@"数量":self.countLabel.text?:@"1",@"productsId":self.selectedProduct.productsId.stringValue?:@"",@"尺寸":self.selectedProduct.specification?:@""}];
        [MobClick event:@"add_shopCart_action" attributes:umDic counter:self.selectedProduct.cost.intValue];
        
    }else{
        return ;
    }
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"添加中..." xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[cartOrBuyModel class]]) {
            weakSelf.cartorbuymodel = responseObject;
            if (weakSelf.cartorbuymodel.state.intValue == 0) {
                if (weakSelf.cartOrBuy == 88) {
                    //Yi
                    //购物车内商品数量更改（此处为添加）发送通知
                    if (weakSelf.cartorbuymodel.data.productQuantity) {
                        [RJAccountManager sharedInstance].account.cartProductQuantity = weakSelf.cartorbuymodel.data.productQuantity;
                        [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCartNumberChanged object:nil];
                    }
                    
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"已成功加入购物车" image:nil];

                }
                //立即购买
                else{
                    
                    if (weakSelf.cartorbuymodel.data.cartItemId) {
                        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                        CheckOrderViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CheckOrderViewController"];
                        ZHRequestInfo *requesInfo = [ZHRequestInfo new];
                        /**
                         *  2.1.4 更改V5接口
                         */
                        requesInfo.URLString = @"/api/v5/member/order/checkout_orders.jhtml?";
                        requesInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"ids":weakSelf.cartorbuymodel.data.cartItemId}];
                        
                        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requesInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
                            if ([responseObject objectForKey:@"state"]) {
                                NSNumber *number = [responseObject objectForKey:@"state"];
                                if (number.intValue == 0) {
                                    NSDictionary *dic = responseObject[@"data"];
                                    NSError __autoreleasing *e = nil;
                                    RJCheckOrderModel *model = [[RJCheckOrderModel alloc]initWithDictionary:dic error:&e];
                                    if (model) {
                                        [[HTUIHelper shareInstance]removeHUD];
                                        vc.model = model;
                                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                            
                                            [self.navigationController pushViewController:vc animated:YES];
                                        });
                                    }else{
                                        [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                                    }
                                    
                                }else{
                                    [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                                }
                            }else{
                                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                            }
                            
                        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                            [[HTUIHelper shareInstance]removeHUDWithEndString:@"网络请求失败" image:nil];
                        }];
                        [[HTUIHelper shareInstance]removeHUD];
                    }else{
                        
                        [[HTUIHelper shareInstance]removeHUDWithEndString:weakSelf.cartorbuymodel.msg  image:nil delyTime:1];

                    }
                }
                
                
                
            }else if(weakSelf.cartorbuymodel.state.intValue == 1){
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:weakSelf.cartorbuymodel.msg  image:nil delyTime:1];
            }
//            else if(weakSelf.cartorbuymodel.state.intValue == 2){
//                if ([RJAccountManager sharedInstance].token) {
//                    [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//                }
//            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"Error" image:nil];
    }];

}

@end



@implementation RJCartOrBuyCustomerButton

- (void)customInit{
    CGFloat fontSize;
    if (DEVICE_IS_IPHONE4 || DEVICE_IS_IPHONE5) {
        fontSize = 11;
    }else{
        fontSize = 13;
    }
        
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#f2f2f2"] size:self.size] forState:0];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#000000"] size:self.size] forState:UIControlStateSelected];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"#fbfbfb"] size:self.size] forState:UIControlStateDisabled];

//    [self setTitleColor:[UIColor colorWithHexString:@"#d8d8d8"] forState:UIControlStateDisabled];
//
//    [self setTitleColor:[UIColor colorWithHexString:@"#000000"] forState:0];
//    [self setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateSelected];
    
    self.titleLabel.font = GetFont(fontSize);
    
}
- (void)setPreSaleState{
    CGFloat fontSize;
    if (DEVICE_IS_IPHONE4 || DEVICE_IS_IPHONE5) {
        fontSize = 9;
    }else{
        fontSize = 11;
    }
    NSMutableAttributedString *atString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ [预售]",self.model.specification]];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    NSDictionary *attrsDictionary1 = @{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],
                                       NSParagraphStyleAttributeName:paragraphStyle};
    [atString addAttributes:attrsDictionary1 range:NSMakeRange(self.model.specification.length, 4)];

    
    [self setAttributedTitle:atString forState:0];
    NSMutableAttributedString *atStr2 = [atString mutableCopy];
    [atStr2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#ffffff"] range:NSMakeRange(0, atStr2.length)];
    [self setAttributedTitle:atStr2 forState:UIControlStateSelected];

}
- (void)setNormalSaleState{
    
    NSMutableAttributedString *atString = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@",self.model.specification]];
    [self setAttributedTitle:atString forState:0];
    NSMutableAttributedString *atstr2 = [atString mutableCopy];
    [atstr2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#d8d8d8"] range:NSMakeRange(0, atstr2.length)];
    [self setAttributedTitle:atstr2 forState:UIControlStateDisabled];
    NSMutableAttributedString *atstr3 = [atString mutableCopy];
    [atstr3 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#ffffff"] range:NSMakeRange(0, atstr3.length)];
    [self setAttributedTitle:atstr3 forState:UIControlStateSelected];
    
}
- (void)setModel:(RJGoodDetailProductsModel *)model{
    _model = model;
    [self setNormalSaleState];

    if (model.isPreSale.boolValue) {
        //支持预售
        //现货和预售都卖完了
        if ((!model.isAvailable.boolValue)&&(!model.isAvailablePreStock.boolValue)) {
            self.enabled = NO;
        }else{
            if (model.isAvailable.boolValue) {
                [self setNormalSaleState];
            }else{
                [self setPreSaleState];
            }
        }
    }else{
        if (!model.isAvailable.boolValue) {
            self.enabled = NO;
        }
    }

}
@end
