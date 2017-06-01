//
//  SMAllGoodsHeaderView.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMAllGoodsSearchViewDelegate <NSObject>

- (void)didClickSearchView;
- (void)didClickCamara;
@end

@interface SMAllGoodsSearchView : UIView
@property (nonatomic,weak)id<SMAllGoodsSearchViewDelegate>delegate;
@end
