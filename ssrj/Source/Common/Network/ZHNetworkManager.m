//
//  ZHNetworkManager.m
//  CityWifi
//
//  Created by George on 14-7-10.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import "ZHNetworkManager.h"
#import "ZHALAsset.h"
@implementation ZHNetworkManager

+ (instancetype)sharedInstance
{
    static ZHNetworkManager *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[ZHNetworkManager alloc] initWithBaseURL:[NSURL URLWithString:API_BASE_URL]];
    });
    
    return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    if (self = [super initWithBaseURL:url]) {
        
        /**
         *  https
         */
        [self setSecurityPolicy:[self customSecurityPolicy]];
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"mp4",@"application/json",@"text/plain",@"image/jpeg", nil];
        /**
         *  打开https
         */
//        self.securityPolicy.allowInvalidCertificates = YES;
//
//        [self.requestSerializer setValue:@"application/vnd.5tv.v3+json" forHTTPHeaderField:@"Accept"];
//        if ([ZHAccountManager sharedInstance].account.token.length) {
//            [self.requestSerializer setValue:[ZHAccountManager sharedInstance].account.token forHTTPHeaderField:@"Authorization"];
//
//        }
        __weak ZHNetworkManager *manager = self;
        [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [[NSNotificationCenter defaultCenter]postNotificationName:NetWorkChanged object:[NSNumber numberWithInteger:status]];
            switch (status) {
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    DDLogDebug(@"WWAN");
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
    
                    DDLogDebug(@"WIFI");
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    DDLogDebug(@"Network NotReachable");
                    break;
                default:
                    break;
            }
        }];
        [manager.reachabilityManager startMonitoring];
        
        self.zhOperations = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)deleteWithRequestInfo:(ZHRequestInfo *)requestInfo
                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    __weak __typeof(&*self)weakSelf = self;
    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.operation = [self DELETE:requestInfo.URLString parameters:requestInfo.postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(operation,responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];

    }];
}

/**
 *  本项目应该没有返回数据是纯数组的了
 */
//返回是一个数组
//- (void)getListWithRequestInfo:(ZHRequestInfo *)requestInfo
//                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
//    __weak __typeof(&*self)weakSelf = self;
//    
//    [requestInfo.getParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
//    
//    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
//        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
//    requestInfo.operation = [self GET:requestInfo.URLString parameters:requestInfo.getParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSDictionary *dict = (NSDictionary *)responseObject;
//       //DDLogDebug(@"%@",dict);
//        if (dict && [dict isKindOfClass:[NSArray class]]) {
//            // 成功
//            Class modelClass = requestInfo.modelClass;
//            NSError __autoreleasing *e = nil;
//            NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[responseObject count]];
//            for (NSDictionary *info in responseObject) {
//                id obj = [[modelClass alloc] initWithDictionary:info error:&e];
//                if (obj) {
//                    [objects addObject:obj];
//                }
//                else {
//                    if (failure) {
//                        DDLogDebug(@"Create %@ model fail!!!", modelClass);
//                        failure(operation, e);
//                        return;
//                    }
//              
//                }
//            }
//            success(operation,objects);
//            
//        } else {
//            NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kLCFail], @"code", dict[@"msg"], @"msg", nil];
//            ZHNetworkError *error = [ZHNetworkError initWithErrorCode:kLCFail userInfo:errInfo];
//            failure(operation, error);
//        }
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        failure(operation, error);
//        [weakSelf serverErrorWithOperation:operation error:error];
//
//    }];
//}
- (void)getWithRequestInfoWithoutModel:(ZHRequestInfo *)requestInfo
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    __weak __typeof(&*self)weakSelf = self;
    [requestInfo.getParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.operation = [self GET:requestInfo.URLString parameters:requestInfo.getParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        
        if (dict) {
            // 成功
            success(operation, dict);
            //取值state
            if ([dict objectForKey:@"state"]) {
                NSNumber *state = [dict objectForKey:@"state"];
                if (state.intValue!= 0) {
                    [weakSelf serverBackErrorWithOperation:operation state:[dict objectForKey:@"state"] msg:[dict objectForKey:@"msg"]?:@"no msg key!"];
                    if (state.intValue == 2) {
                        [[RJAppManager sharedInstance] showTokenDisableLoginVcWithMessage:[dict objectForKey:@"msg"]];
                    }
                }
            }
        } else {
            NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kLCFail], @"code", dict[@"msg"], @"msg", nil];
            ZHNetworkError *error = [ZHNetworkError initWithErrorCode:kLCFail userInfo:errInfo];
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];
       
    }];
    
}
// http get请求
- (void)getWithRequestInfo:(ZHRequestInfo *)requestInfo
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    __weak __typeof(&*self)weakSelf = self;

    [requestInfo.getParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    requestInfo.operation = [self GET:requestInfo.URLString parameters:requestInfo.getParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if (dict) {
            //取值state
            if ([dict objectForKey:@"state"]) {
                NSNumber *state = [dict objectForKey:@"state"];
                if (state.intValue!= 0) {
                    [weakSelf serverBackErrorWithOperation:operation state:[dict objectForKey:@"state"] msg:[dict objectForKey:@"msg"]?:@"no msg key!"];
                    if (state.intValue == 2) {
                        [[RJAppManager sharedInstance] showTokenDisableLoginVcWithMessage:[dict objectForKey:@"msg"]];
                    }
                }
            }
            
            // 成功
            Class modelClass = requestInfo.modelClass;
            if (!modelClass) {
                success(operation,dict);
                return ;
            }
            ZHNetworkError *error = nil;
            RJBasicModel *model = [[modelClass alloc] initWithDictionary:dict error:&error];
            if (model == nil) {
                NSLog(@"Create %@ model fail!!!", modelClass);
                failure(operation, error);
            } else {
                success(operation, model);
            }
            
            
            
        } else {
            NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kLCFail], @"code", dict[@"msg"], @"msg", nil];
            ZHNetworkError *error = [ZHNetworkError initWithErrorCode:kLCFail userInfo:errInfo];
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];

    }];
}

- (void)postWithRequestInfo:(ZHRequestInfo *)requestInfo
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    __weak __typeof(&*self)weakSelf = self;

    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.operation = [self POST:requestInfo.URLString parameters:requestInfo.postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if (dict) {
            //取值state
            if ([dict objectForKey:@"state"]) {
                NSNumber *state = [dict objectForKey:@"state"];
                if (state.intValue!= 0) {
                    [weakSelf serverBackErrorWithOperation:operation state:[dict objectForKey:@"state"] msg:[dict objectForKey:@"msg"]?:@"no msg key!"];
                    if (state.intValue == 2) {
                        [[RJAppManager sharedInstance] showTokenDisableLoginVcWithMessage:[dict objectForKey:@"msg"]];
                    }
                }
            }
            
            // 成功
            Class modelClass = requestInfo.modelClass;
            if (!modelClass) {
                success(operation,dict);
                return;
            }
            ZHNetworkError *error = nil;
            RJBasicModel *model = [[modelClass alloc] initWithDictionary:dict error:&error];
            if (model == nil) {
                DDLogDebug(@"Create %@ model fail!!!", modelClass);
                failure(operation, error);
            } else {
                success(operation, model);
            }
            
          
            
        } else {
            NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kLCFail], @"code", nil];
            ZHNetworkError *error = [ZHNetworkError initWithErrorCode:kLCFail userInfo:errInfo];
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];

    }];
}

- (void)putWithRequestInfo:(ZHRequestInfo *)requestInfo
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    __weak __typeof(&*self)weakSelf = self;

    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.operation = [self PUT:requestInfo.URLString parameters:requestInfo.postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if (dict) {
            //取值state
            if ([dict objectForKey:@"state"]) {
                NSNumber *state = [dict objectForKey:@"state"];
                if (state.intValue!= 0) {
                    [weakSelf serverBackErrorWithOperation:operation state:[dict objectForKey:@"state"] msg:[dict objectForKey:@"msg"]?:@"no msg key!"];
                    if (state.intValue == 2) {
                        [[RJAppManager sharedInstance] showTokenDisableLoginVcWithMessage:[dict objectForKey:@"msg"]];
                    }
                }
            }
            
            // 成功
            Class modelClass = requestInfo.modelClass;
            if (!modelClass) {
                success(operation,dict);
                return;
            }
            ZHNetworkError *error = nil;
            RJBasicModel *model = [[modelClass alloc] initWithDictionary:dict error:&error];
            if (model == nil) {
                DDLogDebug(@"Create %@ model fail!!!", modelClass);
                failure(operation, error);
            } else {
                success(operation, model);
            }
            
           
            
        } else {
            NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kLCFail], @"code", nil];
            ZHNetworkError *error = [ZHNetworkError initWithErrorCode:kLCFail userInfo:errInfo];
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];

    }];
}
//常规put
- (void)putWithRequestInfoWithoutModel:(ZHRequestInfo *)requestInfo
                   success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    __weak __typeof(&*self)weakSelf = self;

    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.operation = [self PUT:requestInfo.URLString parameters:requestInfo.postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if (dict) {
            // 成功
            success(operation,dict);
            //取值state
            if ([dict objectForKey:@"state"]) {
                NSNumber *state = [dict objectForKey:@"state"];
                if (state.intValue!= 0) {
                    [weakSelf serverBackErrorWithOperation:operation state:[dict objectForKey:@"state"] msg:[dict objectForKey:@"msg"]?:@"no msg key!"];
                    if (state.intValue == 2) {
                        [[RJAppManager sharedInstance] showTokenDisableLoginVcWithMessage:[dict objectForKey:@"msg"]];
                    }
                }
            }
                return;
            }
        
         else {
            NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kLCFail], @"code", nil];
            ZHNetworkError *error = [ZHNetworkError initWithErrorCode:kLCFail userInfo:errInfo];
            failure(operation, error);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];

    }];
}
//常规post 返回原始数据 不进行JsonModel转换
- (void)postWithRequestInfoWithoutJsonModel:(ZHRequestInfo *)requestInfo
                    success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    __weak __typeof(&*self)weakSelf = self;

    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.operation = [self POST:requestInfo.URLString parameters:requestInfo.postParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if (dict) {
            // 成功
            success(operation, dict);
            //取值state
            if ([dict objectForKey:@"state"]) {
                NSNumber *state = [dict objectForKey:@"state"];
                if (state.intValue!= 0) {
                    [weakSelf serverBackErrorWithOperation:operation state:[dict objectForKey:@"state"] msg:[dict objectForKey:@"msg"]?:@"no msg key!"];
                    if (state.intValue == 2) {
                        [[RJAppManager sharedInstance] showTokenDisableLoginVcWithMessage:[dict objectForKey:@"msg"]];
                    }
                }
            }
        } else {
            NSDictionary *errInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kLCFail], @"code", nil];
            ZHNetworkError *error = [ZHNetworkError initWithErrorCode:kLCFail userInfo:errInfo];
            failure(operation, error);
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];

    }];
}
#pragma mark - 上传
- (AFHTTPRequestOperation *)uploadWithRequestInfo:(ZHRequestInfo *)requestInfo
                                   uploadProgress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))uploadProgress
                                          success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                          failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    __weak __typeof(&*self)weakSelf = self;

    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]&&![requestInfo.URLString containsString:@"token="]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    requestInfo.operation = [self POST:requestInfo.URLString parameters:requestInfo.postParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    
        NSError *error = nil;
        NSArray *keys = [requestInfo.fileBodyParams allKeys];
        for (NSString *key in keys) {
            id object = [requestInfo.fileBodyParams objectForKey:key];
            if ([object isKindOfClass:[NSString class]]) {
                BOOL append = [formData appendPartWithFileURL:[NSURL fileURLWithPath:object]
                                                         name:key
                                                     fileName:[object lastPathComponent]
                                                     mimeType:@"file"
                                                        error:&error];
                if (!append) {
                    DDLogDebug(@"append file body error: %@ key: %@ file:%@",error, key, object);
                } else {
                    DDLogDebug(@"append file body succuss");
                }
            } else if ([object isKindOfClass:[NSData class]]) {
                [formData appendPartWithFileData:object name:key fileName:@"pic.jpg" mimeType:@"file"];
                
            }else if ([object isKindOfClass:[ZHALAsset class]]){
                ZHALAsset *asset = object;
                [formData appendPartWithFileData:asset.imageData name:key fileName:[NSString stringWithFormat:@"%@.jpg",asset.name] mimeType:@"file"];
            }
            
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *dict = (NSDictionary *)responseObject;
        if ( dict) {
            
            if ([dict objectForKey:@"state"]) {
                NSNumber *state = [dict objectForKey:@"state"];
                if (state.intValue!= 0) {
                    [weakSelf serverBackErrorWithOperation:operation state:[dict objectForKey:@"state"] msg:[dict objectForKey:@"msg"]?:@"no msg key!"];
                    if (state.intValue == 2) {
                        [[RJAppManager sharedInstance] showTokenDisableLoginVcWithMessage:[dict objectForKey:@"msg"]];
                    }
                }
            }
            
            Class modelClass = requestInfo.modelClass;
            if (!modelClass) {
                success(operation,dict);
                return;
            }
            ZHNetworkError *error = nil;
            RJBasicModel *model = [[modelClass alloc] initWithDictionary:dict error:&error];
            if (model == nil) {
                DDLogDebug(@"Create %@ model fail!!!", modelClass);
                failure(operation, error);
            } else {
                success(operation, model);
            }
        }
//        Class modelClass = requestInfo.modelClass;
//        ZHNetworkError *error = nil;
//        RJBasicModel *model = [[modelClass alloc] initWithDictionary:dict error:&error];
//        if (model == nil) {
//            DDLogDebug(@"Create %@ model fail!!!", modelClass);
//            failure(operation, error);
//        } else {
//            success(operation, model);
//        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(operation, error);
        [weakSelf serverErrorWithOperation:operation error:error];

    }];
    
    if (uploadProgress) {
        [requestInfo.operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            uploadProgress(bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        }];
    }
    
    return  requestInfo.operation;
}
/**
 *  服务器没响应时候的 failure处理上报
 */
- (void)serverErrorWithOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:@{@"url":operation.request.URL.absoluteString?:@"",@"appVersion":VERSION,@"idfa":[RJAppManager sharedInstance].IDFA,@"error_code":[NSNumber numberWithInteger:error.code],@"error_desc":[error localizedDescription],@"date":[[RJAppManager sharedInstance]nowTimeFullString]}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        [dic addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token,@"userId":[RJAccountManager sharedInstance].account.id}];
    }
    if ([self.reachabilityManager isReachable]) {
        [self upLoadErrorMessageWithType:1902 dictionary:dic];
    }
}
/**
 *  服务器有返回状态  返回state的值不为0
 */
- (void)serverBackErrorWithOperation:(AFHTTPRequestOperation *)operation state:(NSNumber *)state msg:(NSString *)msg{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:@{@"url":operation.request.URL.absoluteString?:@"",@"appVersion":VERSION,@"idfa":[RJAppManager sharedInstance].IDFA,@"server_state":state,@"server_msg":msg,@"date":[[RJAppManager sharedInstance]nowTimeFullString]}];
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        [dic addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token,@"userId":[RJAccountManager sharedInstance].account.id}];
    }
    if ([self.reachabilityManager isReachable]) {
        [self upLoadErrorMessageWithType:1901 dictionary:dic];
    }
}
#pragma mark -  接口错误信息上报
- (void)upLoadErrorMessageWithType:(NSInteger)type dictionary:(NSMutableDictionary *)dictionary{
    NSMutableDictionary *dic = [dictionary copy];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    if (data) {
        NSString *jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
        NSMutableDictionary *parmaDic = [NSMutableDictionary dictionary];
        if (!jsonString) {
            return;
        }
        [parmaDic addEntriesFromDictionary:@{@"json":jsonString,@"upload_type":[NSNumber numberWithInteger:type]}];
        [[AFHTTPRequestOperationManager manager]POST:[NSString stringWithFormat:@"https://ssrj.com/b180/api/v1/statistics/upload"] parameters:parmaDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"%@",[error localizedDescription]);
        }];
        
    }

}
#pragma mark -add 6.28
#pragma mark -AFNetworking 对数据进行https ssl加密
- (AFSecurityPolicy*)customSecurityPolicy
{
    // /先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"ssrj" ofType:@"cer"];//证书的路径
    
    //    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"www.ssrj.com" ofType:@"cer"];//证书的路径
    
    
    
    //        NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];//证书的路径
    
    
//    NSLog(@"cerPath=%@", cerPath);
    
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    
//    NSLog(@"certData=%@", certData);
    
    // AFSSLPinningModeCertificate 使用证书验证模式
    //    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    
    
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    // 如果是需要验证自建证书，需要设置为YES
    securityPolicy.allowInvalidCertificates = YES;
    
    //validatesDomainName 是否需要验证域名，默认为YES；
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
    securityPolicy.validatesDomainName = YES;
    
    securityPolicy.pinnedCertificates = @[certData];
    
    return securityPolicy;
}


@end
