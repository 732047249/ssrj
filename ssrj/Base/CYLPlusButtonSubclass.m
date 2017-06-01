//
//  CYLPlusButtonSubclass.m
//  DWCustomTabBarDemo
//
//  Created by 微博@iOS程序犭袁 ( http://weibo.com/luohanchenyilong/ ) on 15/10/24.
//  Copyright (c) 2015年 https://github.com/ChenYilong . All rights reserved.
//

#import "CYLPlusButtonSubclass.h"
#import "CYLTabBarController.h"
#import "SMCreateMatchController.h"
#import "HHInformationViewController.h"
#import "ZHALAsset.h"
#import "HyPopMenuView.h"
//#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>



#import "AJPhotoPickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AJPhotoBrowserViewController.h"
#import "RJCreateTopicViewController.h"
#import "Masonry.h"
@interface CYLPlusButtonSubclass ()<UIActionSheetDelegate,HyPopMenuViewDelegate> {
    CGFloat _buttonImageHeight;
}

@end

@implementation CYLPlusButtonSubclass

#pragma mark -
#pragma mark - Life Cycle

+ (void)load {
    [super registerPlusButton];
    
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
        self.trackingId = @"HomeViewController&PlustButton";
    }
    return self;
}

//上下结构的 button
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 控件大小,间距大小
    // 注意：一定要根据项目中的图片去调整下面的0.7和0.9，Demo之所以这么设置，因为demo中的 plusButton 的 icon 不是正方形。
//    CGFloat const imageViewEdgeWidth   = self.bounds.size.width;
//    CGFloat const imageViewEdgeHeight  = imageViewEdgeWidth;
    
//    CGFloat const centerOfView    = self.bounds.size.width * 0.5;
//    CGFloat const labelLineHeight = self.titleLabel.font.lineHeight;
//    CGFloat const verticalMarginT = self.bounds.size.height - labelLineHeight - imageViewEdgeWidth;
//    CGFloat const verticalMargin  = verticalMarginT / 2;
    
    // imageView 和 titleLabel 中心的 Y 值
//    CGFloat const centerOfImageView  = verticalMargin + imageViewEdgeWidth * 0.5;
//    CGFloat const centerOfTitleLabel = imageViewEdgeWidth  + verticalMargin * 2 + labelLineHeight * 0.5 + 5;
    
    //imageView position 位置
    self.imageView.bounds = CGRectMake(0, 0, 38, 38);
//    self.imageView.center = CGPointMake(centerOfView, centerOfImageView);
    
    //title position 位置
//    self.titleLabel.bounds = CGRectMake(0, 0, self.bounds.size.width, labelLineHeight);
//    self.titleLabel.center = CGPointMake(centerOfView, centerOfTitleLabel);
}

#pragma mark -
#pragma mark - CYLPlusButtonSubclassing Methods

/*
 *
 Create a custom UIButton with title and add it to the center of our tab bar
 *
 */
+ (id)plusButton {
    CYLPlusButtonSubclass *button = [[CYLPlusButtonSubclass alloc] init];
    UIImage *buttonImage = [UIImage imageNamed:@"home_add"];
//    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setImage:buttonImage forState:UIControlStateNormal];
//    [button setTitle:@"发布" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
//    [button setTitle:@"选中" forState:UIControlStateSelected];
//    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];

//    button.titleLabel.font = [UIFont systemFontOfSize:9.5];
    [button sizeToFit]; // or set frame in this way `button.frame = CGRectMake(0.0, 0.0, 250, 100);`
    button.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH/5-5, 44);
//    button.backgroundColor = [UIColor redColor];
    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];
    return button;
}
/*
 *
 Create a custom UIButton without title and add it to the center of our tab bar
 *
 */
//+ (id)plusButton
//{
//
//    UIImage *buttonImage = [UIImage imageNamed:@"hood.png"];
//    UIImage *highlightImage = [UIImage imageNamed:@"hood-selected.png"];
//
//    CYLPlusButtonSubclass* button = [CYLPlusButtonSubclass buttonWithType:UIButtonTypeCustom];
//
//    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
//    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
//    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
//    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];
//
//    return button;
//}

#pragma mark -
#pragma mark - Event Response

- (void)clickPublish {

    
//    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
//    requestInfo.URLString = @"http://192.168.1.14:10003/api/v1/information/files";
//    UIImage *image1 = GetImage(@"f3占位");
//    UIImage *image2 = GetImage(@"smile");
//    ZHALAsset *asset = [[ZHALAsset alloc]init];
//    asset.image  = image1;
//    asset.name =  @"image1";
//    NSData *imagedata = UIImageJPEGRepresentation(image1, 0.2);
//    asset.imageData = imagedata;
//    
//    
//    ZHALAsset *asset2 = [[ZHALAsset alloc]init];
//    asset2.image  = image2;
//    asset2.name =  @"image2";
//    NSData *imagedata2 = UIImageJPEGRepresentation(image2, 0.2);
//    asset2.imageData = imagedata2;
//    
//    
//    [requestInfo.fileBodyParams addEntriesFromDictionary:@{@"file1":asset,@"file2":asset2}];
//    NSError __autoreleasing *e = nil;
//    
//   NSString *str = [NSString stringWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"test" ofType:@"html"] encoding:NSUTF8StringEncoding error:&e];
//    [requestInfo.postParams addEntriesFromDictionary:@{@"content":str,@"title":@"我是标题"}];
//    [[ZHNetworkManager sharedInstance]uploadWithRequestInfo:requestInfo uploadProgress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
//        
//    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"%@",responseObject);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"%@",error);
//
//    }];
    
    self.popMenu.backgroundType = HyPopMenuViewBackgroundTypeLightBlur;
    [_popMenu openMenu];
}


#pragma mark - CYLPlusButtonSubclassing

//+ (UIViewController *)plusChildViewController {
//    UIViewController *plusChildViewController = [[UIViewController alloc] init];
//    plusChildViewController.view.backgroundColor = [UIColor redColor];
//    plusChildViewController.navigationItem.title = @"PlusChildViewController";
//    UIViewController *plusChildNavigationController = [[UINavigationController alloc]
//                                                   initWithRootViewController:plusChildViewController];
//    return plusChildNavigationController;
//}


//+ (NSUInteger)indexOfPlusButtonInTabBar {
//    return 4;
//}
//
//+ (CGFloat)multiplierOfTabBarHeight:(CGFloat)tabBarHeight {
//    return  0.3;
//}
//
//+ (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
//    return  -10;
//}
#pragma mark -

-(HyPopMenuView *)popMenu{
    if (!_popMenu) {
        _popMenu = [HyPopMenuView sharedPopMenuManager];
        PopMenuModel* model = [PopMenuModel
                               allocPopMenuModelWithImageNameString:@"home_pop_1"
                               AtTitleString:@"上传图片"
                               AtTextColor:[UIColor grayColor]
                               AtTransitionType:PopMenuTransitionTypeCustomizeApi
                               AtTransitionRenderingColor:nil];
        PopMenuModel* model1 = [PopMenuModel
                                allocPopMenuModelWithImageNameString:@"home_pop_2"
                                AtTitleString:@"创建搭配"
                                AtTextColor:[UIColor grayColor]
                                AtTransitionType:PopMenuTransitionTypeSystemApi
                                AtTransitionRenderingColor:nil];
        
        PopMenuModel* model2 = [PopMenuModel
                                allocPopMenuModelWithImageNameString:@"home_pop_3"
                                AtTitleString:@"发布资讯"
                                AtTextColor:[UIColor grayColor]
                                AtTransitionType:PopMenuTransitionTypeCustomizeApi
                                AtTransitionRenderingColor:nil];
        _popMenu.dataSource = @[ model, model1, model2 ];
        _popMenu.delegate = self;
        _popMenu.popMenuSpeed = 15.0f;
        _popMenu.automaticIdentificationColor = NO;
        _popMenu.animationType = HyPopMenuViewAnimationTypeCenter;
        
        UIImageView *topView = [[UIImageView alloc]initWithFrame:CGRectZero];
        topView.backgroundColor = [UIColor clearColor];

        topView.image = GetImage(@"广告图");
        CGFloat imageW = topView.image.size.width;
        CGFloat imageH = topView.image.size.height;
        
//        topView.width = imageW;
        topView.height = imageH;
        if (DEVICE_IS_IPHONE4) {
            topView.height = imageH - 90;
        }
        if (DEVICE_IS_IPHONE5) {
            topView.height = imageH - 20;
        }
        topView.width = topView.height / imageH *imageW;

        topView.center = CGPointMake(SCREEN_WIDTH/2, 0);
        topView.origin = CGPointMake(topView.frame.origin.x, 60);
//        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(_popMenu);
//        }];
        _popMenu.topView = topView;
        
           }
    return _popMenu;
}

#pragma mark - HyPopMenuViewDelegate
- (void)popMenuView:(HyPopMenuView*)popMenuView didSelectItemAtIndex:(NSUInteger)index{
//    PHFetchOptions *options = [[PHFetchOptions alloc] init];
//    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
//    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    // 这时 assetsFetchResults 中包含的，应该就是各个资源（PHAsset）
//    for (NSInteger i = 0; i < fetchResult.count; i++) {
//        // 获取一个资源（PHAsset）
//        PHAsset *asset = fetchResult[i];
//    }
    
    NSString *string = [NSString stringWithFormat:@"PlusButtonTappedId=%lu",(unsigned long)index];
    [[RJAppManager sharedInstance]trackingWithTrackingId:string];
    
    if (index == 0) {
        AJPhotoPickerViewController *picker = [[AJPhotoPickerViewController alloc] init];
        picker.isUseToTag = YES;
        picker.assetsFilter = [ALAssetsFilter allPhotos];
        picker.showEmptyGroups = YES;
        //        picker.delegate=self;
        picker.minimumNumberOfSelection = 1;
        picker.maximumNumberOfSelection = 9;
        picker.multipleSelection = NO;
        picker.shouldClip = YES;
        picker.cropMode = RSKImageCropModeSquare;

        picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
            return YES;
        }];
        
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:picker];
        [nav setNavigationBarHidden:YES];
        UIViewController *vc = [self.popMenu currentViewController];
        [vc presentViewController:nav animated:YES completion:nil];
        

    }else if (index == 1){
        SMCreateMatchController *add = [SMCreateMatchController new];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:add];
        UIViewController *vc = [self.popMenu currentViewController];
        [vc presentViewController:nav animated:YES completion:nil];
    }else{
        HHInformationViewController *createVc = [[HHInformationViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:createVc];
        
        UIViewController *vc = [self.popMenu currentViewController];
        [vc presentViewController:nav animated:YES completion:^{
            
        }];
    }
    
    

}



@end
