//
//  RJUserCentePublishTableViewController.h
//  ssrj
//
//  Created by CC on 16/9/21.
//  Copyright (c) 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>



@class RJUserCenteRootViewController;
@interface RJUserCentePublishTableViewController : UITableViewController
@property (assign, nonatomic) RJUserCenteRootViewController * fatherViewController;
@property (strong, nonatomic) NSNumber * userId;

//add 12.22 记录是否进入了用户自己的用户中心
@property (assign, nonatomic) BOOL isSelf;




@end
