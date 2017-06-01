//
//  RJRecommentGoodViewController.h
//  ssrj
//
//  Created by CC on 16/8/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDiarySegmentControl.h"
#import "STCollectionView.h"
@class RJZhuShouViewController;
@interface RJRecommentGoodViewController : UICollectionViewController
@property (assign, nonatomic) id<CCDiaryTopBarChanegNumberDelegate> delegate;
@property (strong, nonatomic) NSDictionary * parameterDictionary;
@property (strong, nonatomic) NSMutableArray * sceneArray;
@property (strong, nonatomic) STCollectionView * stCollectionView;
@property (nonatomic,weak) RJZhuShouViewController * fatherViewController;

- (void)sceneDataChanged:(NSMutableArray *)arr;
@end

