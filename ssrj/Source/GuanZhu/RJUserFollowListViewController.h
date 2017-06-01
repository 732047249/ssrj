//
//  RJUserFollowListViewController.h
//  ssrj
//
//  Created by CC on 16/9/19.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
typedef NS_ENUM(NSInteger ,RJFollowListType){
    RJFollowListBrand = 0,
    RJFollowListUser,
    RJFollowListUserSelf
};
@interface RJUserFollowListViewController : RJBasicViewController
@property (strong, nonatomic) NSNumber * userId;

@property (assign, nonatomic) RJFollowListType  type;
@end
