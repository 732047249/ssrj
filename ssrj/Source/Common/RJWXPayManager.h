//
//  RJWXPayManager.h
//  ssrj
//
//  Created by CC on 16/6/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
@protocol RJWXApiManagerDelegate <NSObject>

@optional

- (void)managerDidRecvGetMessageReq:(GetMessageFromWXReq *)request;

- (void)managerDidRecvShowMessageReq:(ShowMessageFromWXReq *)request;

- (void)managerDidRecvLaunchFromWXReq:(LaunchFromWXReq *)request;

- (void)managerDidRecvMessageResponse:(SendMessageToWXResp *)response;

- (void)managerDidRecvAuthResponse:(SendAuthResp *)response;

- (void)managerDidRecvAddCardResponse:(AddCardToWXCardPackageResp *)response;
/**
 *  支付返回后 传递给代理做进一步操作
 */
- (void)managerDidRecvPayResponse:(PayResp *)response;
@end

@interface RJWXPayManager : NSObject<WXApiDelegate>
@property (nonatomic, assign) id<RJWXApiManagerDelegate> delegate;
+ (instancetype)sharedManager;

@end
