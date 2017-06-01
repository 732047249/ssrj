//
//  CCAppVersionModel.h
//  ssrj
//
//  Created by CC on 16/7/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface CCAppVersionModel : JSONModel
/// 版本号
@property (strong, nonatomic) NSString *version;

/// 标识
@property (strong, nonatomic) NSString *URI;

/// 描述
@property (strong, nonatomic) NSString<Optional> *releaseNote;

/// 最低版本
@property (strong, nonatomic) NSString<Optional> *minimalRequiredVersion;
@end
