
#import "RJBaseNavigationController.h"

@interface RJBaseNavigationController ()
@end

@implementation RJBaseNavigationController

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)viewDidLoad{
    [super viewDidLoad];
    self.navigationBar.translucent = NO;

}


@end
