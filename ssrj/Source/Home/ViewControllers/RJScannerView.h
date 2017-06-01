//
//  RJScannerView.h
//  ssrj
//
//  Created by YiDarren on 16/5/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SubLBXScanViewController.h"

@interface RJScannerView : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

+(BOOL)cameraAuthStatus;
+ (LBXScanViewStyle *)paramSet;
+ (SubLBXScanViewController *)openScannerWithParam:(LBXScanViewStyle *)scanViewStyleParam;
@end
