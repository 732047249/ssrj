//
//  RJTopicDetailViewController.h
//  ssrj
//
//  Created by YiDarren on 16/10/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
#import "RJHomeTopicModel.h"
typedef void(^zanBackBlock)(NSInteger);

@interface RJTopicDetailViewController : RJBasicViewController
@property (nonatomic, strong)NSNumber *isThumbUp;
@property (nonatomic, strong) NSNumber *informId;
@property (strong, nonatomic) RJHomeTopicShareModel * shareModel;
@property (nonatomic, copy)zanBackBlock zanBlock;
@property (nonatomic, assign) BOOL isFromInformPublished;
/**
 * 3.0.1 新增发布列表cell来源类型
 */
@property (strong, nonatomic) NSNumber <Optional> *event;


@end
