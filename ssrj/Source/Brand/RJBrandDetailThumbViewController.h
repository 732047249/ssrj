//
//  RJBrandDetailThumbViewController.h
//  ssrj
//
//  Created by CC on 16/9/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
@class RJBrandDetailRootViewController;

@interface RJBrandDetailThumbViewController : UITableViewController
@property (assign, nonatomic) RJBrandDetailRootViewController * faterViewController;
@property (strong, nonatomic) NSNumber * brandId;

@end
