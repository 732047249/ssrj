//
//  AppConfig.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#ifndef AppConfig_h
#define AppConfig_h

/**
 *  默认开启Debug模式 发布时要注释掉
 */
//#define HT_DEBUG
#define APP_ID @"1035505672"

// 友盟API key
#define UmengAppkey @"57305e6867e58e2e0c000ade"

// weibo app key
//#define kAppKey_weibo        @"70483929"
//#define kRedirectURI_weibo    @"http://www.sina.com"
#define kAppKey_weibo        @"2866004777"
#define kRedirectURI_weibo    @"http://ssrj.com/callback"
#define kAppSecret_weibo    @"2d674c28080ec8e9199e744deb3c1fc9"

#define ssrjWebUrl @"http://ssrj.com"

//// weichat app key
#define kAppKey_weixin        @"wx71d644fc50bc3765"
#define kAppSecret_weixin    @"e21c3a1db78495da17462f39c90d52f3"
//// qq app key
#define kAppId_qq        @"1104792404"
#define kAppKey_qq    @"EMn9chKPz8n2tLWT"

#define NetWorkChanged          @"NetWorkChanged"


#define AddressKey @"LocalAddressKey"
//#define kAppKey_qq        @"801550723"

// 测试账号
//#define kTRIAL_ACCOUNT_NAME @"demo1234"
//#define kTRIAL_ACCOUNT_PWD @"123456"


//保存用户个人标识符，用于搜索 9.30
#define SearchIdentifierKey         @"SearchIdentifierKey"


#endif /* AppConfig_h */
