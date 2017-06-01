//
//  RJHomeShareViewController.h
//  ssrj
//
//  Created by CC on 16/7/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@interface RJHomeShareViewController : RJBasicViewController

@end



@interface RJHomeShareModel : JSONModel
@property (strong, nonatomic) NSString * content;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * share_img;
@property (strong, nonatomic) NSNumber * isAvailable;
@property (strong, nonatomic) NSString * url;
@property (strong, nonatomic) NSString * redirectUrl;

@end