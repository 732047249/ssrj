//
//  categoryTableViewCell.m
//  categoryDemo
//
//  Created by MFD on 16/5/24.
//  Copyright © 2016年 MFD. All rights reserved.
//


#import "categoryTableViewCell.h"

@implementation categoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
        
        _picture = [[UIImageView alloc]initWithFrame:CGRectMake(0, -(SCREEN_HEIGHT/3.5-150)/2, SCREEN_WIDTH, SCREEN_HEIGHT/3.5)];

        
        if (DEVICE_IS_IPHONE5) {
            
            _picture = [[UIImageView alloc]initWithFrame:CGRectMake(0, -(SCREEN_HEIGHT/3.5-110)/2, SCREEN_WIDTH, 220)];
        }

        
        if (DEVICE_IS_IPHONE4) {
            
            _picture = [[UIImageView alloc]initWithFrame:CGRectMake(0, -(SCREEN_HEIGHT/3.5-100)/2, SCREEN_WIDTH, 200)];
        }
        
        _picture.contentMode = UIViewContentModeScaleAspectFill;
        //_picture.image = [UIImage imageNamed:@"分类_半身裙"];
//        _picture.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_picture];

        _coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 150)];
        _coverView.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        [self.contentView addSubview:_coverView];
        
        _categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 150/2-45, SCREEN_WIDTH/2, 30)];
        _categoryLabel.font = [UIFont boldSystemFontOfSize:20];
        _categoryLabel.textAlignment = NSTextAlignmentCenter;
        _categoryLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
//        _categoryLabel.text = @"上衣";
        [self.contentView addSubview:_categoryLabel];
        
        _engCategoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH/2, 150/2-15, SCREEN_WIDTH/2, 30)];
        _engCategoryLabel.font = [UIFont boldSystemFontOfSize:20];
        _engCategoryLabel.textAlignment = NSTextAlignmentCenter;
        _engCategoryLabel.textColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1];
//        _engCategoryLabel.text = @"Tops";
        [self.contentView addSubview:_engCategoryLabel];
        
        
    }
    return self;
}


- (CGFloat)cellOffset{
    CGRect centerToWindow = [self convertRect:self.bounds toView:self.window];
    
    CGFloat centerY = CGRectGetMidY(centerToWindow);
    CGPoint windowCenter = self.superview.center;
    
    CGFloat cellOffsetY = centerY - windowCenter.y;
    
    CGFloat offsetDig = cellOffsetY / self.superview.frame.size.height *2;
    CGFloat offset = -offsetDig * (SCREEN_HEIGHT/3.5 - 150)/2;
    if (DEVICE_IS_IPHONE4) {
        
        offset = -offsetDig * (SCREEN_HEIGHT/3.5 - 100)/2;
    }
    
    if (DEVICE_IS_IPHONE5) {
        
        offset = -offsetDig * (SCREEN_HEIGHT/3.5 - 110)/2;
    }
    
    CGAffineTransform transY = CGAffineTransformMakeTranslation(0, offset);
    
    self.picture.transform = transY;
    
    return offset;
}
@end
