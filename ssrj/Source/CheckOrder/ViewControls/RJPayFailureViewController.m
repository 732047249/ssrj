
#import "RJPayFailureViewController.h"

@interface RJPayFailureViewController ()
@end

@implementation RJPayFailureViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"支付失败页面"];
    [TalkingData trackPageBegin:@"支付失败页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"支付失败页面"];
    [TalkingData trackPageEnd:@"支付失败页面"];

}

- (void)viewDidLoad{
    [super viewDidLoad];

    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    });
}

- (IBAction)buttonAction:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
