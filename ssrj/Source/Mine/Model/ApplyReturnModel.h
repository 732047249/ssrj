//
//  ApplyReturnModel.h
//  ssrj
//  申请退换货文案模型，用于显示售后服务条目
//  Created by YiDarren on 16/12/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol ApplyReasonModel <NSObject>
@end
@interface ApplyReasonModel : JSONModel

@property (strong, nonatomic) NSNumber <Optional> * reasonId;
@property (strong, nonatomic) NSString <Optional> * name;

@end



@interface ApplyReturnModel : JSONModel

@property (strong, nonatomic) NSNumber <Optional> * serviceId;
@property (strong, nonatomic) NSString <Optional> *name;
@property (strong, nonatomic) NSArray <Optional, ApplyReasonModel> *child;

@end



