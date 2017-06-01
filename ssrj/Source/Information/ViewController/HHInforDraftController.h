//
//  HHInforDraftController.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "HHInforDraftModel.h"
@protocol HHInforDraftControllerDelegate <NSObject>

- (void)didSelectDraftWithModel:(HHInforDraftModel *)model;

@end

@interface HHInforDraftController : RJBasicViewController
@property (nonatomic,strong)NSString *htmlString;
@property (nonatomic,assign)id<HHInforDraftControllerDelegate> delegate;
@end
