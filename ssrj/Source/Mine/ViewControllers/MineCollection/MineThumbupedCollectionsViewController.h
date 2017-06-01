//
//  MineThumbupedCollectionsViewController.h
//  ssrj
//
//  Created by YiDarren on 16/8/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol MineThumbupedCollectionsViewControllerDelegate <NSObject>

@end
@interface MineThumbupedCollectionsViewController : RJBasicViewController

@property (nonatomic,strong)NSDictionary * parameterDictionary;
@property (weak, nonatomic) id<MineThumbupedCollectionsViewControllerDelegate>delegate;

@end
