
#import "RJAnswerViewController.h"
#import "HMSegmentedControl.h"


#import "RJAnswerOneViewController.h"
#import "RJAnswerTwoViewController.h"
#import "RJAnswerThreeViewController.h"
#import "RJAnswerFourViewController.h"
#import "GuideView.h"


#import "RJZhuShouViewController.h"
@interface RJAnswerViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate,UIScrollViewDelegate,RJAnswersSavaDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *containView;
@property (nonatomic,strong)HMSegmentedControl *topPageController;
@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSMutableArray * pages;
@property (weak,nonatomic)UIScrollView *pageScrollView;

@property (strong, nonatomic) RJAnswerOneViewController *oneVc;
@property (strong, nonatomic) RJAnswerTwoViewController *twoVC;
@property (strong, nonatomic) RJAnswerThreeViewController *threeVc;
@property (strong, nonatomic) RJAnswerFourViewController *fourVc;
@property (strong, nonatomic) NSMutableDictionary * getParams;

@property (strong, nonatomic) NSMutableDictionary * dicOne;
@property (strong, nonatomic) NSMutableDictionary * dicTwo;
@property (strong, nonatomic) NSMutableDictionary * dicThree;
@property (strong, nonatomic) NSMutableDictionary * dicFour;
@property (strong, nonatomic) UIButton * closeButton;

@end

@implementation RJAnswerViewController

- (void)viewDidLoad{
    
    [super viewDidLoad];
    self.getParams = [NSMutableDictionary dictionary];
    self.dicOne = [NSMutableDictionary dictionary];
    self.dicTwo = [NSMutableDictionary dictionary];
    self.dicThree = [NSMutableDictionary dictionary];
    self.dicFour = [NSMutableDictionary dictionary];

    
    self.topPageController = [[HMSegmentedControl alloc]initWithSectionTitles:@[@"颜色   ",@"款式   ",@"风格   "]];
    self.topPageController.backgroundColor = [UIColor colorWithHexString:@"#190d31"];
    
    self.topPageController.titleTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#9d9ba3"]};
    self.topPageController.selectedTitleTextAttributes = @{
                                                           NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                                                           NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#ffffff"]
                                                           };
    
    self.topPageController.selectionStyle = HMSegmentedControlSelectionStyleTextWidthStripe;
    self.topPageController.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.topPageController.selectionIndicatorColor = [UIColor colorWithHexString:@"#5d32b5"];
    self.topPageController.selectionIndicatorHeight = 3.0f;
    self.topPageController.frame = CGRectMake(40, 20, self.view.width-80, 50);
    [self.topView addSubview:self.topPageController];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageViewController.view.frame = self.containView.bounds;
    [self.pageViewController setDataSource:self];
    [self.pageViewController setDelegate:self];
    [self.pageViewController.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self addChildViewController:self.pageViewController];
    [self.containView addSubview:self.pageViewController.view];
    self.containView.backgroundColor = [UIColor whiteColor];
    [self.topPageController addTarget:self
                               action:@selector(pageControlValueChanged:)
                     forControlEvents:UIControlEventValueChanged];
    
    self.closeButton = [UIButton buttonWithType:0];
    [self.closeButton setImage:GetImage(@"small_closed") forState:0];
    self.closeButton.frame = CGRectMake(2, 28, 36, 36);
//    [self.closeButton setBackgroundColor:[UIColor redColor]];
    [self.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.closeButton];
    self.closeButton.hidden = YES;
    if (self.isPresentIn) {
        self.closeButton.hidden = NO;
    }
    [self setupViewControllers];

    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self addGuideView];
}

- (void)addGuideView{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:RJFirstInZuoTi]) {
        GuideView *guidView = [[GuideView alloc]initWithFrame:[UIScreen mainScreen].bounds];
        guidView.identifier = RJFirstInZuoTi;
        if (DEVICE_IS_IPHONE4) {
            guidView.localImage = @"dati_4";
        }
        if (DEVICE_IS_IPHONE5) {
            guidView.localImage = @"dati_5";
        }
        if (DEVICE_IS_IPHONE6) {
            guidView.localImage = @"dati_6";
        }
        if (DEVICE_IS_IPHONE6Plus) {
            guidView.localImage = @"dati_6p";
        }
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:guidView];
        
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:RJFirstInZuoTi];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }
}


- (void)closeButtonAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:^{
    
    }];
}
#pragma mark RJAnswersSavaDelegate
#pragma mark -
- (void)answerSaveWithDictionary:(NSMutableDictionary *)dic controllerIndex:(NSInteger )index{
    if (index == 0) {
        self.dicOne = [NSMutableDictionary dictionaryWithDictionary:[dic copy]];
//        NSLog(@"收到第一个问题答案 %@",self.dicOne);

    }
    if (index == 1) {
        self.dicTwo = [NSMutableDictionary dictionaryWithDictionary:[dic copy]];
//        NSLog(@"收到第二个问题答案%@",self.dicTwo);

    }
    if (index == 2) {
        self.dicThree = [NSMutableDictionary dictionaryWithDictionary:[dic copy]];
//        NSLog(@"收到第三个问题答案%@",self.dicThree);
        
    }
    if (index == 3) {
        self.dicFour = [NSMutableDictionary dictionaryWithDictionary:[dic copy]];
//        NSLog(@"收到第四个问题答案%@",self.dicFour);
        
    }
}
- (void)nextButtonClickedWithIndex:(NSInteger)index{
    /**
     *  2.2.0 没有第一问了 下标要改
     */
//    if (index == 0) {
//
//        [self.topPageController setSelectedSegmentIndex:1 animated:YES];
//    }
    if (index == 1) {
        [self.topPageController setSelectedSegmentIndex:1  animated:YES];
    }
    if (index == 2) {
        [self.topPageController setSelectedSegmentIndex:2 animated:YES];
    }
    if (index == 3) {
        //提交
        [self startRecommend];
    }
}
- (void)startRecommend{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/clad-aide/addfeatrueuser"];
//    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    [requestInfo.getParams addEntriesFromDictionary:self.dicOne];
    [requestInfo.getParams addEntriesFromDictionary:self.dicTwo];
    [requestInfo.getParams addEntriesFromDictionary:self.dicThree];
    [requestInfo.getParams addEntriesFromDictionary:self.dicFour];
//    NSLog(@"传递参数为：%@",requestInfo.getParams);
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"推荐中...请稍后..." xOffset:0 yOffset:0];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
        NSNumber *num = responseObject[@"state"];
        if (num.intValue == 0) {
            NSDictionary *dic = responseObject[@"data"];
            if (dic) {
                NSNumber *isSurvey =  dic[@"isSurvey"];
                if (isSurvey.boolValue) {
                    [RJAccountManager sharedInstance].account.isSurvey = [NSNumber numberWithBool:YES];
                    [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                    [[HTUIHelper shareInstance]removeHUD];
                    
                    if (self.isPresentIn) {
                        [self.delegate redoAnswerSaveAction];
                        [self dismissViewControllerAnimated:YES completion:^{
                            
                        }];
                    }else{
                        //替换Nav的controllers
                        RJZhuShouViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJZhuShouViewController"];
                        [self.navigationController setViewControllers:@[vc] animated:YES];
                    }
                    
                    
                    
                }else{
                    [RJAccountManager sharedInstance].account.isSurvey = [NSNumber numberWithBool:NO];
                    [[RJAccountManager sharedInstance]registerAccount:[RJAccountManager sharedInstance].account];
                    [[HTUIHelper shareInstance]removeHUDWithEndString:@"加载失败" image:nil];

                }
            }else{
                
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];

            }
        }else if(num.intValue == 1){
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }else if(num.intValue == 2){
//            if ([RJAccountManager sharedInstance].token) {
//                [[RJAppManager sharedInstance]showTokenDisableLoginVc];
//            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        [[HTUIHelper shareInstance]removeHUDWithEndString:@"加载失败，请稍后再试" image:nil];
    }];
}

#pragma mark -
- (void)setupViewControllers{
    NSMutableArray *pages = [NSMutableArray new];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
//    self.oneVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJAnswerOneViewController"];
    self.twoVC = [storyBoard instantiateViewControllerWithIdentifier:@"RJAnswerTwoViewController"];
    self.threeVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJAnswerThreeViewController"];
    self.fourVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJAnswerFourViewController"];
    self.oneVc.delegate = self;
    self.twoVC.delegate = self;
    self.threeVc.delegate = self;
    self.fourVc.delegate = self;
//    [pages addObject:_oneVc];
    [pages addObject:_twoVC];
    [pages addObject:_threeVc];
    [pages addObject:_fourVc];
    
    [self setPages:pages];
    
    for (UIView *view in self.pageViewController.view.subviews) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.pageScrollView =(UIScrollView *)view;
            _pageScrollView.delegate = self;
            _pageScrollView.scrollEnabled = YES;
            _pageScrollView.scrollsToTop = NO;
        }
    }
    if ([self.pages count]>0) {
        [self.topPageController setSelectedSegmentIndex:0 animated:YES];
        [self.pageViewController setViewControllers:@[self.pages[0]]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:YES
                                         completion:nil];
    }
    
}


#pragma mark - Callback

- (void)pageControlValueChanged:(id)sender
{
    
    UIPageViewControllerNavigationDirection direction = [self.topPageController selectedSegmentIndex] > [self.pages indexOfObject:[self.pageViewController.viewControllers lastObject]] ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    
    [self.pageViewController setViewControllers:@[[self selectedController]]
                                      direction:direction
                                       animated:YES
                                     completion:NULL];
    
}
- (UIViewController *)selectedController
{
    return self.pages[[self.topPageController selectedSegmentIndex]];
}

-(NSMutableArray *)pages{
    if (!_pages) {
        _pages = [[NSMutableArray alloc]init];
    }
    return _pages;
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pages indexOfObject:viewController];
    
    if ((index == NSNotFound) || (index == 0)) {
        return nil;
    }
    
    return self.pages[--index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [self.pages indexOfObject:viewController];
    
    if ((index == NSNotFound)||(index+1 >= [self.pages count])) {
        return nil;
    }
    return self.pages[++index];
}

- (void)pageViewController:(UIPageViewController *)viewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    if (!completed){
        return;
    }
    [self.topPageController setSelectedSegmentIndex:[self.pages indexOfObject:[viewController.viewControllers lastObject]] animated:YES];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [MobClick beginLogPageView:@"穿衣助手问卷"];
    [TalkingData trackPageBegin:@"穿衣助手问卷"];


    //    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"穿衣助手问卷"];
    [TalkingData trackPageEnd:@"穿衣助手问卷"];


//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}
@end
