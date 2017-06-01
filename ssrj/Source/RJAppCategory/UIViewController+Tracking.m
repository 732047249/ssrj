//
//  UIViewController+Tracking.m
//  ssrj
//
//  Created by CC on 16/12/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UIViewController+Tracking.h"

@implementation UIViewController (Tracking)
+ (void)load {
    
    // 交换方法viewWillAppear：
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewWillAppear:)),class_getInstanceMethod(self, @selector(tracking_viewWillAppear:)));
    
    //交换方法viewWillDisappear：
    
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewWillDisappear:)), class_getInstanceMethod(self, @selector(tracking_viewWillDisappear:)));

}
- (void)tracking_viewWillAppear:(BOOL)animated {
    
    [self tracking_viewWillAppear:animated];
    
    NSArray *vcArray = @[@"RJBaseTabBarTableViewController",
                         @"RJBaseNavigationController",
                         @"UIPageViewController",
                         @"UICompatibilityInputViewController",
                         @"UIInputWindowController",
                         @"_UIRemoteInputViewController",
                         @"UINavigationController",
                         @"SMCreateMatchController",
                         @"HHInforGoodsController",
                         @"HHInforMatchController",
                         @"HHYiStoreCatoryViewController",
                         @"SMAllGoodsViewController",
                         @"SMMyGoodsController",
                         @"SMSourceController",
                         @"SMGoodsListViewController",
                         @"SMStuffListViewController",
                         @"HHYiStoreCatoryViewController",
                         @"RJBrandDetailPublishViewController",
                         @"RJBrandDetailGoodsViewController",
                         @"RJUserCentePublishTableViewController",
                         @"RJUserRecommendViewController",
                         @"UIAlertController"];
    for (NSString *vcName in vcArray) {
        if ([self isKindOfClass:NSClassFromString(vcName)]) {
            return;
        }
    }
    //此处添加你想统计的打点事件
    if (!self.view.trackingId.length) {
        self.view.trackingId = [NSString stringWithFormat:@"%@&viewWillAppear",NSStringFromClass([self class])];
    }
    [[RJAppManager sharedInstance]trackingWithTrackingId:self.view.trackingId];
//        NSLog(@"当前进入viewController :%@",NSStringFromClass([self class]));
    
}
- (void)tracking_viewWillDisappear:(BOOL)animated {
    
    [self tracking_viewWillDisappear:animated];
    
    //此处添加你想统计的打点事件
    
    //    NSLog(@"当前离开viewController :%@",NSStringFromClass([self class]));
    
}
@end
