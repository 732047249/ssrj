//
//  LaunchAnimationModel.h
//  ssrj
//
//  Created by YiDarren on 16/12/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface LaunchAnimationModel : JSONModel

@property (strong, nonatomic) NSNumber <Optional> *id;
@property (strong, nonatomic) NSString <Optional> *name;
@property (strong, nonatomic) NSString <Optional> *beginDate;
@property (strong, nonatomic) NSString <Optional> *endDate;
@property (strong, nonatomic) NSNumber <Optional> *playTime;
@property (strong, nonatomic) NSString <Optional> *showUrl;
@property (strong, nonatomic) NSNumber <Optional> *isShow;
@property (strong, nonatomic) NSNumber <Optional> *showType;


@property (nonatomic,strong) NSNumber<Optional> * forceClose;

- (NSInteger)isInAvailableTimeWithModel;
@end
