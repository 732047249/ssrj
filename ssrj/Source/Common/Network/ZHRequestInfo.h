//
//  ZHRequestInfo.h
//  CampusVideo
//
//  Created by George on 14-7-17.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
//#import "ZHBasicModel.h"
#import "ZHNetworkConstants.h"
@interface ZHRequestInfo : NSObject

@property (nonatomic, strong) NSString            *URLString;

@property (nonatomic, strong) NSMutableDictionary *getParams;
@property (nonatomic, strong) NSMutableDictionary *postParams;
@property (nonatomic, strong) NSMutableDictionary *fileBodyParams;

@property (nonatomic, assign) Class modelClass;
@property (nonatomic, assign) ZHNetworkRequestType requestType;

@property (nonatomic, assign) AFHTTPRequestOperation *operation;

- (void)cancel;

@end
