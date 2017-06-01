//
//  RJTrackingModel.h
//  ssrj
//
//  Created by CC on 17/1/11.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
@protocol RJTrackingModel <NSObject>

@end
/**
 *  原生统计Model
 */
@interface RJTrackingModel : JSONModel
@property (nonatomic, strong) NSString * trackingId;
@property (nonatomic,strong) NSString * date;
@property (nonatomic, assign) NSInteger id;
@end


/**
 *  方便转换json串
 */
@interface RJTrackingArrayModel : JSONModel
@property (nonatomic,strong) NSArray<RJTrackingModel> *dataArray;
@end



/**
 *  转为json传 上传失败保存在表里面
 */
@interface RJTrackingJsonStringModel : JSONModel
@property (nonatomic,strong) NSString * jsonString;
@property (nonatomic, assign) NSInteger id;

@end