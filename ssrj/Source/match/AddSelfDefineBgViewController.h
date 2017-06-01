//
//  AddSelfDefineBgViewController.h
//  ssrj
//
//  Created by YiDarren on 16/10/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"
#import "SelfDefinedModel.h"

@interface AddSelfDefineBgViewController : RJBasicViewController

@property (nonatomic,copy)void (^selectedBgBlock)(BackgroundModel *);
@end






@interface AddSelfDefineBgViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@end
