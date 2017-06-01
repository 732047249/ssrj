//
//  UICollectionViewCell+Tracking.m
//  ssrj
//
//  Created by CC on 16/12/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "UICollectionViewCell+Tracking.h"

@implementation UICollectionViewCell (Tracking)
+(void)load{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(prepareForReuse)), class_getInstanceMethod(self, @selector(myPrepareForReuse)));

}
- (void)myPrepareForReuse{
  
    if ([RJAppManager sharedInstance].trackingDebug) {
        for (UIView *subView in self.subviews) {
            if ([subView isKindOfClass:[RJClickCountLabel class]]) {
                [subView removeFromSuperview];
            }
        }
    }
    [self myPrepareForReuse];
}
@end
