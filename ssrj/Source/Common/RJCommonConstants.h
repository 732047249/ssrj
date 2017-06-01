
//
//  RJCommonConstants.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#ifndef RJCommonConstants_h
#define RJCommonConstants_h

#define LLLocalizedString(key)  NSLocalizedStringFromTable(key, @"Localizations", @"")

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

#define IOS8_OR_LATER ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending )
#define IsIOS7 ( [[[UIDevice currentDevice] systemVersion] compare:@"8.0"] == NSOrderedAscending)

#define IOS7_OR_LATER ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define IOS6_OR_LATER ( [[[UIDevice currentDevice] systemVersion] compare:@"6.0"] != NSOrderedAscending )
#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)
#define DEVICE_IS_IPHONE4 ([[UIScreen mainScreen] bounds].size.height == 480)


#define DEVICE_IS_IPHONE6 ([[UIScreen mainScreen] bounds].size.width == 375)
#define DEVICE_IS_IPHONE6Plus ([[UIScreen mainScreen] bounds].size.width == 414)


#define GetFont(x) [UIFont systemFontOfSize:x]

#define CCLog_Frame(n)  NSLog(@"x:%.2f y:%.2f width:%.2f height:%.2f",n.frame.origin.x,n.frame.origin.y,n.frame.size.width,n.frame.size.height);

#define VERSION (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define GetBoldFont(x) [UIFont boldSystemFontOfSize:x]
#define ViewSize self.view.frame.size

#define GetImage(imageName)  [UIImage imageNamed:imageName]

#define UIColorFromRGBOne(x)  [UIColor colorWithRed:x/255.0 green:x/255.0 blue:x/255.0 alpha:1.0]
#define UIColorFromRGB(x, y, z)  [UIColor colorWithRed:x/255.0 green:y/255.0 blue:z/255.0 alpha:1.0]
#define UIColorFromRGBA(r, g, b, a) ([UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a])

#define UIColorFromHex(string) ([UIColor colorWithHexString:string])

#define DocumentPath  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define ZHAppDelegate (AppDelegate *)[[UIApplication sharedApplication] delegate]

#define HasLogin [[ZHAccountManager sharedInstance] hasAccountLogin]

// 汉字范围
#define MIN_CODE 0x4E00
#define MAX_CODE 0x9FA5

#endif /* RJCommonConstants_h */
