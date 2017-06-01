//
//  HomeGoodListViewController.h
//  ssrj
//
//  Created by CC on 16/5/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCGoodOrderView.h"
#import "RJBasicViewController.h"
@interface HomeGoodListViewController : RJBasicViewController



@property (strong, nonatomic) NSDictionary * parameterDictionary;
//首页热卖进来 单独处理
@property (assign, nonatomic) BOOL isHot;
@property (nonatomic,strong) NSString * titleStr;
@end



@interface GoodListCollectionHeaderView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet CCGoodOrderView *orderView;

@end



@interface GoodListCollectionBannerView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView * bannerView;
@end


@interface RJSorteModel : NSObject
@property (strong, nonatomic) NSString * name;
@property (strong, nonatomic) NSString * value;
-(instancetype)initWithName:(NSString *)name value:(NSString *)value;
@end