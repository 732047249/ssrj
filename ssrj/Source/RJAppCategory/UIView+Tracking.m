//
//  UIView+Tracking.m
//  ssrj
//
//  Created by CC on 16/12/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UIView+Tracking.h"

@implementation UIView (Tracking)
static const void *numViewKey = &numViewKey;
static const void *trackingIdKey = &trackingIdKey;
static const void *customerTreeKey = &customerTreeKey;
static const void *actionIDKey = &actionIDKey;

//- (void)setIsUseActionId:(BOOL)isUseActionId{
//    NSNumber* number = nil;
//    if (isUseActionId) {
//        number = [NSNumber numberWithBool:YES];
//    }
//    objc_setAssociatedObject(self, actionIDKey, number, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//-(BOOL)isUseActionId{
//    return [objc_getAssociatedObject(self, actionIDKey) boolValue];
//
//}
- (void)setTrackingId:(NSString *)trackingId{
    objc_setAssociatedObject(self, trackingIdKey, trackingId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}
- (NSString *)trackingId{
    return objc_getAssociatedObject(self, trackingIdKey);
    
}
//- (void)setCustomerTreeId:(NSNumber *)customerTreeId{
//    objc_setAssociatedObject(self, customerTreeKey, customerTreeId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    
//}
//- (NSNumber *)customerTreeId{
//    return objc_getAssociatedObject(self, customerTreeKey);
//    
//}

- (RJClickCountLabel *)numView{
    return objc_getAssociatedObject(self, numViewKey);
    
}
-(void)setNumView:(RJClickCountLabel *)numView{
    objc_setAssociatedObject(self, numViewKey, numView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)showLabel{
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[RJClickCountLabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    if (!self.trackingId) {
        //        [[RJAppManager sharedInstance]getCustomerIdentiferWihtView:self];
        return;
    }
    
    NSString *beginDateString = [[NSUserDefaults standardUserDefaults] objectForKey:@"HHUserDefaults_beginDateString"];
    NSString *endDateString = [[NSUserDefaults standardUserDefaults] objectForKey:@"HHUserDefaults_endDateString"];;
    if (!beginDateString.length) {
        beginDateString = [NSString stringWithFormat:@"2016-01-01"];
    }
    if (!endDateString.length) {
        [self now];
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/statistics/getcount"];
    [requestInfo.getParams addEntriesFromDictionary:@{@"tracking_id":self.trackingId}];
    
    if (beginDateString.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"beginDate": [NSString stringWithFormat:@"%@ 00:00:00",beginDateString]}];
    }
    if (endDateString.length) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"endDate": [NSString stringWithFormat:@"%@ 23:59:59",endDateString]}];
    }
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"data"]) {
            NSString *str = responseObject[@"data"];
            [self addSubview:self.numView];
            [self.numView bringToFront];
            self.numView.text = str;
            [self.numView clikeLabelSizeToFit];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
    
}
- (NSString *)now {
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"YYYY-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    //    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //用[NSDate date]可以获取系统当前时间
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}
- (void)removeLabel{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[RJClickCountLabel class]]) {
            [view removeFromSuperview];
        }
    }
    self.numView = nil;
}
@end
