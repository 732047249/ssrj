//
//  HTWIFIRequestManager.h
//  CityWifi
//
//  Created by George on 14-7-10.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#define NetIsWiFi [ZHNetworkManager sharedInstance].reachabilityManager.reachableViaWiFi
#define NetIsWWAN [ZHNetworkManager sharedInstance].reachabilityManager.reachableViaWWAN
#define NetIsReachable [ZHNetworkManager sharedInstance].reachabilityManager.reachable
@interface ZHNetworkManager : AFHTTPRequestOperationManager

// 用来存储operation, key是url
@property (nonatomic, strong) NSMutableDictionary *zhOperations;

+ (instancetype)sharedInstance;

- (void)deleteWithRequestInfo:(ZHRequestInfo *)requestInfo
                      success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
/**
 *  本项目应该没有返回数据是一个纯数组的 都包含msg data state
 */
//- (void)getListWithRequestInfo:(ZHRequestInfo *)requestInfo
//                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getWithRequestInfoWithoutModel:(ZHRequestInfo *)requestInfo
                               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)getWithRequestInfo:(ZHRequestInfo *)requestInfo
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)postWithRequestInfo:(ZHRequestInfo *)requestInfo
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)putWithRequestInfo:(ZHRequestInfo *)requestInfo
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)putWithRequestInfoWithoutModel:(ZHRequestInfo *)requestInfo
                               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (void)postWithRequestInfoWithoutJsonModel:(ZHRequestInfo *)requestInfo
                                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
- (AFHTTPRequestOperation *)uploadWithRequestInfo:(ZHRequestInfo *)requestInfo
                                   uploadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
    
@end
