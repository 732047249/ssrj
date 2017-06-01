//
//  CreatNewThemeViewController.h
//  ssrj
//
//  Created by YiDarren on 16/7/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJBasicViewController.h"

@protocol CreatNewThemeViewControllerDelegate <NSObject>

- (void)reloadExitedThemeDataWithDic:(NSDictionary *)dic;

@end


@interface CreatNewThemeViewController : RJBasicViewController

@property (strong, nonatomic) NSString *themeName;


@property (weak, nonatomic) IBOutlet UITextField *themeTitleText;
@property (weak, nonatomic) IBOutlet UITextField *themeDescribeText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UISwitch *switchKey;
//保存开关是否打开
@property (strong ,nonatomic) NSNumber *buttonOn;

@property (strong, nonatomic) NSNumber *creatThemeID;

@property (weak, nonatomic) id<CreatNewThemeViewControllerDelegate>delegate;

//用于ugc上传搭配和创建搭配
@property (nonatomic, assign) BOOL isFromCreateCollection;

@end
