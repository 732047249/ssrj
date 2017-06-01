//
//  RJZhuShouViewController.h
//  ssrj
//
//  Created by CC on 16/7/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@interface RJZhuShouViewController : RJBasicViewController
@property (strong, nonatomic) UIView * topToolBarView;
@property (strong, nonatomic) UIScrollView *tagScrollView;
@property (nonatomic,assign) NSInteger  goodNumber;
@property (nonatomic,assign) NSInteger  collactionNumber;

@end




@interface RJZhuShouSceneModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString<Optional> * checkedColorValue;
@property (strong, nonatomic) NSString<Optional> * uncheckedColorValue;
/**
 *  新增背景图
 */
@property (strong, nonatomic) NSString<Optional> * icon;

/**
 *  2.2.0 使用1：1的图 分为选中和未选中
 */
@property (nonatomic,strong) NSString<Optional> * uncheckedImage;
@property (nonatomic,strong) NSString<Optional> * checkedImage;

@end
