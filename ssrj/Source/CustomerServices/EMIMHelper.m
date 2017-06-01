//
//  EMIMHelper.m
//  CustomerSystem-ios
//
//  Created by dhc on 15/3/28.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "EMIMHelper.h"

#import "EaseMob.h"
#import "LocalDefine.h"


static EMIMHelper *helper = nil;

@implementation EMIMHelper

@synthesize appkey = _appkey;
@synthesize cname = _cname;
@synthesize nickname = _nickname;

@synthesize username = _username;
@synthesize password = _password;

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        _appkey = [userDefaults objectForKey:kAppKey];
        if ([_appkey length] == 0) {
            _appkey = kDefaultAppKey;
            [userDefaults setObject:_appkey forKey:kAppKey];
        }
        
        _cname = [userDefaults objectForKey:kCustomerName];
        if ([_cname length] == 0) {
            _cname = kDefaultCustomerName;
            [userDefaults setObject:_cname forKey:kCustomerName];
        }
        
        _nickname = [userDefaults objectForKey:kCustomerNickname];
        if ([_nickname length] == 0) {
            _nickname = @"";
            [userDefaults setObject:_nickname forKey:kCustomerNickname];
        }
        
        _tenantId = [userDefaults objectForKey:kCustomerTenantId];
        if ([_tenantId length] == 0) {
            _tenantId = @"";
            [userDefaults setObject:_tenantId forKey:kCustomerTenantId];
        }
        
        _projectId = [userDefaults objectForKey:kCustomerProjectId];
        if ([_projectId length] == 0) {
            _projectId = @"";
            [userDefaults setObject:_projectId forKey:kCustomerProjectId];
        }
        
        _username = [userDefaults objectForKey:@"username2"];
        _password = [userDefaults objectForKey:@"password2"];
    }
    
    return self;
}

+ (instancetype)defaultHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EMIMHelper alloc] init];
    });
    
    return helper;
}

#pragma mark - login

- (void)loginEasemobSDK
{
    EaseMob *easemob = [EaseMob sharedInstance];

    
    if (![easemob.chatManager isLoggedIn] || ([_username length] == 0 || [_password length] == 0)) {
        if ([_username length] == 0 || [_password length] == 0) {
           
            if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
                return;
            }

            NSString *tempID = [[RJAccountManager sharedInstance] account].userid;
            
            tempID = [tempID stringFromMD5];

            _username = tempID;
            _password = @"mfd2016,";
            [easemob.chatManager asyncRegisterNewAccount:_username password:_password withCompletion:^(NSString *username, NSString *password, EMError *error) {
                if (!error || error.errorCode == EMErrorServerDuplicatedAccount) {
                    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                    if ([_password isEqualToString:@"123456"]) {
                        _password = @"mfd2016,";
                    }
                    [userDefaults setObject:_username forKey:@"username2"];
                    [userDefaults setObject:_password forKey:@"password2"];
                    [userDefaults synchronize];
                    [easemob.chatManager asyncLoginWithUsername:_username password:_password completion:^(NSDictionary *loginInfo, EMError *error) {
                        [[EaseMob sharedInstance].chatManager setApnsNickname:@"cc412"];
                        

                    } onQueue:nil];
                }
            } onQueue:nil];
        }
        else{
//            NSDictionary *dic =[easemob.chatManager loginWithUsername:_username password:_password error:nil];
//            NSLog(@"%@",dic);
            if ([_password isEqualToString:@"123456"]) {
                _password = @"mfd2016,";
            }
            [easemob.chatManager asyncLoginWithUsername:_username password:_password completion:^(NSDictionary *loginInfo, EMError *error) {
//                [[EaseMob sharedInstance].chatManager setApnsNickname:@"cc412"];
                
//                EMPushNotificationOptions *options = [[EaseMob sharedInstance].chatManager pushNotificationOptions];
////                NSLog(@"%ld",(long)options.displayStyle);
//                
////                options.displayStyle = ePushNotificationDisplayStyle_simpleBanner;
//                [[EaseMob sharedInstance].chatManager asyncUpdatePushOptions:options completion:^(EMPushNotificationOptions *options, EMError *error) {
////                    NSLog(@"%ld",(long)options.displayStyle);
//                } onQueue:nil];
                
            } onQueue:nil];
        }
    }
}

#pragma mark - info

- (void)setNickname:(NSString *)nickname
{
    if ([nickname length] > 0 && ![nickname isEqualToString:_nickname]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:nickname forKey:kCustomerNickname];
        _nickname = nickname;
    }
}

- (void)setCname:(NSString *)cname
{
    if ([cname length] > 0 && ![cname isEqualToString:_cname]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:cname forKey:kCustomerName];
        _cname = cname;
    }
}

- (void)setProjectId:(NSString *)projectId
{
    if ([projectId length] > 0 && ![projectId isEqualToString:_projectId]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:projectId forKey:kCustomerProjectId];
        _projectId = [projectId copy];
    }
}

- (void)setTenantId:(NSString *)tenantId
{
    if ([tenantId length] > 0 && ![tenantId isEqualToString:_tenantId]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:tenantId forKey:kCustomerTenantId];
        _tenantId = [tenantId copy];
    }
}

- (void)refreshHelperData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    _appkey = [userDefaults objectForKey:kAppKey];
    if ([_appkey length] == 0) {
        _appkey = kDefaultAppKey;
        [userDefaults setObject:_appkey forKey:kAppKey];
    }
    
    _cname = [userDefaults objectForKey:kCustomerName];
    if ([_cname length] == 0) {
        _cname = kDefaultCustomerName;
        [userDefaults setObject:_cname forKey:kCustomerName];
    }
    
    _nickname = [userDefaults objectForKey:kCustomerNickname];
    if ([_nickname length] == 0) {
        _nickname = @"";
        [userDefaults setObject:_nickname forKey:kCustomerNickname];
    }
    
    _tenantId = [userDefaults objectForKey:kCustomerTenantId];
    if ([_tenantId length] == 0) {
        _tenantId = @"";
        [userDefaults setObject:_tenantId forKey:kCustomerTenantId];
    }
    
    _projectId = [userDefaults objectForKey:kCustomerProjectId];
    if ([_projectId length] == 0) {
        _projectId = @"";
        [userDefaults setObject:_projectId forKey:kCustomerProjectId];
    }
    
    [userDefaults removeObjectForKey:@"username2"];
    [userDefaults removeObjectForKey:@"password2"];
    _username = nil;
    _password = nil;
}

@end
