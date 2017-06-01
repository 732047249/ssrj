//
//  NSString+Additions.h
//  SLCalendar
//
//  Created by George on 12-6-3.
//  Copyright (c) 2012年 Goodo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Additions)

- (NSString *)getReadableDateFromTimestamp;
- (NSString *)getReadableDateFromTimestampString;
- (NSString *)convertStrToTime;
+ (NSString *)convertSecondToTime:(int)totalSeconds;

- (NSString *)getFileName;
- (NSString *)utf2gbk;
- (NSString *)stringFromMD5;
- (NSString *)stringFromMD5_3;
- (NSString *)stringFromUTF8;
- (NSString *)latinToutf8;
- (NSData *)UTF8Data;
- (BOOL)isUsefulString;
- (BOOL)isValidEmail;
- (BOOL)containsString:(NSString *)aString;
- (BOOL)isHanzi;
- (BOOL)isLetter;

// 检测字符串是否是手机号码
- (BOOL)isMobileNumber;

- (BOOL)isValidIpAddress;

+ (NSString *)intToString:(NSInteger)value;
+ (NSString *)doubleToString:(double)value;

//返回一个带中间分割线的String

+ (NSMutableAttributedString *)effectivePriceWithString:(NSString *)str;

- (CGFloat)getHeightWithFont:(UIFont *)font width:(CGFloat)width;
- (CGFloat)getWithWithFont:(UIFont *)font height:(CGFloat)heigth;

-(NSString *) sha1;
-(NSString *) sha224;
-(NSString *) sha256;
-(NSString *) sha384;
-(NSString *) sha512;
@end
