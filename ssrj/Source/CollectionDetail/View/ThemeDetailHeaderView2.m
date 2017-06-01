//
//  ThemeDetailHeaderView2.m
//  ssrj
//
//  Created by MFD on 16/9/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ThemeDetailHeaderView2.h"
#import <masonry.h>

@implementation ThemeDetailHeaderView2

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        _sepView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        _sepView.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
        
        _titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 40)];
        _titleView.backgroundColor = [UIColor whiteColor];
        _title = [[UILabel alloc]initWithFrame:CGRectZero];
        _title.font = [UIFont systemFontOfSize:15];
        _title.textColor = [UIColor colorWithHexString:@"424446"];
        _title.text = @"评论";
        _count = [[UILabel alloc]initWithFrame:CGRectZero];
        _count.font = [UIFont systemFontOfSize:14];
        _count.textColor = [UIColor colorWithHexString:@"898e90"];
    //    count.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.comment.commentList.count];
        
        [_titleView addSubview:_title];
        [_titleView addSubview:_count];
        [self addSubview:_sepView];
        [self addSubview:_titleView];
        
//        [_sepView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.mas_left);
//            make.right.equalTo(self.mas_right);
//            make.top.equalTo(self.mas_top);
//            make.height.mas_equalTo(10);
//        }];
//        
//        [_titleView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(self.mas_left);
//            make.right.equalTo(self.mas_right);
//            make.top.equalTo(_sepView.mas_top);
//            make.bottom.equalTo(self.mas_bottom);
//        }];
        
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_titleView.mas_left).offset(10);
            make.centerY.equalTo(_titleView.mas_centerY);
        }];
        
        [_count mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_title.mas_right).offset(5);
            make.centerY.equalTo(_title.mas_centerY);
        }];
        
    }
    return self;
}


- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
}
@end


@implementation ThemeDetailFooterView2



@end
