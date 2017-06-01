//
//  SMPublishFinishedController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/11/22.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMPublishFinishedController.h"
#import "SMCreateMatchController.h"
#import "SMAddTagViewController.h"
#import "CollectionsViewController.h"
#import "HHInformationViewController.h"
#import "HHTopicDetailViewController.h"
@interface SMPublishFinishedController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *seeMatchBtn;
@property (weak, nonatomic) IBOutlet UIButton *continueMatchBtn;
@property (weak, nonatomic) IBOutlet UILabel *finishLabel;

@end

@implementation SMPublishFinishedController
{
    BOOL navBarHiddenState;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self forbiddenSideBack];
    
    switch (self.publishType) {
        case HHPublishTyleMatch:
            [MobClick beginLogPageView:@"创建搭配-发布完成页面"];
            [TalkingData trackPageBegin:@"创建搭配-发布完成页面"];
            break;
        case HHPublishTyleTag:
            [MobClick beginLogPageView:@"上传搭配-发布完成页面"];
            [TalkingData trackPageBegin:@"上传搭配-发布完成页面"];
            break;
        case HHPublishTyleInformation:
            [MobClick beginLogPageView:@"上传资讯-发布完成页面"];
            [TalkingData trackPageBegin:@"上传资讯-发布完成页面"];
            break;
        default:
            break;
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
    [self resetSideBack];
    
    switch (self.publishType) {
        case HHPublishTyleMatch:
            [MobClick endLogPageView:@"创建搭配-发布完成页面"];
            [TalkingData trackPageEnd:@"创建搭配-发布完成页面"];
            break;
        case HHPublishTyleTag:
            [MobClick endLogPageView:@"上传搭配-发布完成页面"];
            [TalkingData trackPageEnd:@"上传搭配-发布完成页面"];
            break;
        case HHPublishTyleInformation:
            [MobClick endLogPageView:@"上传资讯-发布完成页面"];
            [TalkingData trackPageEnd:@"上传资讯-发布完成页面"];
            break;
        default:
            break;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.publishType == HHPublishTyleMatch) {
        self.title = @"发布我的搭配";
        self.finishLabel.text = @"搭配发布成功";
    }else if (self.publishType == HHPublishTyleTag){
        self.title = @"上传我的搭配";
        self.finishLabel.text = @"搭配发布成功";
    }else {
        self.title = @"发布我的资讯";
        self.finishLabel.text = @"资讯发布成功";
        [_seeMatchBtn setTitle:@"查看资讯" forState:UIControlStateNormal];
    }
    _seeMatchBtn.layer.cornerRadius = 8;
    [_seeMatchBtn setTitleColor:[UIColor colorWithHexString:@"#5d32b8"] forState:UIControlStateNormal];
    _continueMatchBtn.layer.cornerRadius = 8;
    _seeMatchBtn.layer.borderColor = [[UIColor colorWithHexString:@"#5d32b8"] CGColor];
    _seeMatchBtn.layer.borderWidth = 1.5;
    _continueMatchBtn.backgroundColor = [UIColor colorWithHexString:@"#5d32b8"];
    
    UIButton *backItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
    [backItem addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [backItem setTitle:@"回首页" forState:UIControlStateNormal];
    backItem.titleLabel.font = [UIFont systemFontOfSize:15];
    [backItem setImage:GetImage(@"backicon") forState:UIControlStateNormal];
    backItem.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backItem];
}
- (void)backBtnClick {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)seeMatchClick:(id)sender {
    if (self.publishType == HHPublishTyleMatch || self.publishType == HHPublishTyleTag) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
        CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
        collectionViewController.collectionId = [NSNumber numberWithInt:[self.matchId intValue]];
        [self.navigationController pushViewController:collectionViewController animated:YES];
    }else {
        HHTopicDetailViewController *vc = [[HHTopicDetailViewController alloc] init];
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];;
//        RJTopicDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"RJTopicDetailViewController"];

        vc.shareModel = self.shareModel;
        vc.informId = [NSNumber numberWithInt:self.informationId.intValue];
        vc.isThumbUp = @(0);
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (IBAction)continueMatchClick:(id)sender {
    //继续 ： 上传搭配
    if (self.publishType == HHPublishTyleTag) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    //继续 ： 创建搭配
    else if (self.publishType == HHPublishTyleMatch){
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[SMCreateMatchController class]]) {
                SMCreateMatchController *create = (SMCreateMatchController *)vc;
                [create deleteMatch];
                [self.navigationController popToViewController:create animated:NO];
            }
        }
    }
    //继续 ： 创建资讯
    else {
        for (UIViewController *vc in self.navigationController.viewControllers) {
            if ([vc isKindOfClass:[HHInformationViewController class]]) {
                HHInformationViewController *information = (HHInformationViewController *)vc;
                [information deleteInformation];
                [self.navigationController popToViewController:information animated:NO];
            }
        }

    }
}
-(void)forbiddenSideBack{
    
    //关闭ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
        
    }
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer*)gestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
    
}
//viewDidDisappear
- (void)resetSideBack {
    
    //开启ios右滑返回
    if([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
