//
//  TagsView.m
//  ssrj
//
//  Created by MFD on 16/7/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "TagsView.h"
#import "ThemeDetailVC.h"

@implementation TagsView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)setTagsFrames:(TagsFrames *)tagsFrames{
    _tagsFrames = tagsFrames;
    for (UIView * subView in self.subviews) {
        [subView removeFromSuperview];
    }
    NSString *str = [[RJAppManager sharedInstance]currentViewControllerName];
    for (NSInteger i = 0; i < tagsFrames.titlesArray.count; i++) {
        UIButton *tagsBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [tagsBtn setTitle:tagsFrames.titlesArray[i] forState:UIControlStateNormal];
        [tagsBtn setTitleColor:[UIColor colorWithHexString:@"5d32b5"] forState:UIControlStateNormal];
        [tagsBtn setBackgroundColor:[UIColor colorWithHexString:@"f2f2f2"]];
        tagsBtn.titleLabel.font = Tags_Font;
        tagsBtn.layer.cornerRadius = 15;
        tagsBtn.layer.masksToBounds = YES;
      
        tagsBtn.frame = CGRectFromString(tagsFrames.tagsFrames[i]);
        
        tagsBtn.tag = i;
        [tagsBtn addTarget:self action:@selector(clickTag:) forControlEvents:UIControlEventTouchUpInside];
        /**
         *  TrackingId
         */
        if (i+1 <= tagsFrames.themeIdsArray.count) {
            NSString *idStr = tagsFrames.themeIdsArray[i];
            tagsBtn.trackingId = [NSString stringWithFormat:@"%@&tagsBtn&id=%@",str,idStr];
        }
        [self addSubview:tagsBtn];
    }
}


- (UIViewController *)viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

//点击按钮标签跳转到合辑页面
- (void)clickTag:(UIButton *)btn{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    ThemeDetailVC *vc = [sb instantiateViewControllerWithIdentifier:@"ThemeDetailVC"];
    if (btn.tag + 1 > self.tagsFrames.themeIdsArray.count) {
        return;
    }
    NSNumber *num = self.tagsFrames.themeIdsArray[btn.tag];
//    vc.parameterDictionary = @{@"thememItemId":self.tagsFrames.themeIdsArray[btn.tag]};
    vc.themeItemId = num;
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

@end
