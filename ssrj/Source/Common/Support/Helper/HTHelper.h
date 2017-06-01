//
//  HTHelper.h
//  CityWifi
//
//  Created by George on 14-7-10.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTHelper : NSObject

+ (double)getCurStamp;

+ (NSInteger)covertDoubleToInt:(double)value;
+ (NSString *)getMobileCompany;

+ (NSArray *)getIpAddresses;
+ (NSString *)getIPAddressEn0;
+ (NSString *)macaddress;

+ (long long)calculateFileSizeWithURLString:(NSString *)urlString;

+ (NSString *)sizeOfFolder:(NSString *)folderPath;

@end
