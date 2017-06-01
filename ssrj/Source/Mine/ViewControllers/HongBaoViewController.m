//
//  HongBaoViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HongBaoViewController.h"
#import "LXSegmentScrollView.h"
#import "UnusedHongBaoTableTableViewController.h"
#import "OverdueHongBaoTableViewController.h"
#import "UsedHongBaoTableViewController.h"
#import "UseRuleForRedbagViewController.h"

@interface HongBaoViewController ()

@property (strong, nonatomic) UnusedHongBaoTableTableViewController *unusedVC;
@property (strong, nonatomic) OverdueHongBaoTableViewController *overdueVC;
@property (strong, nonatomic) UsedHongBaoTableViewController *usedVC;


@end

@implementation HongBaoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"现金券";
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.hidden = YES;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"使用说明" style:UIBarButtonItemStylePlain target:self action:@selector(rightButtonClicked)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 3; i++) {
        if (i==0) {
            _unusedVC = [[UnusedHongBaoTableTableViewController alloc]init];
            [array addObject:_unusedVC.view];
        }
        if (i==1) {
            _overdueVC = [[OverdueHongBaoTableViewController alloc] init];
            [array addObject:_overdueVC.view];
        }
        if (i==2) {
            _usedVC = [[UsedHongBaoTableViewController alloc] init];
            [array addObject:_usedVC.view];
        }
    }
    LXSegmentScrollView *scView = [[LXSegmentScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) titleArray:@[@"未使用",@"已过期",@"已使用"] contentViewArray:array];
    [self.view addSubview:scView];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

}


#pragma mark -使用说明button 点击事件
- (void)rightButtonClicked {
    
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    UseRuleForRedbagViewController *useRuleVC = [[UseRuleForRedbagViewController alloc] init];
    
    [self.navigationController pushViewController:useRuleVC animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end






