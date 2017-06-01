//
//  HHTopicDetailViewController.h
//  ssrj
//
//  Created by yfxiari on 2017/3/20.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "RJHomeTopicModel.h"
typedef void(^zanBackBlock)(NSInteger);

@interface HHTopicDetailViewController : RJBasicViewController

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
