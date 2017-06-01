//
//  HHLongPressedImageView.m
//  ssrj
//
//  Created by yf on 2017/2/22.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "HHLongPressedImageView.h"
#import "RJAppManager.h"
#import "CartOrBuyViewController.h"
@interface HHLongPressedImageView ()<CartOrBuyViewControllerDelegate>
@property (nonatomic, strong) UIViewController *currentVc;
@end

@implementation HHLongPressedImageView

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userInteractionEnabled = YES;
    UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressGesture:)];
    [self addGestureRecognizer:longpressGesture];
}
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longpressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longpressGesture:)];
        [self addGestureRecognizer:longpressGesture];
    }
    return self;
}
- (void)longpressGesture:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if (!self.goodsModel) {
            return;
        }
        self.currentVc = [[RJAppManager sharedInstance] currentViewController];
        
        if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self.currentVc presentViewController:loginNav animated:YES completion:^{
                
            }];
            return;
        }
        
        NSNumber *goodId = [NSNumber numberWithInt:[self.goodsModel.goodId intValue]];
        if (self.goodsModel.detail) {
            
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
            CartOrBuyViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CartOrBuyViewController"];
            vc.cartOrBuy = 88;
            vc.delegate = self;
            vc.fromGoodsId = goodId;
            
            vc.datamodel = self.goodsModel.detail;
            vc.detailView.backgroundColor = [UIColor colorWithRed:1.000 green:0.988 blue:0.960 alpha:1.000];
            [vc addViewToKeyWindow];
            for (UIViewController *vc in self.currentVc.childViewControllers) {
                if ([vc isKindOfClass:[CartOrBuyViewController class]]) {
                    [vc removeFromParentViewController];
                }
            }
            [self.currentVc addChildViewController:vc];
        }
    }
}
-(void)reloadGoodsDetailCloseCoverWithisReload:(BOOL)isReload {
    if ([self.currentVc respondsToSelector:@selector(getNetData)]) {
        [self.currentVc performSelector:@selector(getNetData)];
    }
}
@end
