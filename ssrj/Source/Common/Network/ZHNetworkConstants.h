//
//  ZHNetworkConstants.h
//  Created by CC on 14-7-10.
//  Copyright (c) 2014年 CC. All rights reserved.
//

#ifdef HT_DEBUG
//https://ssrj.com
#define API_BASE_URL @"http://192.168.1.42"
#else
#define API_BASE_URL @"https://ssrj.com"
#endif

#ifdef HT_DEBUG
#define PusherTag @"dev_serie_"
#else
#define PusherTag @"pro_serie_"

#endif

#ifdef HT_DEBUG

#define NSSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);

#else

#define NSSLog(...)

#endif
typedef enum : NSUInteger {
    kZHNetworkRequestLogin_Weibo = 0,
    kZHNetworkRequestLogin_Weixin,
    kZHNetworkRequestLogin_QQ,
    kZHNetworkRequestRegister,
    kZHNetworkRequestCheckLogin,
    kZHNetworkRequestChangePassword,
    kZHNetworkRequestChangeUserInfo,
    kZHNetworkRequestLogout,
    kZHNetworkRequestUploadAvatar,
    kZHNetworkRequestGetUserInfo,
    kZHNetworkRequestGetCategory,
    kZHNetworkRequestGetVideos,
    kZHNetworkRequestGetHomeVideos,
    kZHNetworkRequestGetVideo,
    kZHNetworkRequestGetPmList,
    kZHNetworkRequestGetNotifications,
    kZHNetworkRequestSendMessage,
    kZHNetworkRequestReadMessage,
    kZHNetworkRequestDeleteMessage,
    kZHNetworkRequestAddComment,
    kZHNetworkRequestDeleteComment,
    kZHNetworkRequestGetComments,
    kZHNetworkRequestGetUnreadMessageNumber,
} ZHNetworkRequestType;
