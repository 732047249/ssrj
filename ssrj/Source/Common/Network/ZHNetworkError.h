//
//  ZHNetworkError.h
//  TestNetworkKit
//
//  Created by George on 12-10-1.
//  Copyright (c) 2012年 ZHIHE. All rights reserved.
//

#import <Foundation/Foundation.h>

// 请求返回状态
typedef enum {
    
    /************************************* 客户端 *************************************/
    
    // 失败
    kLCFail = 400,
    // 超时
    kLCTimeOut = 401,
    // 无网络
    kLCNetworkNotReachable = 402,
    // 未找到
    kLCNotFound = 404,
    // 存储数据失败
    kLCStoreDataFail = 403,
    
    /************************************* 服务端 *************************************/
    
    // 网络故障或其他原因导致的，解释包错误
    kResponseCodeUnpack = -2,
    // 错误没定义，对应的错误文字描述不固定
    kResponseCodeNoDefine = -1,
    // OK
    kResponseCodeOK = 0,
    // 数据没变更 该类返回，限于在请求端缓存数据，与服务器端需要比较版本号的类型请求与返回
    kResponseCodeNoUpdateData = 1,
    // 批量处理动作中，服务器部分处理正确，部分出现错误
    kResponseCodeServerProcessNotComplete = 2,
    // 用户已存在
    kResponseCodeUserAlreadyExist = -21001,
    // 手机格式不正确
    kResponseCodeIncorrectPhoneFormat = -21002,
    // 校验码不正确
    kResponseCodeIncorrectChecksum = -21003,
    // 校验码已过期
    kResponseCodeChecksumExpired = -21004,
    // 手机不存在
    kResponseCodePhoneNotExist = -21005,
    // 用户密码不正确
    kResponseCodeIncorrectUserPassword = -21006,
    // passport不正确
    kResponseCodeIncorrectPassport = -24001,
    // passport已过期
    kResponseCodePassportExpired = -24002,
    // 验证码不正确
    kResponseCodeIncorrectVerificationCode  = -22002,
    
} XGResponseErrorCodeStatus;

@interface ZHNetworkError : NSError

+ (id)initWithErrorCode:(XGResponseErrorCodeStatus)errorCode userInfo:(NSDictionary *)userInfo;

@end
