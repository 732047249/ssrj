//
//  SMGoodsListViewController.h
//  ssrj
//
//  Created by 夏亚峰 on 17/1/6.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMGoodsListViewController : UIViewController
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSDictionary *filterDictionary;
- (void)reloadData;
@end
