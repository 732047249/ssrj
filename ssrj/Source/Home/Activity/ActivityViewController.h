//
//  ActivityViewController.h
//  ssrj
//
//  Created by MFD on 16/8/10.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "ActivityModel.h"

@interface ActivityViewController : RJBasicViewController
//@property (nonatomic, strong)ActivityDataModel *activityDataModel;
@property (nonatomic, strong)NSNumber *activityId;
@property (nonatomic, strong)NSNumber *isLogin;;
@property (nonatomic, strong)NSString *show_url;
@property (nonatomic, strong)NSString *share_url;
@property (strong, nonatomic)NSString * shareType;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
