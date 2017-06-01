//
//  EditPublishThemeViewController.h
//  ssrj
//
//  Created by YiDarren on 16/12/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJBasicViewController.h"

@protocol EditPublishThemeViewControllerDelegate <NSObject>
@optional
- (void)reloadEditedThemeDataWithDic:(NSDictionary *)dic;
- (void)reloadThemeDetailData;

@end


@interface EditPublishThemeViewController : RJBasicViewController
//合辑名称
@property (strong, nonatomic) NSString *themeName;
//合辑描述
@property (strong, nonatomic) NSString *themeDescribe;

@property (weak, nonatomic) IBOutlet UITextField *themeTitleText;
@property (weak, nonatomic) IBOutlet UITextField *themeDescribeText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *switchKey;
//保存开关是否打开
@property (strong ,nonatomic) NSNumber *buttonOn;

@property (strong, nonatomic) NSNumber *creatThemeID;

@property (weak, nonatomic) id<EditPublishThemeViewControllerDelegate>delegate;

@end
