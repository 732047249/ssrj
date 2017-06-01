//
//  GetToThemeViewController.h
//  ssrj
//
//  Created by YiDarren on 16/7/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddToNewThemeModel.h"
#import "CreatNewThemeViewController.h"
#import "RJBasicViewController.h"
#import "SMThemeModel.h"
#import "RJHomeItemTypeTwoModel.h"

@protocol GetToThemeViewControllerDelegate <NSObject>
@optional
- (void)reloadHomeViewCollocationCellDataWithModel:(RJHomeItemTypeTwoModel *)homeItemModel;
- (void)reloadCollocationViewCollocationCellDataWithModel:(RJHomeItemTypeTwoModel *)collocationModel;

@end


@interface GetToThemeViewController : RJBasicViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *themeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *themeDescribeLabel;
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

@property (weak, nonatomic) id<GetToThemeViewControllerDelegate>delegate;

@property (strong, nonatomic) RJHomeItemTypeTwoModel *homeItemTypeTwoModel;

@end



//已有主题列表
@interface ExistingThemeTableViewCell : UITableViewCell

@property (weak, nonatomic)IBOutlet UIImageView *themeImageView;
@property (weak, nonatomic) IBOutlet UILabel *themeTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *themeDescribeLabel;

@property (weak, nonatomic) IBOutlet UILabel *publishStatusLabel;


@end
