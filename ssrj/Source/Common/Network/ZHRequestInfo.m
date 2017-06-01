//
//  ZHRequestInfo.m
//  CampusVideo
//
//  Created by George on 14-7-17.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import "ZHRequestInfo.h"

@interface ZHRequestInfo ()

@end


@implementation ZHRequestInfo

- (void)dealloc
{
    DDLogDebug(@"");
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.URLString = API_BASE_URL;
    }
    return self;
}

- (NSMutableDictionary *)getParams
{
    if (!_getParams) {
        _getParams = [NSMutableDictionary dictionary];
    }
    return _getParams;
}

- (NSMutableDictionary *)postParams
{
    if (!_postParams) {
        _postParams = [NSMutableDictionary dictionary];
    }
    return _postParams;
}

- (NSMutableDictionary *)fileBodyParams
{
    if (!_fileBodyParams) {
        _fileBodyParams = [NSMutableDictionary dictionary];
    }
    return _fileBodyParams;
}

- (void)cancel
{
    [self.operation cancel];
}

//- (void)setRequestType:(ZHNetworkRequestType)requestType
//{
//    ZHAccount *ac = [[ZHAccountManager sharedInstance] account];
//    _requestType = requestType;
//    if (_requestType == kZHNetworkRequestLogin_Weibo) {
//        self.URLString = @"v1/accounts/weibo_callback";
//
//    }else if (_requestType == kZHNetWeixinGetToken){
//        self.URLString = @"https://api.weixin.qq.com/sns/oauth2/access_token";
//
//    }else if (_requestType == kZHNetGetAllSeries){
//        self.URLString = @"v1/series";
//        if (ac.token) {
//            [self.postParams setObject:ac.token forKey:@"token"];
//        }
//        
//    }
//    else if (_requestType == kZHNetworkManyLike){
//        self.URLString = @"/v1/likes";
//        if (ac.token) {
//            [self.postParams setObject:ac.token forKey:@"token"];
//        }
//        
//    }
//    //kZHNetworkMyfollowed
//    else if (_requestType == kZHNetworkRequestFollows){
//        self.URLString = @"v1/follows";
//        [self.postParams setObject:ac.token forKey:@"token"];
//        
//    }
//    //根据post 的id拿到 评论
//    else if (_requestType == kZHNetworkGetRepilse){
//        self.URLString = @"v1/replies";
//        [self.postParams setDictionary:@{@"token":ac.token,@"replyable_type":@"Post"}];
//
//    }//kZHNetworkVideos 根据ids拿到videos
//    else if (_requestType == kZHNetworkVideos){
//        self.URLString = @"/v1/videos";
//        [self.postParams setDictionary:@{@"token":ac.token,@"replyable_type":@"Post"}];
//
//    }
//    //kZHNetworkPost 发新帖
//    else if (_requestType == kZHNetworkPost){
//        //https://10.40.1.127:3000/
//        self.URLString = @"v1/posts";
//        [self.postParams setObject:ac.token forKey:@"token"];
//        
//    }
//    else if (_requestType == kZHNetworkRequestGetCrewList){
//        self.URLString = [NSString stringWithFormat:@"v1/series/%@/account_series", [self.postParams objectForKey:@"series_id"]];
//        [self.postParams setObject:ac.token forKey:@"token"];
//    }
//    else if (_requestType == kZHNetworkRequestLikeVideo) {
//        self.URLString = [NSString stringWithFormat:@"v1/videos/%@/likes", [self.postParams objectForKey:@"video_id"]];
//        [self.postParams setObject:ac.token forKey:@"token"];
//        
//    }
//    else if (_requestType == kZHNetworkDelockSeries){
//        self.URLString = @"v1/card_codes";
//        [self.postParams setObject:ac.token forKey:@"token"];
//        
//    }
//    else if (_requestType == kZHNetworkRequestLogin_Weixin){
//        self.URLString = @"v1/accounts/weixin_login";
//        
//    }else if (_requestType == kZHNetworkRequestLogin_QQ){
//        /**
//         *  正式服务器请打开下面注释
//         */
//        //self.URLString = @"http://5tv.com/api/v3/accounts/qq_callback";
//        self.URLString = @"v1/accounts/qq_callback";
//
//    } else if (_requestType == kZHNetworkRequestGetVideos) {
//        self.URLString = [NSString stringWithFormat:@"v1/series/%@/videos", [self.postParams objectForKey:@"series_id"]];
//        [self.postParams setObject:ac.token forKey:@"token"];
//        
//    } else if (_requestType == kZHNetworkRequestGetHomeVideos) {
//        self.URLString = [NSString stringWithFormat:@"/v1/videos"];
//        [self.postParams setObject:ac.token forKey:@"token"];
//    }
//    //kZHNetworkAccount_Videos
//    //播放历史
//    else if (_requestType ==kZHNetworkRequestRecordPlayVideoDate){
//        self.URLString = [NSString stringWithFormat:@"/v1/account_videos"];
//        [self.postParams setObject:ac.token forKey:@"token"];
//
//    }
//    else if (_requestType ==kZHNetworkAccount_Videos){
//        self.URLString = [NSString stringWithFormat:@"/v1/account_videos"];
//        [self.postParams setObject:ac.token forKey:@"token"];
//        
//    }
//    else if (_requestType == kZHNetworkRequestRegister) {
//        [self.postParams setObject:@"register" forKey:@"cmd"];
//        
//    } else if (_requestType == kZHNetworkRequestChangeUserInfo) {
//        self.URLString = [NSString stringWithFormat:@"/v1/accounts/%@",ac.id];
//        [self.postParams setObject:ac.token forKey:@"token"];
//
//    } else if (_requestType == kZHNetworkRequestReport) {
//        self.URLString = [NSString stringWithFormat:@"/v1/complaints"];
//        [self.postParams setObject:ac.token forKey:@"token"];
//        
//    } else if (_requestType == kZHNetworkRequestGetWhiteVersionlist) {
//        self.URLString = [NSString stringWithFormat:@"/version_reference"];
//        
//    } else if (_requestType == kZHNetworkRequestGetConfig) {
//        self.URLString = [NSString stringWithFormat:@"/v1/configures"];
//        
//    } else if (_requestType == kZHNetworkRequestLogout) {
//        if (ac && ac.token && ac.id) {
//            [self.postParams setObject:ac.token forKey:@"token"];
//            [self.postParams setObject:ac.id forKey:@"userid"];
//        }
//    } else if (_requestType == kZHNetworkRequestUploadAvatar) {
//        if (ac && ac.token && ac.id) {
//            [self.postParams setObject:ac.token forKey:@"token"];
//            [self.postParams setObject:ac.id forKey:@"userid"];
//        }
//    }
//}

@end
