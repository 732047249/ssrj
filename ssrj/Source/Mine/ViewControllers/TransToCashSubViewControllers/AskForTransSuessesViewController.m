//
//  AskForTransSuessesViewController.m
//  ssrj
//
//  Created by YiDarren on 16/9/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "AskForTransSuessesViewController.h"

@interface AskForTransSuessesViewController ()

@property (weak, nonatomic) IBOutlet UIButton *Done;

@end

@implementation AskForTransSuessesViewController
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"申请提现成功页面"];
    [TalkingData trackPageBegin:@"申请提现成功页面"];

}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"申请提现成功页面"];
    [TalkingData trackPageEnd:@"申请提现成功页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addBackButton];
    self.title = @"申请提现";
    _Done.layer.cornerRadius = 20;
    _Done.layer.masksToBounds = YES;

}

- (IBAction)DoneButtonAction:(id)sender {
    
    [UIView animateWithDuration:1 delay:1.5 options:UIViewAnimationTransitionFlipFromRight animations:^{
       
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } completion:^(BOOL finished) {
        
        
    }];

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
