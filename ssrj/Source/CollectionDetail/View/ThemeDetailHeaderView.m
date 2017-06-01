//
//  ThemeDetailHeaderView.m
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ThemeDetailHeaderView.h"
#import "ThemeDetailModel.h"

@implementation ThemeDetailHeaderView
- (void)setData:(ThemeData *)data{
    _data = data;
    self.themeTitle.text = data.name;
    [self.authorIcon sd_setImageWithURL:[NSURL URLWithString:data.avatar]];
    self.authorName.text = data.userName;
    self.zanCountLabel.text = [data.thumbsupCount stringValue];
    self.themeNumLabel.text = [data.countCollocation stringValue];
    self.themeDescription.text = data.memo;
    self.themeDescription.preferredMaxLayoutWidth = SCREEN_WIDTH-16;
    self.publishButton.layer.cornerRadius = 12.5;
    self.publishButton.layer.masksToBounds = YES;
    
    CGFloat textHeight =0;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize size = [self.data.memo boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 16, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:style} context:nil].size;
    textHeight = size.height+5;
    
    CGRect frame = self.themeDescription.frame;
    frame.size.height = textHeight;
    self.themeDescription.frame = frame;

//    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
//    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*150/320);
//    [_bgImageView addSubview:effectView];
    
    [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:data.picture] placeholderImage:[UIImage imageNamed:@"bg"]];
    BOOL isThumbUp = data.thumbsup;
    if (isThumbUp) {
        self.zanIcon.image = [UIImage imageNamed:@"zan_icon_select"];
    } else {
        
        self.zanIcon.image = [UIImage imageNamed:@"dianzanwhite"];
    }
    
//    NSLog(@"data.memberList=%@", data.memberList);

    NSArray *fansArr = [NSArray arrayWithArray:data.memberList];
    
    if (fansArr.count) {
        
        if (fansArr.count == 0) {
            
            self.followerImageView1.hidden = YES;
            self.followerImageView2.hidden = YES;
            self.followerImageView3.hidden = YES;
            self.followerImageView4.hidden = YES;
            self.followerImageView5.hidden = YES;
        }
        if (fansArr.count == 1) {
            
            self.followerImageView1.hidden = YES;
            self.followerImageView2.hidden = YES;
            self.followerImageView3.hidden = YES;
            self.followerImageView4.hidden = YES;
            self.followerImageView5.hidden = NO;
            fansMemberList *model = [[fansMemberList alloc] initWithDictionary:fansArr[0] error:nil];
            [self.followerImageView5 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            
        }
        if (fansArr.count == 2) {
            self.followerImageView1.hidden = YES;
            self.followerImageView2.hidden = YES;
            self.followerImageView3.hidden = YES;
            self.followerImageView4.hidden = NO;
            self.followerImageView5.hidden = NO;
            fansMemberList *model = [[fansMemberList alloc] initWithDictionary:fansArr[0] error:nil];
            [self.followerImageView4 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[1] error:nil];
            [self.followerImageView5 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
        }
        if (fansArr.count == 3) {
            self.followerImageView1.hidden = YES;
            self.followerImageView2.hidden = YES;
            self.followerImageView3.hidden = NO;
            self.followerImageView4.hidden = NO;
            self.followerImageView5.hidden = NO;
            
            fansMemberList *model = [[fansMemberList alloc] initWithDictionary:fansArr[0] error:nil];
            [self.followerImageView3 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[1] error:nil];
            [self.followerImageView5 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[2] error:nil];
            [self.followerImageView5 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
        }
        if (fansArr.count == 4) {
            self.followerImageView1.hidden = YES;
            self.followerImageView2.hidden = NO;
            self.followerImageView3.hidden = NO;
            self.followerImageView4.hidden = NO;
            self.followerImageView5.hidden = NO;
            
            fansMemberList *model = [[fansMemberList alloc] initWithDictionary:fansArr[0] error:nil];
            [self.followerImageView2 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[1] error:nil];
            [self.followerImageView3 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[2] error:nil];
            [self.followerImageView4 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[3] error:nil];
            [self.followerImageView5 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            
        }
        if (fansArr.count >= 5) {
            self.followerImageView1.hidden = NO;
            self.followerImageView2.hidden = NO;
            self.followerImageView3.hidden = NO;
            self.followerImageView4.hidden = NO;
            self.followerImageView5.hidden = NO;
            
            fansMemberList *model = [[fansMemberList alloc] initWithDictionary:fansArr[0] error:nil];
            
            [self.followerImageView1 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[1] error:nil];
            [self.followerImageView2 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[2] error:nil];
            [self.followerImageView3 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[3] error:nil];
            [self.followerImageView4 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
            model = [[fansMemberList alloc] initWithDictionary:fansArr[4] error:nil];
            [self.followerImageView5 sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
        }
    }
    self.authorIcon.trackingId = [NSString stringWithFormat:@"ThemeDetailHeaderView&id=%@",data.themeCollectionId];
}


- (void)awakeFromNib{
    [super awakeFromNib];
    self.zanBgView.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    self.zanBgView.layer.borderWidth = 1.0;
    self.zanBgView.layer.cornerRadius = 12.5;
    self.commentBgView.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    self.commentBgView.layer.borderWidth = 1.0;
    self.commentBgView.layer.cornerRadius = 12.5;
    
    self.authorIcon.layer.cornerRadius = 12.5;
    self.authorIcon.clipsToBounds = YES;
    
    self.followerImageView1.layer.cornerRadius = 12.5;
    self.followerImageView1.clipsToBounds = YES;
    self.followerImageView1.layer.borderWidth = 1.0;
    self.followerImageView1.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    
    self.followerImageView2.layer.cornerRadius = 12.5;
    self.followerImageView2.clipsToBounds = YES;
    self.followerImageView2.layer.borderWidth = 1.0;
    self.followerImageView2.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    
    self.followerImageView3.layer.cornerRadius = 12.5;
    self.followerImageView3.clipsToBounds = YES;
    self.followerImageView3.layer.borderWidth = 1.0;
    self.followerImageView3.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    
    self.followerImageView4.layer.cornerRadius = 12.5;
    self.followerImageView4.clipsToBounds = YES;
    self.followerImageView4.layer.borderWidth = 1.0;
    self.followerImageView4.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    
    self.followerImageView5.layer.cornerRadius = 12.5;
    self.followerImageView5.clipsToBounds = YES;
    self.followerImageView5.layer.borderWidth = 1.0;
    self.followerImageView5.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, _bgImageView.frame.origin.y, SCREEN_WIDTH, SCREEN_WIDTH *200/320)];
    
    _toolbar.barStyle = UIBarStyleBlackTranslucent;
    _toolbar.alpha = 0.65;
    [_bgImageView addSubview:_toolbar];
    
    /**
     *  点击用户头像去个人中心界面 添加Tap事件
     */
    UITapGestureRecognizer *tapGest1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    UITapGestureRecognizer *tapGest2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapUserViewAction:)];
    self.authorIcon.userInteractionEnabled = YES;
    self.authorName.userInteractionEnabled = YES;
    
    [self.authorIcon addGestureRecognizer:tapGest1];
    [self.authorName addGestureRecognizer:tapGest2];

    
}

- (void)TapUserViewAction:(id)sender{
    [[RJAppManager sharedInstance] trackingWithTrackingId:self.authorIcon.trackingId];
    if (self.headerUserDelegate && [self.headerUserDelegate respondsToSelector:@selector(didTapedUserViewWithUserId:userName:)]) {
        [self.headerUserDelegate didTapedUserViewWithUserId:self.data.member userName:self.data.userName];
    }
}

@end
