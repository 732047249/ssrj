//
//  ZHNetworkError.m
//  TestNetworkKit
//
//  Created by George on 12-10-1.
//  Copyright (c) 2012年 ZHIHE. All rights reserved.
//

#import "ZHNetworkError.h"

@implementation ZHNetworkError

+ (id)initWithErrorCode:(XGResponseErrorCodeStatus)errorCode userInfo:(NSDictionary *)userInfo {
    
    return [ZHNetworkError errorWithDomain:@"ZHNetworkError"
                                      code:errorCode
                                  userInfo:userInfo];
}

@end
