//
//  GoodsInfoCell.m
//  ssrj
//
//  Created by MFD on 16/6/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//
#define WIDTH    [UIScreen mainScreen].bounds.size.width
#define HEIGHT    [UIScreen mainScreen].bounds.size.height;

#import "GoodsInfoCell.h"
@interface GoodsInfoCell()<UIWebViewDelegate>

@end

@implementation GoodsInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.goosInfoWebView.delegate = self;
    self.goosInfoWebView.scrollView.bounces = NO;
    self.goosInfoWebView.userInteractionEnabled = NO;
    self.goosInfoWebView.opaque = NO;
    self.goosInfoWebView.scalesPageToFit = YES;
    self.goosInfoWebView.backgroundColor = [UIColor whiteColor];
    
}


-(void)setContentStr:(NSString *)contentStr
{
    if (![_contentStr isEqualToString:contentStr]) {
        _contentStr = contentStr;
        [self.goosInfoWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:contentStr]]];
        
//        NSLog(@"开始加载网页");

    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}


#pragma mark --webDelegate
- (void) webViewDidFinishLoad:(UIWebView *)webView {
    if (self.delegate) {
//        NSLog(@"加载网页完成，刷新高度");
        [self.goosInfoWebView sizeToFit];
        __weak __typeof(&*self)weakSelf = self;
        dispatch_time_t time=dispatch_time(DISPATCH_TIME_NOW, 50*NSEC_PER_MSEC);
        dispatch_after(time, dispatch_get_main_queue(), ^{
            //执行操作
            [self.activityIndicator stopAnimating];
            if ([weakSelf.delegate respondsToSelector:@selector(cellFinishLoadedWithWebViewHeight:)]) {
                [weakSelf.delegate cellFinishLoadedWithWebViewHeight:self.goosInfoWebView.scrollView.contentSize.height];
            }
        });
        
    }
    
//    //获取webView的高度
//    // 方法一
//    CGSize fittingSize = [self.goosInfoWebView sizeThatFits:CGSizeZero];
//    self.height = fittingSize.height;
//    self.goosInfoWebView.frame = CGRectMake(0, 0, WIDTH, fittingSize.height);
//    [self.delegate cellFinishLoadedWithWebViewHeight:fittingSize.height];
    // 方法二
    //    CGFloat height = webView.scrollView.contentSize.height;
    // 方法三 （不推荐使用，当webView.scalesPageToFit = YES计算的高度不准确）
    //    CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
    
 
}

@end
