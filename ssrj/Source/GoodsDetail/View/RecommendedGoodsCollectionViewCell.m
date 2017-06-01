//
//  RecommendedGoodsCollectionViewCell.m
//  ssrj
//
//  Created by MFD on 16/6/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RecommendedGoodsCollectionViewCell.h"
#import "ZanModel.h"
#import "GetToThemeViewController.h"


@implementation RecommendedGoodsCollectionViewCell


- (UIViewController *)viewController{
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (IBAction)addToTheme:(id)sender {
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [[self viewController]presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC.collectionID = self.colloctionId;
    
    [[self viewController].navigationController pushViewController:getToThemeVC animated:YES];
    
//    [[self viewController] presentViewController:getToThemeVC animated:YES completion:nil];
    
}


- (IBAction)zan:(id)sender {
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [[self viewController]presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    [self getNetData];
}

- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=collocation";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    if (self.colloctionId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.colloctionId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                weakSelf.zanBtn.selected = thumb;
                
                weakSelf.changeStateBlock([NSNumber numberWithBool:thumb]);
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];

            }
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:[error localizedDescription] hideDelay:1];
        
    }];
}

- (void)showRightLine{
    self.sepView.hidden = NO;
}
- (void)hideRightLine{
    self.sepView.hidden = YES;
}
-(void)prepareForReuse{
    [super prepareForReuse];
    self.sepView.hidden = YES;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    self.authorImg.layer.cornerRadius = 14;
    self.authorImg.layer.masksToBounds = YES;
    self.authorImg.layer.borderWidth = 0.5;
    self.authorImg.layer.borderColor = [UIColor colorWithHexString:@"ffffff"].CGColor;
    
    self.rightLineWidthConstraint.constant = 0.7;
    self.bottomLineHeightConstraint.constant = 0.7;
    
    /**
     *  点击用户头像去个人中心界面 添加Tap事件
     */
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    self.authorImg.userInteractionEnabled = YES;
    self.recommendAuthor.userInteractionEnabled = YES;
    
    [self.authorImg addGestureRecognizer:tapGest1];
    [self.recommendAuthor addGestureRecognizer:tapGest2];

}
- (void)TapUserViewAction:(UITapGestureRecognizer *)sender{
    
    if (self.userDelegate && [self.userDelegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [self.userDelegate didTapedUserViewWithUserId:self.model.memberId userName:self.model.autherName];
    }
    if (sender.view.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:sender.view.trackingId];
    }
}
- (void)setModel:(RJGoodDetailRelationCollocationModel *)model{
    _model = model;
    self.authorImg.trackingId = [NSString stringWithFormat:@"%@&authorImg&id=%@",NSStringFromClass(self.class),model.collocationId];
    self.recommendAuthor.trackingId = [NSString stringWithFormat:@"%@&recommendAuthor&id=%@",NSStringFromClass(self.class),model.collocationId];

    
}
@end
