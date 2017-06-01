//
//  HTLogFormatter.m
//  CityWifi
//
//  Created by George on 12-11-15.
//  Copyright (c) 2012年 ZHIHE. All rights reserved.
//

#import "HTLogFormatter.h"

@implementation HTLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString *timestampstr = nil;
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
    timestampstr = [formater stringFromDate:logMessage->timestamp];
    
	return [NSString stringWithFormat:@"%@ %@ line:%d (%s) %@",timestampstr, [logMessage fileName], logMessage->lineNumber, logMessage->function, logMessage->logMsg];
}

@end
