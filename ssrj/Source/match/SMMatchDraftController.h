//
//  SMMatchDraftController.h
//  ssrj
//
//  Created by MFD on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
@class SMMatchDraftModel;
@interface SMMatchDraftController : RJBasicViewController
@property (nonatomic,copy)void (^selectedDraftBlock)(SMMatchDraftModel *);
@end
