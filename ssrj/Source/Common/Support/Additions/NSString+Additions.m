//
//  NSString+Additions.m
//  SLCalendar
//
//  Created by George on 12-6-3.
//  Copyright (c) 2012年 Goodo. All rights reserved.
//

#import "NSString+Additions.h"
#import <CommonCrypto/CommonDigest.h>
#import <arpa/inet.h>

@implementation NSString(Additions)

- (NSString *)getReadableDateFromTimestamp {
    
	NSString *_timestamp;
    
    NSTimeInterval createdAt = [self doubleValue];
    
    // Calculate distance time string
    time_t now;
    time(&now);
    
    int distance = (int)difftime(now, createdAt);  // createdAt
    if (distance < 0) distance = 0;
    
    if (distance < 10) {
        _timestamp = @"刚刚";
    }
    else if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"秒前" : @"秒前"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"小时前" : @"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"天前" : @"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"周前" : @"周前"];
    }
    else {
        static NSDateFormatter *dateFormatter = nil;
        if (dateFormatter == nil) {
            [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehaviorDefault];
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            //            [dateFormatter setDateStyle:NSDateFormatterShortStyle];
            //            [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:createdAt];        
        _timestamp = [dateFormatter stringFromDate:date];
    }
    
    return _timestamp;
}

- (NSString *)getReadableDateFromTimestampString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *newsDateFormatted = [dateFormatter dateFromString:self];
    NSTimeInterval value = [newsDateFormatted timeIntervalSince1970];
    NSString *valueStr = [NSString stringWithFormat:@"%lf", value];
    return [valueStr getReadableDateFromTimestamp];
}

- (NSString *)convertStrToTime
{
    int totalSeconds = [self intValue];
    return [NSString convertSecondToTime:totalSeconds];
}

+ (NSString *)convertSecondToTime:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}

- (NSString *)getFileName {
    
    NSString *path = self;
    
    path = [path stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
    path = [path stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
    NSArray *parts = [path componentsSeparatedByString:@"/"];
    
    return [parts lastObject];
}

- (NSString*) sha1
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString*) sha224
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA224_DIGEST_LENGTH];
    
    CC_SHA224(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA224_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA224_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString*) sha256
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString*) sha384
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA384_DIGEST_LENGTH];
    
    CC_SHA384(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA384_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA384_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString*) sha512
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}
- (NSString *)utf2gbk {
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_2312_80);
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSString *retStr = [[NSString alloc] initWithData:data encoding:enc];
    return  retStr;   
}

- (NSString *)latinToutf8 {
    
    NSData *data = [self dataUsingEncoding:NSISOLatin1StringEncoding];
    NSString *retStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return retStr;
}

- (NSString *)stringFromMD5 {
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    
    return outputString;
}

- (NSString *)stringFromMD5_3{
    
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH+32];
    
    CC_MD5_CTX ctx;
    
    CC_MD5_Init(&ctx);
    
    CC_MD5_Update(&ctx, cStr, strlen(cStr));
    CC_MD5_Update(&ctx, cStr, strlen(cStr));
    CC_MD5_Update(&ctx, cStr, strlen(cStr));
    
    CC_MD5_Final(result, &ctx);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",result[count]];
    }
    
    return outputString;
}


- (NSData *)UTF8Data {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)stringFromUTF8
{
	NSString* encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)self, NULL, (CFStringRef)@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`\n\r", kCFStringEncodingUTF8 ));
	return encodedString;
}

- (BOOL)isUsefulString
{
    if (self && ![self isEqual:[NSNull null]] && [self length] > 0 && ![self isEqualToString:@"(null)"] && ![self isEqualToString:@" "]) {
        return YES;
    }
    return NO;
}

- (NSString *)removeHtmlItem
{
    NSString *localString= [self stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    return localString;
}

- (BOOL)isValidEmail
{
    // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/    
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isHanzi {
    
    unichar ch_chr = [self characterAtIndex:0];
    if (ch_chr >= MIN_CODE && ch_chr <= MAX_CODE) {
        
        return YES;
    }
    return NO;
}

- (BOOL)isLetter {
    
    const char *s = [self UTF8String];
    if (s[0] >= 'A' && s[0] <= 'Z') {
        return YES;
    } else if ([self isEqualToString:@"#"] || [self isEqualToString:@"$$"] || [self isEqualToString:@"$"]) {
        return YES;
    }
    return NO;
}

- (BOOL)containsString:(NSString *)aString {
    
	NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
	return range.location != NSNotFound;
}

- (BOOL)isMobileNumber {
    
    
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,2-3,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];    
    return [pred evaluateWithObject:self];
}

- (BOOL)isValidIpAddress
{
    const char *utf8 = [self UTF8String];
    // Check valid IPv4.
    struct in_addr dst;
    int success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    if (success != 1) {
        // Check valid IPv6.
        struct in6_addr dst6;
        success = inet_pton(AF_INET6, utf8, &dst6);
    }
    return (success == 1);
}

+ (NSString *)intToString:(NSInteger)value {
    
    return [NSString stringWithFormat:@"%d", value];
}

+ (NSString *)doubleToString:(double)value {
    
    return [NSString stringWithFormat:@"%lf", value];
}

- (CGFloat)getHeightWithFont:(UIFont *)font width:(CGFloat)width
{
    if (IOS7_OR_LATER) {
        CGRect stringRect = [self boundingRectWithSize:CGSizeMake(width, 0) options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:NULL];
        return stringRect.size.height;
    } else {
        CGSize stringSize = [self sizeWithFont:font constrainedToSize:CGSizeMake(width, 0)];
        return stringSize.height;
    }
}

- (CGFloat)getWithWithFont:(UIFont *)font height:(CGFloat)height
{
    if (IOS7_OR_LATER) {
        CGRect stringRect = [self boundingRectWithSize:CGSizeMake(0, height) options:(NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName: font} context:NULL];
        return stringRect.size.width;
    } else {
        CGSize stringSize = [self sizeWithFont:font constrainedToSize:CGSizeMake(0, height)];
        return stringSize.width;
    }
}
//返回一个带中间分割线的String
+ (NSMutableAttributedString *)effectivePriceWithString:(NSString *)str{
    NSDictionary *attribtDic = @{NSStrikethroughStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    return [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"¥%d",[str intValue]] attributes:attribtDic];

}


@end
