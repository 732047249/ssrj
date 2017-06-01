
#import "RJZhushouNavigationController.h"
#import "RJZhuShouViewController.h"
#import "RJAnswerViewController.h"
@interface RJZhushouNavigationController ()
@property (assign, nonatomic) BOOL  shouldLoaded;
@end

@implementation RJZhushouNavigationController
- (void)viewDidLoad{
    [super viewDidLoad];
//#warning debug  
//    [RJAccountManager sharedInstance].account.isSurvey = [NSNumber numberWithBool:NO];
    self.navigationBar.translucent = NO;
    
    RJZhuShouViewController *zhushouVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJZhuShouViewController"];
    [self setViewControllers:@[zhushouVc]];
    /**
     *  2.2.0 不需要做题和登录也能去推荐界面了
     */
    //之前做过题了 有值了
//    if ([RJAccountManager sharedInstance].account.isSurvey.boolValue == YES) {
//        //直接去推荐界面
//        RJZhuShouViewController *zhushouVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJZhuShouViewController"];
//        [self setViewControllers:@[zhushouVc]];
//    }else{
//        RJAnswerViewController *answerVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJAnswerViewController"];
//        [self setViewControllers:@[answerVc]];
//
//    }
    
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationWithLogout:) name:kNotificationLogoutSuccess object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationWithLogin:) name:kNotificationLoginSuccess object:nil];
}
//- (void)notificationWithLogout:(NSNotification *)sender{
////    NSLog(@"收到退出登录通知");
//    self.shouldLoaded = YES;
//    [self setViewControllers:@[]];
//}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
//    if (self.shouldLoaded) {
//        self.shouldLoaded = NO;
//        //之前做过题了 有值了
//        if ([RJAccountManager sharedInstance].account.isSurvey.boolValue == YES) {
//            //直接去推荐界面
//            RJZhuShouViewController *zhushouVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJZhuShouViewController"];
//            [self setViewControllers:@[zhushouVc]];
//            
//        }else{
//            RJAnswerViewController *answerVc = [self.storyboard instantiateViewControllerWithIdentifier:@"RJAnswerViewController"];
//            [self setViewControllers:@[answerVc]];
//        }
//    }
}
- (void)dealloc{
    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotificationLogoutSuccess object:nil];
    
}
//- (void)notificationWithLogin:(NSNotification *)sender{
//    NSLog(@"收到登录通知");
//}
@end
