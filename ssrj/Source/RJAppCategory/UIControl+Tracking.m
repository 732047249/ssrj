//
//  UIControl+Tracking.m
//  ssrj
//
//  Created by CC on 16/12/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UIControl+Tracking.h"
#import "RJTrackingModel.h"
#import "LKDBHelper.h"
#import "RJSqlitManager.h"
@implementation UIControl (Tracking)
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(sendAction:to:forEvent:)), class_getInstanceMethod(self, @selector(tracking_sendAction:to:forEvent:)));
        //    method_exchangeImplementations(class_getInstanceMethod(self, @selector(sendActionsForControlEvents:)), class_getInstanceMethod(self, @selector(tracking_sendActionsForControlEvents:)));
    });
}
- (void)tracking_sendActionsForControlEvents:(UIControlEvents)controlEvents{

    if (((controlEvents == UIControlEventValueChanged) | (controlEvents == UIControlEventTouchUpInside)) ||controlEvents == 1073741824) {
        
//        NSString * str = [[RJAppManager sharedInstance]getCustomerIdentiferWihtView:self];
//        NSLog(@"%@",str);
//        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
//        requestInfo.URLString = [NSString stringWithFormat:@"http://101.251.217.84:8081/api/v2/statistics/post/%@",str];
//        
//        [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            //        NSLog(@"%@",responseObject);
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            //        NSLog(@"%@",error);
//        }];
        
    }
    [self tracking_sendActionsForControlEvents:controlEvents];


}
- (void)tracking_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
//    NSString * str = [[RJAppManager sharedInstance]getCustomerIdentiferWihtView:self];
//    NSLog(@"%@",str);
//    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
//    requestInfo.URLString = [NSString stringWithFormat:@"http://101.251.217.84:8081/api/v2/statistics/post/%@",str];
//    
//    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        //        NSLog(@"%@",responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        //        NSLog(@"%@",error);
//    }];
    
    [self tracking_sendAction:action to:target forEvent:event];
//    此处添加你想统计的打点事件
    
//    NSString *string = [NSString stringWithFormat:@"%@_%@_%ld",NSStringFromClass([target class]),NSStringFromSelector(action),self.tag];
//    NSLog(@"=================%@",string);
    
    if ([NSStringFromClass([target class]) isEqualToString:@"TDAAUIControlBinding"]||[NSStringFromClass([target class]) isEqualToString:@"MPVideoPlaybackOverlayView"]||[NSStringFromClass([target class]) isEqualToString:@"AVFullScreenPlaybackControlsViewController"]) {
        return;
    }
    
    if ([NSStringFromClass([target class]) isEqualToString:@"CYLTabBar"]) {
        if ([NSStringFromSelector(action) isEqualToString:@"_buttonUp:"]) {
            if (self.trackingId) {
                [[RJAppManager sharedInstance]trackingWithTrackingId:self.trackingId];
            }
        }
        return;
    }
    if (self.trackingId) {
        if ([NSStringFromClass([target class]) isEqualToString:@"HyPopMenuView"]) {
            return;
        }
        if ([NSStringFromClass([target class]) isEqualToString:@"CCButton"]) {
            return;
        }
        [[RJAppManager sharedInstance]trackingWithTrackingId:self.trackingId];

        return;
    }

//    if (self.isUseActionId) {
//        NSString *string = [NSString stringWithFormat:@"%@_%@_%ld",NSStringFromClass([target class]),NSStringFromSelector(action),self.tag];
//        self.trackingId = string;
//        //            NSLog(@"你现在点击的是%@",string);
//        [[RJAppManager sharedInstance]trackingWithTrackingId:string];
//    }
//    NSMutableArray* array = [RJTrackingModel searchWithWhere:nil orderBy:nil offset:0 count:100];
//    NSLog(@"%@",array);

}

@end
