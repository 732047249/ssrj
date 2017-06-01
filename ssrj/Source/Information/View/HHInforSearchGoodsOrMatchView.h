//
//  HHInforSearchGoodsOrMatchView.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HHInforSearchGoodsOrMatchViewDelegate <NSObject>
- (void)didClickSearchView;
@end
@interface HHInforSearchGoodsOrMatchView : UIView

@property (nonatomic,weak)id<HHInforSearchGoodsOrMatchViewDelegate>delegate;
@property (nonatomic,strong)NSString * placeHolder;
@end
