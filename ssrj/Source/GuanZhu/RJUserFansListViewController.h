//
//  RJUserFansListViewController.h
//  ssrj
//
//  Created by CC on 16/9/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
typedef NS_ENUM(NSInteger ,RJFansListType){
    RJFansListBrand = 0,
    RJFansListUser,
    RJFansListUserSelf
};
@interface RJUserFansListViewController : RJBasicViewController
@property (strong, nonatomic) NSNumber * userId;
@property (assign, nonatomic) RJFansListType type;
@end
