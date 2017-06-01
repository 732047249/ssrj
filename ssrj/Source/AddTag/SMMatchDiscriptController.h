//
//  SMMatchDiscriptController.h
//  ssrj
//
//  Created by MFD on 16/11/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "TagView.h"

@interface SMMatchDiscriptController : RJBasicViewController
@property (nonatomic,assign)BOOL isAddTag;
@property (nonatomic,copy)void (^block)(TagModel *);
@end
