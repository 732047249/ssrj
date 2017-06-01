//
//  CCFirstInView.h
//  ssrj
//
//  Created by CC on 17/3/24.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCFirstInView : UIView
@property (nonatomic,strong) NSMutableArray * imagesNames;
@property (nonatomic,strong) NSString * localIdentify;
- (instancetype)initWithImageArray:(NSMutableArray *)imagesNames localIdentify:(NSString *)localIdentify;
- (void)show;
- (void)close;
@end
