//
//  ReportStatisticalDataModel.h
//  ssrj
//
//  Created by YiDarren on 16/12/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ReportStatisticalDataModel : JSONModel


//当前页面（控制器）的名称
@property (strong, nonatomic) NSString <Optional> * currentVCName;
//跳转后的页面（控制器）的名称
@property (strong, nonatomic) NSString <Optional> * NextVCName;
//点击进入下级UI的入口类型    单品、合辑、搭配、资讯（列表）
@property (strong, nonatomic) NSNumber <Optional> * entranceType;
//点击进入下级UI的入口类型ID
@property (strong, nonatomic) NSNumber <Optional> * entranceTypeId;
//点击的单品、合辑、搭配、资讯（列表）的唯一标识ID
@property (strong, nonatomic) NSNumber <Optional> * tapId;



@end
