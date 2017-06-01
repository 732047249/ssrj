//
//  RJPushWebViewController.h
//  ssrj
//
//  Created by CC on 16/12/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
/**
 *  这个WebView 是从其他WebView跳转过来的
    只传过来一个ID 根据ID去请求所有信息
 */
@interface RJPushWebViewController : RJBasicViewController
@property (nonatomic,strong) NSNumber * activityId;
@end
