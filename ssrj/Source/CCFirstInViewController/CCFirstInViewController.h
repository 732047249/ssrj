//
//  CCFirstInViewController.h
//  ssrj
//
//  Created by CC on 16/12/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "YFGIFImageView.h"
//#import "UIImageView+PlayGIF.h"
#import "OLImageView.h"
@interface CCFirstInViewController : UIViewController
+(instancetype)newFirstInViewControllerWithImageName:(NSArray *)images enterBlock:(void(^)())enterBlock;
+ (BOOL)canShowNewFeature;
@end




@interface CCFirstInViewGifImageCollectionViewCell : UICollectionViewCell
@property (nonatomic,strong) NSString * imageName;
@property (nonatomic,strong) OLImageView * gifImageView;
@property (nonatomic,strong) UIImageView * imageView;
@end