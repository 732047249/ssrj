//
//  HTHelper.m
//  CityWifi
//
//  Created by George on 14-7-10.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import "HTHelper.h"
#import "UIDevice+Resolutions.h"

//获取 IP 地址

#import <sys/socket.h>
#import <sys/sockio.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <arpa/inet.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#include <sys/sysctl.h>
#include <net/if_dl.h>

@implementation HTHelper

+ (double)getCurStamp
{
    return [[NSDate date] timeIntervalSince1970];
}

+ (NSInteger)covertDoubleToInt:(double)value
{
    // 四舍五入
    NSInteger tempValue = (NSInteger)(value * 1000);
    NSInteger quotient = tempValue / 1000;
    NSInteger remainder = tempValue % 1000;
    if (remainder > 500) {
        return quotient + 1;
    } else {
        return quotient;
    }
}

+ (NSString *)getMobileCompany
{
    NSString *cellularProviderName = [UIDevice getCellularProviderName];
    if([cellularProviderName isEqualToString:@"中国联通"]){
        cellularProviderName = @"chinaunicom";
    } else if([cellularProviderName isEqualToString:@"中国移动"]){
        cellularProviderName = @"chinamobile";
    } else if([cellularProviderName isEqualToString:@"中国电信"]){
        cellularProviderName = @"chinatelecom";
    } else {
        cellularProviderName = @"none";
    }
    return cellularProviderName;
}

+ (NSArray *)getIpAddresses
{
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) return nil;
    NSMutableArray *ips = [NSMutableArray array];
    
    int BUFFERSIZE = 4096;
    struct ifconf ifc;
    char buffer[BUFFERSIZE], *ptr, lastname[IFNAMSIZ], *cptr;
    struct ifreq *ifr, ifrcopy;
    ifc.ifc_len = BUFFERSIZE;
    ifc.ifc_buf = buffer;
    if (ioctl(sockfd, SIOCGIFCONF, &ifc) >= 0){
        for (ptr = buffer; ptr < buffer + ifc.ifc_len; ){
            ifr = (struct ifreq *)ptr;
            int len = sizeof(struct sockaddr);
            if (ifr->ifr_addr.sa_len > len) {
                len = ifr->ifr_addr.sa_len;
            }
            ptr += sizeof(ifr->ifr_name) + len;
            if (ifr->ifr_addr.sa_family != AF_INET) continue;
            if ((cptr = (char *)strchr(ifr->ifr_name, ':')) != NULL) *cptr = 0;
            if (strncmp(lastname, ifr->ifr_name, IFNAMSIZ) == 0) continue;
            memcpy(lastname, ifr->ifr_name, IFNAMSIZ);
            ifrcopy = *ifr;
            ioctl(sockfd, SIOCGIFFLAGS, &ifrcopy);
            if ((ifrcopy.ifr_flags & IFF_UP) == 0) continue;
            
            NSString *ip = [NSString stringWithFormat:@"%s", inet_ntoa(((struct sockaddr_in *)&ifr->ifr_addr)->sin_addr)];
            [ips addObject:ip];
        }
    }
    close(sockfd);
    return ips;
}

+ (NSString *)getIPAddressEn0
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    //retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        //Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if (temp_addr->ifa_addr->sa_family == AF_INET) {
                //Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String: temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    //Get NSString from C String
                    address =[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    //Free memory
    freeifaddrs(interfaces);
//    NSLog(@"addrees----%@",address);
    return address;
}

+ (NSString *)macaddress
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (long long)calculateFileSizeWithURLString:(NSString *)urlString
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:urlString]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:urlString error:nil];
        NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
        long long fileSize = [fileSizeNumber longLongValue];
        return fileSize;
    }
    return 0;
}

+ (NSString *)sizeOfFolder:(NSString *)folderPath
{
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long int folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    
    //This line will give you formatted size from bytes ....
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:folderSize countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

@end
