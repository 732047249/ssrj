//
//  SegementScrollView.h
//  categoryDemo
//
//  Created by MFD on 16/5/24.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SegmentView.h"
@interface SegementScrollView : UIScrollView
- (instancetype)initWithFrame:(CGRect)frame
                   titleArray:(NSArray *)titleArray
             contentViewArray:(NSArray *)contentViewArray;


@property (strong,nonatomic)UIScrollView *bgScrollView;
@property (strong,nonatomic)SegmentView *segmentView;
@property (strong,nonatomic)UISearchBar *serach;
@end
