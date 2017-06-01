
#import "RJBasicViewController.h"
#import "CartViewController.h"
@interface RJBasicViewController ()
@property (nonatomic, strong) UIButton			*titleBtn;

@end

@implementation RJBasicViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[SDImageCache sharedImageCache]clearMemory];

}
- (void)addBackButton{
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImg = GetImage(@"back_icon");
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+20, buttonImg.size.height);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button setImage:buttonImg forState:0];
//    button.tag = 200;
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.trackingId = [NSString stringWithFormat:@"%@&backButton",NSStringFromClass(self.class)];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
}
- (void)addCloseButton{
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *buttonImg = GetImage(@"back_icon");
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, 40, 40);
//    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
//    [button setImage:buttonImg forState:0];
    //    button.tag = 200;
    [button setTitle:@"关闭" forState:0];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    button.trackingId = [NSString stringWithFormat:@"%@&closeButton",NSStringFromClass(self.class)];
    self.navigationItem.leftBarButtonItem = buttonItem;
}

- (void)addSaveButton{
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    UIImage *buttonImg = GetImage(@"back_icon");
    [button addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, 40, 40);
//    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
//    [button setImage:buttonImg forState:0];
    [button setTitle:@"保存" forState:0];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
//    button.tag = 201;
    button.trackingId = [NSString stringWithFormat:@"%@&SaveButton",NSStringFromClass(self.class)];

    self.navigationItem.rightBarButtonItem = buttonItem;
}

- (UIBarButtonItem *)getBarButtonItemWithType:(RJButtonItemType)type{
    UIButton *button = nil;
    if (type == RJNavCartButtonItem) {
//        button = [CCCartBarItemButton buttonWithType:0];
        button = [[CCCartBarItemButton alloc]initWithFrame:CGRectZero];

    }else{
        button = [UIButton buttonWithType:UIButtonTypeCustom];

    }
    
    UIImage *buttonImg = nil;
    button.tag = type;
//    [button setTitle:@"" forState:0];
    switch (type) {
        case RJNavBackButtonItem:
            buttonImg = [UIImage imageNamed:@"back_icon"];
            [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
            button.trackingId = [NSString stringWithFormat:@"%@&backButton",NSStringFromClass(self.class)];

            break;
        case RJNavSearchButtonItem:
            buttonImg = [UIImage imageNamed:@"suozhou_icon"];
            [button addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
            button.trackingId = [NSString stringWithFormat:@"%@&searchButton",NSStringFromClass(self.class)];

            break;
        case RJNavShareButtonItem:
            buttonImg = [UIImage imageNamed:@"zhuanfa_icon"];
            [button addTarget:self action:@selector(share:) forControlEvents:UIControlEventTouchUpInside];
            button.trackingId = [NSString stringWithFormat:@"%@&shareButton",NSStringFromClass(self.class)];

            break;
        case RJNavCartButtonItem:
            buttonImg = [UIImage imageNamed:@"gouwudai_icon"];
            [button addTarget:self action:@selector(cart:) forControlEvents:UIControlEventTouchUpInside];
            button.trackingId = [NSString stringWithFormat:@"%@&cartButton",NSStringFromClass(self.class)];

            button.titleLabel.font = GetFont(11);
            break;
        case RJNavColseButtonItem:
            [button addTarget:self action:@selector(dismiss:) forControlEvents:UIControlEventTouchUpInside];
            button.trackingId = [NSString stringWithFormat:@"%@&closeButton",NSStringFromClass(self.class)];

            [button setTitle:@"关闭" forState:0];
            [button setTitleColor:[UIColor whiteColor] forState:0];
            break;
        case RJNavDoneButtonItem:
            [button addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
            button.trackingId = [NSString stringWithFormat:@"%@&doneButton",NSStringFromClass(self.class)];

            [button setTitle:@"完成" forState:0];
            [button setTitleColor:[UIColor whiteColor] forState:0];
            break;
        case RJNavLikeButtonItem:
            [button addTarget:self action:@selector(like:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:GetImage(@"BIGlike") forState:0];
            [button setImage:GetImage(@"BIGlikelight") forState:UIControlStateHighlighted];
            [button setImage:GetImage(@"BIGlikelight") forState:UIControlStateSelected];
            button.trackingId = [NSString stringWithFormat:@"%@&likeButton",NSStringFromClass(self.class)];

            break;
        default:
            break;
    }
    if (buttonImg) {
        if (type == RJNavBackButtonItem) {
            button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+20, buttonImg.size.height);
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
           [button setImage:buttonImg forState:0];
        }else if (type == RJNavCartButtonItem) {
            button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width, buttonImg.size.height);
            [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
            button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, -8, 0);
            
//            [button setTitle:@"3" forState:0];
            //todo
        }else if (type == RJNavSearchButtonItem) {
            button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+10, buttonImg.size.height);
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [button setImage:buttonImg forState:0];
        }
        else if (type == RJNavShareButtonItem) {
            button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+10, buttonImg.size.height);
            [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
            [button setImage:buttonImg forState:0];
        }
        
        else{
            button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width, buttonImg.size.height);
            [button setBackgroundImage:buttonImg forState:UIControlStateNormal];
//            button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+10, buttonImg.size.height);
//            [button setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
//            [button setImage:buttonImg forState:0];
        }
    }else{
        button.frame = CGRectMake(0, 0, 50, 35);
    }

    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return buttonItem;
}
- (void)addBarButtonItem:(RJButtonItemType)type onSide:(RJSideType)side{
    UIBarButtonItem *buttonItem = [self getBarButtonItemWithType:type];
    if (side == RJNavLeftSide)
        self.navigationItem.leftBarButtonItem = buttonItem;
    else if (side == RJNavRightSide)
        self.navigationItem.rightBarButtonItem = buttonItem;
    
}
- (void)addBarButtonItems:(NSArray *)itemsArray onSide:(RJSideType)side{
    NSMutableArray *array = [[NSMutableArray alloc]initWithCapacity:itemsArray.count];
    for (NSNumber *num in itemsArray) {
        UIBarButtonItem *item = [self getBarButtonItemWithType:num.integerValue];
        [array addObject:item];
    }
    if (side == RJNavLeftSide) {
        self.navigationItem.leftBarButtonItems = array;
    }else if (side == RJNavRightSide){
        self.navigationItem.rightBarButtonItems = array;

    }
}
- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)share:(id)sender{
    
}
- (void)cart:(id)sender{
    /**
     *  去购物车
     */
    if ([RJAccountManager sharedInstance].hasAccountLogin) {
        //登录了 就去购物车
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        CartViewController *vc = [story instantiateViewControllerWithIdentifier:@"CartViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        //去登录界面
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
    }
    
}
- (void)search:(id)sender{
    
}
- (void)scan:(id)sender{
    
}
- (void)done:(id)sender{

}
- (void)save:(id)sender{
    
}
- (void)dismiss:(id)sender{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (void)like:(id)sender{
    
}

- (void)enableBackSwipeGesture {
    if (IOS7_OR_LATER)
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)disableBackSwipeGesture {
    if (IOS7_OR_LATER)
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        if (self.isRootViewController) {
            return NO;
        }
    }
    return YES;
    
}
#pragma mark - Title view

- (void)setTitle:(NSString *)title tappable:(BOOL)tappable {
    [self setTitle:title tappable:tappable textColor:[UIColor whiteColor]];
}

- (void)setTitle:(NSString *)title tappable:(BOOL)tappable textColor:(UIColor *)textColor {
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.backgroundColor = [UIColor clearColor];
    if (textColor)
        titleLabel.textColor = textColor;
    else
        titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0f];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel sizeToFit];
    
    if (tappable) {
        UIImage *triangleImg = [UIImage imageNamed:@"BoSelectGroup_tip"];
        CGFloat viewWidth = titleLabel.frame.size.width + triangleImg.size.width + 10.0f;
        if (viewWidth < 149.0f)
            viewWidth = 149.0f;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, viewWidth, 44.0f)];
        titleLabel.center = view.center;
        [view addSubview:titleLabel];
        
        UIImageView *triangleIV = [[UIImageView alloc] initWithImage:triangleImg];
        triangleIV.frame = CGRectMake(titleLabel.frame.origin.x + titleLabel.frame.size.width + 10.0f, (view.frame.size.height - triangleImg.size.height)/2.0f, triangleImg.size.width, triangleImg.size.height);
        [view addSubview:triangleIV];
        
        self.titleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _titleBtn.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, viewWidth, 44.0f);
        [_titleBtn addTarget:self action:@selector(didTapTitle:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:_titleBtn];
        self.navigationItem.titleView = view;
        self.triangleImg = triangleIV;
        NSString *vc = [[RJAppManager sharedInstance] currentViewControllerName];
        self.titleBtn.trackingId = [NSString stringWithFormat:@"%@&titleBtn",vc];
    }
    else
        self.navigationItem.titleView = titleLabel;
}

- (void)setTitleImage:(UIImage *)image {
    UIImageView *titleIV = [[UIImageView alloc] initWithImage:image];
    self.navigationItem.titleView = titleIV;
}

#pragma mark - Navigation bar title view action

- (void)didTapTitle:(UIButton *)sender {

}
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

@end




@implementation CCCartBarItemButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cartNumberChangeNotification:) name:kNotificationCartNumberChanged object:nil];
        /**
         *  初始化按钮 去AccountManager取值
         */
        if ([RJAccountManager sharedInstance].hasAccountLogin) {
            [self setTitle:[RJAccountManager sharedInstance].account.cartProductQuantity.stringValue forState:0];
        }else{
            [self setTitle:@"" forState:0];
        }
        
      }
    return self;
}
- (void)cartNumberChangeNotification:(NSNotification *)sender{
    

    if ([RJAccountManager sharedInstance].hasAccountLogin) {
        [self setTitle:[RJAccountManager sharedInstance].account.cartProductQuantity.stringValue forState:0];
    }else{
        [self setTitle:@"" forState:0];
    }
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationCartNumberChanged object:nil];
}
@end
