//
//  RJAliPayManager.h
//  ssrj
//
//  Created by CC on 16/6/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol RJAliApiManagerDelegate <NSObject>
- (void)managerDidRecvAliPayResponse:(NSDictionary *)response;
@end


@interface RJAliPayManager : NSObject
+ (instancetype)shareInstance;
@property (assign, nonatomic) id<RJAliApiManagerDelegate> delegate;
@end
