//
//  RJSqlitManager.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LKDBHelper.h"
@interface RJSqlitManager : NSObject
+ (instancetype)sharedInstance;

@property (nonatomic,strong) LKDBHelper * dbHelper;
- (void)openDBWithPath:(NSString *)dbPath;
- (void)closeDB;
@end
