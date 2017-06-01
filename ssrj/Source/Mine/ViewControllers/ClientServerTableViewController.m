//
//  ClientServerTableViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/17.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ClientServerTableViewController.h"
#import "LocalDefine.h"
#import "EMIMHelper.h"
#import "ChatViewController.h"

@interface ClientServerTableViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableViewCell *kefuCell;
@property (weak, nonatomic) IBOutlet UIImageView *kefuRedicon;

@end

@implementation ClientServerTableViewController

//拨打客服电话
-(IBAction)callTheClientServer:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"拨打客服电话" message:@"确认自动拨打客服电话" delegate:self cancelButtonTitle:@"等等" otherButtonTitles:@"确认", nil];
    alert.tag = 100;
    [alert show];
    
}

//客服发送邮箱
-(IBAction)sendEmailButtonAction:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"发送邮件" message:@"确认给客服邮箱发送邮件" delegate:self cancelButtonTitle:@"等等" otherButtonTitles:@"确认", nil];
    alert.tag = 101;
    [alert show];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [MobClick beginLogPageView:@"客服页面"];
    [TalkingData trackPageBegin:@"客服页面"];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newKeFuMessage) name:kStatusNewKeFuMessageNotification object:nil];
    self.kefuRedicon.hidden = YES;
    if ([RJAppManager sharedInstance].isNewKeFuMessage) {
        self.kefuRedicon.hidden = NO;
    }
}
- (void)newKeFuMessage{
    self.kefuRedicon.hidden = NO;
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusNewKeFuMessageNotification object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"客服页面"];
    [TalkingData trackPageEnd:@"客服页面"];

}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.kefuCell.trackingId = [NSString stringWithFormat:@"%@&kefuCell",NSStringFromClass(self.class)];
}

- (void)addBackButton{
    self.navigationItem.hidesBackButton = YES;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImg = GetImage(@"back_icon");
    [button addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0.0f, 0.0f, buttonImg.size.width+20, buttonImg.size.height);
    [button setImageEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [button setImage:buttonImg forState:0];
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = buttonItem;
    
}

- (void)back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (buttonIndex == 0) {
        
        return;
    }
    
    
    //拨打电话
    if (alertView.tag == 100) {
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"tel://4000847775"]];

    }
    //发送邮件
    else {
        
        NSString *recipients =@"mailto: CS@mfdapparel.com";
        
        NSString *body =@"";
        
        NSString *email = [NSString stringWithFormat:@"%@%@", recipients, body];
        
        email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:email]];

    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 1;
    }
    
    if (section == 1) {
        return 1;
    }
    
    if (section == 2) {
        return 1;
    }
    
    if (section == 3) {
        return 2;
    }
    
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

#pragma mark -- 点击在线客服跳转
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
        [[EMIMHelper defaultHelper] loginEasemobSDK];
        NSString *cname = @"mfd2016ssrj";
        ChatViewController *chatViewController = [[ChatViewController alloc]initWithChatter:cname type:eSaleTypeNone];
        chatViewController.title = @"时尚客服";
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
    
}

@end
