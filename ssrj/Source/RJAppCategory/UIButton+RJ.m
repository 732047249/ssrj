//
//  UIButton+RJ.m
//  ViewTest
//
//  Created by CC on 16/12/27.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "UIButton+RJ.h"
#import <objc/runtime.h>
static const void *numViewKey = &numViewKey;

@implementation UIButton (RJ)

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
 
//    NSLog(@"\n***hook success.\n[1]action:%@\n[2]target:%@ \n[3]event:%ld", NSStringFromSelector(action), target, (long)event);
    NSString * str = [[RJAppManager sharedInstance]getCustomerIdentiferWihtView:self];
    [super sendAction:action to:target forEvent:event];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"http://101.251.217.84:8081/api/v2/statistics/post/%@",str];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error);
    }];
}
- (RJLabel *)numView{
    return objc_getAssociatedObject(self, numViewKey);

}
-(void)setNumView:(RJLabel *)numView{
    objc_setAssociatedObject(self, numViewKey, numView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(void)showLabel{
    
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[RJLabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    if (!self.RJStr) {
        [[RJAppManager sharedInstance]getCustomerIdentiferWihtView:self];
    }
    requestInfo.URLString = [NSString stringWithFormat:@"http://101.251.217.84:8081/api/v2/statistics/%@",self.RJStr];
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject[@"data"]) {
            NSNumber *str = responseObject[@"data"];
            [self addSubview:self.numView];
            [self.numView bringToFront];
            [self.numView ccSizeFit];
            self.numView.text = [str stringValue];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];

}
- (void)removeLabel{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[RJLabel class]]) {
            [view removeFromSuperview];
        }
    }
    self.numView = nil;
}
@end
