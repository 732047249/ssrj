//
//  RJWebViewController.h
//  ssrj
//
//  Created by CC on 16/7/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "RJHomeTopicModel.h"
@interface RJWebViewController : RJBasicViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) NSString * urlStr;
@property (strong, nonatomic) RJShareBasicModel * shareModel;
@property (assign, nonatomic) BOOL  isPushIn;
@property (nonatomic,strong) NSNumber * webId;
@end
