//
//  EditCollocationViewController.h
//  ssrj
//
//  Created by YiDarren on 16/12/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddToNewThemeModel.h"
#import "CreatNewThemeViewController.h"
#import "RJBasicViewController.h"
#import "SMThemeModel.h"

@class RJHomeItemTypeTwoModel;
@protocol EditCollocationViewControllerDelegate <NSObject>
//刷新我的发布之搭配cell
@optional
- (void)reloadEditedCollocationDataWithCollocationModel:(RJHomeItemTypeTwoModel *)model;
@end

@interface EditCollocationViewController : RJBasicViewController<UITableViewDataSource, UITableViewDelegate>

/**
 *  3.0.0 搭配编辑功能 重用添加到新合辑的UI
 */
@property (strong, nonatomic) NSString *collocationTitStr;
@property (strong, nonatomic) NSString *collocationDesStr;
//3.1.0 用于用户中心搭配cell代理刷新用的传值数据
@property (strong, nonatomic) RJHomeItemTypeTwoModel *homeItemTypeTwoModel;


@property (weak, nonatomic) IBOutlet UITextField *themeTitleText;
@property (weak, nonatomic) IBOutlet UITextField *themeDescribeText;
@property (weak, nonatomic) IBOutlet UIImageView *themeImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LineHeight;

@property (weak, nonatomic) IBOutlet UIButton *searchThemeButton;
@property (weak, nonatomic) IBOutlet UIView *searchBgView;
//加入合辑背景view
@property (weak, nonatomic) IBOutlet UIView *addThemeBgView;
//tableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//主题对应的ID，用以在上个UI传值collectionID，以便请求网络数据时使用该字段
@property (strong, nonatomic) NSNumber *collectionID;
//网络请求参数（URL内的拼接字段集）
@property (strong, nonatomic) NSDictionary *parameterDictionary;
//接收大json数据
@property (strong, nonatomic) SMThemeModel *themeDataModel;

@property (strong, nonatomic) AddToNewThemeModel *dataModel;
//已有主题arr
@property (strong, nonatomic) NSMutableArray *themeMutableArr;

@property (assign, nonatomic) int pageNumber;

@property (assign, nonatomic) int pageSize;

@property (strong, nonatomic) id<EditCollocationViewControllerDelegate>delegate;

@end

