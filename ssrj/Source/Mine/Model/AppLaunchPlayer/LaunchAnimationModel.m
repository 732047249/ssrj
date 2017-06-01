//
//  LaunchAnimationModel.m
//  ssrj
//
//  Created by YiDarren on 16/12/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "LaunchAnimationModel.h"

@implementation LaunchAnimationModel
/**
 *  0 代表在有效期内
 *
 *  1 代表还没开始
    
    2 代表已经超出了结束时间
 */
- (NSInteger)isInAvailableTimeWithModel{
    NSString *endTime = self.endDate;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
//    dateFormatter.locale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    NSDate *endDate = [dateFormatter dateFromString:endTime];
    
    NSString *beginTime = self.beginDate;
    NSDate *beginDate = [dateFormatter dateFromString:beginTime];
    
    NSDate *nowDate = [NSDate date];
    if ([nowDate compare:beginDate] == NSOrderedDescending && [nowDate compare:endDate] == NSOrderedAscending) {
//        NSLog(@"======有效期内");
        return 0;
    }
    if ([nowDate compare:beginDate] == NSOrderedAscending) {
//        NSLog(@"======还没开始");
        return 1;
    }
    if ([nowDate compare:endDate] == NSOrderedDescending) {
//        NSLog(@"======已经结束");
        return 2;
    }
    return NO;
}
@end
