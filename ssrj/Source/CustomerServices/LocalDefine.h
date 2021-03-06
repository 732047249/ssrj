/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#ifndef ChatDemo_UI2_0_ChatDemoUIDefine_h
#define ChatDemo_UI2_0_ChatDemoUIDefine_h

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"
#define KNOTIFICATION_CHAT @"chat"
#define KNOTIFICATION_SETTINGCHANGE @"settingChange"
#define KNOTIFICATION_ADDMSG_TO_LIST @"addmsgtolist"

#define CHATVIEWBACKGROUNDCOLOR [UIColor colorWithRed:0.936 green:0.932 blue:0.907 alpha:1]

#define kDefaultAppKey @"1103161009115367#mfd2016ssrj"
#define kDefaultCustomerName @"mfd2016ssrj"
//#define kDefaultCustomerName @"130121"
//#define kDefaultAppKey @"culiukeji#99baoyou"
//#define kDefaultCustomerName @"culiutest3"
#define kAppKey @"CSEM_appkey"
/**
 *  因为环信的管理员账号更换 以防万一替换掉宏定义
 */
#define kCustomerName @"CSEM_name2"
#define kCustomerNickname @"CSEM_nickname2"
#define kCustomerTenantId @"CSEM_tenantId2"
#define kCustomerProjectId @"CSEM_projectId2"

#endif
