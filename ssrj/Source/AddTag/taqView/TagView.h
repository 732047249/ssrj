//
//  TagView.h
//  20161101
//
//  Created by MFD on 16/11/1.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagModel.h"


@interface TagView : UIView
@property (nonatomic,strong)TagModel *model;
//yes : left ; no : right
@property (nonatomic, assign) BOOL direction;
@property (nonatomic, assign) BOOL allowSwitchDirection;
@property (nonatomic, assign) BOOL allowPan;
@end
