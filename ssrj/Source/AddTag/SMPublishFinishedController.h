//
//  SMPublishFinishedController.h
//  ssrj
//
//  Created by 夏亚峰 on 16/11/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJHomeTopicModel.h"
typedef NS_ENUM(NSInteger,HHPublishTyle) {
    HHPublishTyleMatch,
    HHPublishTyleTag,
    HHPublishTyleInformation,
};


@interface SMPublishFinishedController : UIViewController
//yes上传搭配。no 创建搭配
//@property (nonatomic,assign)BOOL isUpdataMatch;

@property (nonatomic,assign)HHPublishTyle publishType;
//搭配id
@property (nonatomic,strong)NSString *matchId;
//资讯id
@property (nonatomic,strong)NSString *informationId;
//shareModel
@property (nonatomic,strong)RJHomeTopicShareModel *shareModel;
@end
