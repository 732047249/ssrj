//
//  HHYiStoreCatoryViewController.h
//  ssrj
//
//  Created by 夏亚峰 on 17/2/9.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@interface HHYiStoreCatoryViewController : RJBasicViewController

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSDictionary *filterDictionary;
- (void)reloadData;
- (void)chooseAll;
- (void)clearAll;
- (NSArray *)choosedGoods;
@end
