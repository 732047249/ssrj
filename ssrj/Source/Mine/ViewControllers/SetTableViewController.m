//
//  SetTableViewController.m
//  ssrj
//
//  Created by YiDarren on 16/6/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SetTableViewController.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "AboutUsViewController.h"
#import "ChangeMimaViewController.h"
#import "DestinationManageViewController.h"


@interface SetTableViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cacheLabel;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

@implementation SetTableViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];

    [MobClick beginLogPageView:@"设置页面"];
    [TalkingData trackPageBegin:@"设置页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"设置页面"];
    [TalkingData trackPageEnd:@"设置页面"];
    
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSArray *cells = [self.tableView visibleCells];
    for (UITableViewCell *cell in cells) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        cell.trackingId = [NSString stringWithFormat:@"%@&UITableViewCell&index=%zd",NSStringFromClass([self class]),indexPath.row];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"设置";
    
    float tmpSize = [self checkTmpFileSize];
    NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"%.2fM",tmpSize] : [NSString stringWithFormat:@"%.2fK",tmpSize * 1024];
    _cacheLabel.text = clearCacheName;
    self.versionLabel.text = [NSString stringWithFormat:@"V%@",VERSION];
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

//计算缓存大小
- (float)checkTmpFileSize {
    
    float folderSize;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childenFiles = [fileManager subpathsAtPath:path];
        for (NSString *fileName in childenFiles) {
            NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:absolutePath error:nil];
            unsigned long long length = [attrs fileSize];
            folderSize += length/1024.0/1024.0;
        }
        return folderSize;
    }
    return 0;
    
}

//清除缓存
- (void)clearTmpPics
{
    
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"清理中" xOffset:0 yOffset:0];
    [[SDImageCache sharedImageCache] clearMemory];//可有可无
    __weak __typeof(&*self)weakSelf = self;
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        
        float tmpSize = 0;
        NSString *clearCacheName = tmpSize >= 1 ? [NSString stringWithFormat:@"%.2fM",tmpSize] : [NSString stringWithFormat:@"%.2fK",tmpSize * 1024];
        _cacheLabel.text = clearCacheName;
        [weakSelf.tableView reloadData];
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"清理图片缓存成功" image:nil];
    }];
    
}

- (IBAction)quitButtonAction:(id)sender {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"帐号将退出" message:@"帐号将退出,退出后需重新登录" delegate:self cancelButtonTitle:@"退出" otherButtonTitles:@"取消", nil];
    alert.tag = 100;
    [alert show];

}

#pragma mark -- UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //退出
    if (alertView.tag == 100) {
        //退出
        if (buttonIndex == 0) {
//            NSLog(@"退出");
            [[RJAccountManager sharedInstance]unregisterAccountWithHud:YES];
            [self.tabBarController setSelectedIndex:0];//退出账号，不能在进入次UI，故如此设置
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.navigationController popViewControllerAnimated:NO];

            });
            

            
        }
    }
    
    //清缓存
    if (alertView.tag == 101) {
        if (buttonIndex == 0) {
//            NSLog(@"清缓存");
//            [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"清理中" xOffset:0 yOffset:0];

//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//            NSString *path = [paths objectAtIndex:0];
//            NSFileManager *fileManager = [NSFileManager defaultManager];
//            
//            if ([fileManager fileExistsAtPath:path]) {
//                
//                NSArray *childenFiles = [fileManager subpathsAtPath:path];
//                for (NSString *fileName in childenFiles) {
//                    NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
//                    [fileManager removeItemAtPath:absolutePath error:nil];
//                    
//                }
//            }
            
            [[SDImageCache sharedImageCache] cleanDisk];
            [self clearTmpPics];
        }
    }
    
    
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (section == 0) {
        return 5;//去掉用户反馈
    }
    else {
        return 1;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//  segue跳转
    //修改密码
    if (indexPath.row == 0) {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
        
        ChangeMimaViewController *changeVC = [story instantiateViewControllerWithIdentifier:@"ChangeMimaViewController"];
        
        [self.navigationController pushViewController:changeVC animated:YES];
    }
    //地址管理
    if (indexPath.row == 1) {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
        
        DestinationManageViewController *destinationVC = [story instantiateViewControllerWithIdentifier:@"DestinationManageViewController"];
        
        [self.navigationController pushViewController:destinationVC animated:YES];
    }
    //清缓存操作
    if (indexPath.row == 2) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"清除缓存" message:@"缓存将被清除" delegate:self cancelButtonTitle:@"清除" otherButtonTitles:@"取消", nil];
        alert.tag = 101;
        [alert show];
    }
    //跳转到评论链接
    if (indexPath.row == 3) {
        //        itms-apps://itunes.apple.com/app/idxxxxxxx
        //        NSString *urlStr = @"https://appsto.re/cn/iajU9.i";
        
        NSString *url = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/id%@",APP_ID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
    
    //关于我们
    if (indexPath.row == 4) {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
        
        AboutUsViewController *aboutUsVC = [story instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
        
        [self.navigationController pushViewController:aboutUsVC animated:YES];
    }
    
}


@end
