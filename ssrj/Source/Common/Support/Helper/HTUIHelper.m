//
//  HTUIHelper.m
//  LLLove
//
//  Created by George on 14-7-3.
//  Copyright (c) 2014年 ZHIHE. All rights reserved.
//

#import "HTUIHelper.h"

@interface HTUIHelper()
@property (nonatomic, strong) MBProgressHUD *HUD;

@end

@implementation HTUIHelper
+(instancetype)shareInstance{
    static dispatch_once_t oncePredicate;
    static HTUIHelper *instance;
    dispatch_once(&oncePredicate, ^{
        instance = [[HTUIHelper alloc] init];
    });
    return instance;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)alertMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)addHUDToWindowWithString:(NSString *)string
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.labelText = string;
    [hud show:YES];
}
+ (void)addHUDToWindowWithString:(NSString *)string hideDelay:(CGFloat)delay{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] keyWindow] animated:YES];
    hud.detailsLabelText = string;
    hud.mode = MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
}
+ (void)removeHUDToWindow
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:window];
        if (hud) {
            [hud hide:YES];
        }
    }
}
+ (void)removeHUDToWindowWithEndString:(NSString *)string image:(UIImage *)image delyTime:(NSTimeInterval)time{
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (UIWindow *window in windows) {
        MBProgressHUD *hud = [MBProgressHUD HUDForView:window];
        if (hud) {
            hud.mode = MBProgressHUDModeCustomView;
            hud.customView = [[UIImageView alloc] initWithImage:image];
            hud.labelText = string;
            [hud hide:YES afterDelay:time];
        }
    }
}

+ (void)addHUDToView:(UIView *)view withString:(NSString *)string xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = string;
    hud.xOffset = xOffset;
    hud.yOffset = yOffset;
    [hud show:YES];
    
}

+ (void)addHUDToView:(UIView *)view withString:(NSString *)string hideDelay:(CGFloat)delay
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = string;
    hud.mode = MBProgressHUDModeText;
    [hud show:YES];
    [hud hide:YES afterDelay:delay];
    
}


//新HUD 不使用类方法
- (void)addHUDToView:(UIView *)view withString:(NSString *)string xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset{
    if (self.HUD) {
        [self.HUD hide:YES];
    }
    self.HUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    _HUD.mode = MBProgressHUDModeIndeterminate;
    _HUD.labelText = string;
    _HUD.xOffset = xOffset;
    _HUD.yOffset = yOffset;
    [_HUD show:YES];
}
- (void)editWithString:(NSString *)str{
    if (_HUD) {
        _HUD.labelText = str;
    }
}
- (void)removeHUD{
    if (_HUD) {
        [_HUD hide:YES];
    }
}
- (void)removeHUDWithEndString:(NSString *)endString image:(UIImage *)image{
    if (_HUD) {
        _HUD.mode = MBProgressHUDModeCustomView;
        _HUD.customView = [[UIImageView alloc] initWithImage:image];
        _HUD.labelText = endString;
        [_HUD hide:YES afterDelay:1.0f];
    }
}
- (void)removeHUDWithEndString:(NSString *)endString image:(UIImage *)image delyTime:(NSTimeInterval)time{
    if (_HUD) {
        _HUD.mode = MBProgressHUDModeCustomView;
        _HUD.customView = [[UIImageView alloc] initWithImage:image];
        _HUD.labelText = endString;
        [_HUD hide:YES afterDelay:time];
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* 创建一个String导航按钮 */
+ (UIBarButtonItem *)createStringNavBarItem:(NSString *)title
                               actionObject:(id)actionObject
                                     action:(SEL)action
                                buttonImage:(UIImage *)buttonImage
                       buttonHighlightImage:(UIImage *)buttonHighlightImage {
		
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    button.titleLabel.textColor = [UIColor whiteColor];
    button.titleLabel.shadowOffset = CGSizeMake(0,-1);
    button.titleLabel.shadowColor = [UIColor darkGrayColor];
    button.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
    
	CGSize textSize = [title sizeWithFont:button.titleLabel.font];
    button.frame = CGRectMake(0, 0, textSize.width + 32, buttonImage.size.height);
    [button setTitle:title forState:UIControlStateNormal];
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:buttonHighlightImage forState:UIControlStateHighlighted];
    [button addTarget:actionObject action:action forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
	return barbutton;
}

/* 创建一个图片导航按钮 */
+ (UIBarButtonItem *)createImageNavBarItem:(UIImage *)buttonImage
                      buttonHighlightImage:(UIImage *)buttonHighlightImage
                               actionObject:(id)actionObject
                                    action:(SEL)action
                                    isLeft:(BOOL)isLeft {
		
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.frame = CGRectMake(-10, 0, buttonImage.size.width, buttonImage.size.height);
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button setImage:buttonHighlightImage forState:UIControlStateHighlighted];
    if (isLeft) {
        button.imageEdgeInsets = UIEdgeInsetsMake(0, -25, 0, 0);
    } else {
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -25);
    }

    button.tintColor = UIColorFromRGBOne(198);
    [button addTarget:actionObject action:action forControlEvents:UIControlEventTouchUpInside];
    
	UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
	return barbutton;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////


+ (void)addTableBackGroundViewTop:(NSString *)timageName
                             bottom:(NSString *)bimageName
                          tableView:(UITableView *)tableView
                              frame:(CGRect)frame {
    
    /*
     UIImage *bimage = GetImage(bimageName);
     UIImageView *bimageView = [[UIImageView alloc] initWithFrame:frame];
     bimageView.image = bimage;
     tableView.tableFooterView = bimageView;
     [bimageView release];
     */
    
    UIView *bimageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height*2)];
    bimageView.backgroundColor = [UIColor whiteColor];
    tableView.tableFooterView = bimageView;
    
    tableView.contentInset = UIEdgeInsetsMake(0, 0, -frame.size.height*2, 0);
    
    UIImage *timage = GetImage(timageName);
    UIImageView *timageView = [[UIImageView alloc] initWithFrame:frame];
    timageView.image = timage;
    tableView.backgroundView = timageView;
}

+ (ZHCellBackgroundPosition)calculateCellPosition:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    
    NSInteger position = kZHCellBackgroundPositionSingle;
    int rowCount = [tableView numberOfRowsInSection:indexPath.section];
    if (rowCount > 1) {
        if (indexPath.row == 0) {
            position = kZHCellBackgroundPositionTop;
        } else if (indexPath.row == rowCount - 1) {
            position = kZHCellBackgroundPositionBottom;
        } else {
            position = kZHCellBackgroundPositionMiddle;
        }
    }
    return position;
}

+ (void)setTableViewCellBackground:(UITableView *)tableView
                              cell:(UITableViewCell *)cell
                         indexPath:(NSIndexPath *)indexPath {
    
    NSInteger position = [HTUIHelper calculateCellPosition:tableView indexPath:indexPath];
    if (position == kZHCellBackgroundPositionSingle) {
        UIImage *bgImg = GetImage(@"table_single_normal");
        UIImage *sBgImg = GetImage(@"");
        if (bgImg) {
            UIImage *bottomScaled = [bgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            UIImageView *bottomBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            bottomBg.image = bottomScaled;
            cell.backgroundView = bottomBg;
        }
        
        if (sBgImg) {
            UIImage *sbottomScaled = [sBgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            UIImageView *sbottomBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            sbottomBg.image = sbottomScaled;
            cell.selectedBackgroundView = sbottomBg;
        }
        
    } else if (position == kZHCellBackgroundPositionTop) {
        UIImage *bgImg = GetImage(@"table_above_normal");
        UIImage *sBgImg = GetImage(@"");
        if (bgImg) {
            UIImage *topScaled = [bgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            
            UIImageView *topBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            topBg.image = topScaled;
            cell.backgroundView = topBg;
        }
        
        if (sBgImg) {
            UIImage *stopScaled = [sBgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            UIImageView *stopBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            stopBg.image = stopScaled;
            cell.selectedBackgroundView = stopBg;
        }
        
    } else if (position == kZHCellBackgroundPositionMiddle) {
        UIImage *bgImg = GetImage(@"table_middle_normal");
        UIImage *sBgImg = GetImage(@"");
        if (bgImg) {
            UIImage *centerScaled = [bgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            
            UIImageView *centerBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            centerBg.image = centerScaled;
            cell.backgroundView = centerBg;
        }
        
        if (sBgImg) {
            UIImage *scenterScaled = [sBgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            
            UIImageView *scenterBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            scenterBg.image = scenterScaled;
            cell.selectedBackgroundView = scenterBg;
        }
        
    } else if (position == kZHCellBackgroundPositionBottom) {
        UIImage *bgImg = GetImage(@"table_bottom_normal");
        UIImage *sBgImg = GetImage(@"");
        if (bgImg) {
            UIImage *bottomScaled = [bgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            
            UIImageView *bottomBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            bottomBg.image = bottomScaled;
            cell.backgroundView = bottomBg;
        }
        if (sBgImg) {
            UIImage *sbottomScaled = [sBgImg stretchableImageWithLeftCapWidth:20 topCapHeight:20];
            
            UIImageView *sbottomBg = [[UIImageView alloc] initWithFrame:cell.contentView.frame];
            sbottomBg.image = sbottomScaled;
            cell.selectedBackgroundView = sbottomBg;
        }
    }
}

/*
+ (void)setTableViewCellSelectedBackground:(UITableView *)tableView
                                      cell:(UITableViewCell *)cell
                                 indexPath:(NSIndexPath *)indexPath
                                 fillColor:(UIColor *)fillColor
                               borderRound:(CGFloat)borderRound
                               borderColor:(UIColor *)borderColor {
    ZHCellBackgroundView *selectedBackground = [[ZHCellBackgroundView alloc] initWithFrame:cell.frame];
    selectedBackground.position = [ZHUICommenMethod calculateCellPosition:tableView indexPath:indexPath];
    if (nil != fillColor) {
        selectedBackground.fillColor = fillColor;
    }
    if (nil != borderColor) {
        selectedBackground.borderColor = borderColor;
    }
    selectedBackground.borderRound = borderRound;
    cell.selectedBackgroundView = selectedBackground;
    [selectedBackground release];
}
*/

+ (UIImage*)imageWithImage:(UIImage*)sourceImage scaledToSize:(CGSize)newSize {
    
    CGFloat targetWidth = newSize.width;
    CGFloat targetHeight = newSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, M_PI_2); // + 90 degrees
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, -M_PI_2); // - 90 degrees
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, -M_PI); // - 180 degrees
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage;
}

+ (UIImage *)clipImageToCircle:(UIImage *)image {
    
    UIImage *finalImage = nil;
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGAffineTransform trnsfrm = CGAffineTransformConcat(CGAffineTransformIdentity, CGAffineTransformMakeScale(1.0, -1.0));
        trnsfrm = CGAffineTransformConcat(trnsfrm, CGAffineTransformMakeTranslation(0.0, image.size.height));
        CGContextConcatCTM(ctx, trnsfrm);
        CGContextBeginPath(ctx);
        CGContextAddEllipseInRect(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height));
        CGContextClip(ctx);
        CGContextDrawImage(ctx, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
        finalImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return finalImage;
}


@end
