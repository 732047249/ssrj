//
//  RJScannerView.m
//  ssrj
//
//  Created by YiDarren on 16/5/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJScannerView.h"
#import <AVFoundation/AVFoundation.h>
#import "SubLBXScanViewController.h"

#import "LBXScanView.h"
#import <objc/message.h>
#import "LBXScanResult.h"
#import "LBXScanWrapper.h"
#import "LBXAlertAction.h"


@interface RJScannerView ()

//@property (strong, nonatomic) LBXScanViewStyle *canViewStyle;
{
    LBXScanViewStyle *scanViewStyle;
}
@end


@implementation RJScannerView

+(BOOL)cameraAuthStatus {
    
    BOOL isHavePemission = NO;
    if ([AVCaptureDevice respondsToSelector:@selector(authorizationStatusForMediaType:)])
    {
        AVAuthorizationStatus permission =
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        switch (permission) {
            case AVAuthorizationStatusAuthorized:
                isHavePemission = YES;
                break;
            case AVAuthorizationStatusDenied:
            case AVAuthorizationStatusRestricted:
                break;
            case AVAuthorizationStatusNotDetermined:
                isHavePemission = YES;
                break;
        }
    }
    
//    NSLog(@"cameraAuthStatus -------");
    
    return isHavePemission;
    
}

+ (LBXScanViewStyle *)paramSet {
    
    //设置扫码区域参数设置
    
    //创建参数对象
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    
    //矩形区域中心上移，默认中心点为屏幕中心点
    //    style.centerUpOffset = 44;
    
    //扫码框周围4个角的类型,设置为外挂式
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Outer;
    
    //扫码框周围4个角绘制的线条宽度
    style.photoframeLineW = 6;
    
    //扫码框周围4个角的宽度
    style.photoframeAngleW = 24;
    
    //扫码框周围4个角的高度
    style.photoframeAngleH = 24;
    
    //扫码框内 动画类型 --线条上下移动
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //线条上下移动图片
    style.animationImage = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    
    return style;
 
}


+ (SubLBXScanViewController *)openScannerWithParam:(LBXScanViewStyle *)scanViewStyleParam {
    
    SubLBXScanViewController *vc = [SubLBXScanViewController new];
    
    LBXScanViewStyle *style = scanViewStyleParam;
    
    vc.style = style;
    
    vc.isQQSimulator = YES;
    vc.isVideoZoom = YES;

    return vc;
    
   
}


- (void)showError:(NSString*)str
{
    [LBXAlertAction showAlertWithTitle:@"提示" msg:str chooseBlock:nil buttonsStatement:@"知道了", nil];
     
}


@end
