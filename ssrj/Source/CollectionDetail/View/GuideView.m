//
//  GuideView.m
//  ssrj
//
//  Created by LiHaoFeng on 16/9/13.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "GuideView.h"

@interface GuideView ()

@property (nonatomic, strong) UIImageView* imageView;

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@end


@implementation GuideView

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self initContentView];
        
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shouldDissmissGuideView:)];
        
        [self addGestureRecognizer:_tapGesture];
        
    }
    return self;
}

-(void)initContentView{
    
    _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    
    _imageView.userInteractionEnabled = YES;
    
    [self addSubview:_imageView];
    
}

-(void)shouldDissmissGuideView:(UITapGestureRecognizer*)gesture{
    
    [UIView animateWithDuration:0.15 animations:^{
        self.opaque = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:_identifier];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }];
}

-(void)setLocalImage:(NSString *)localImage{
    
    _localImage = localImage;
    
//    NSString* path = [[NSBundle mainBundle]pathForResource:_localImage ofType:@"png"];
    
//    _imageView.image = [UIImage imageWithContentsOfFile:path];
    
    _imageView.image = [UIImage imageNamed:localImage];
    
}



@end
