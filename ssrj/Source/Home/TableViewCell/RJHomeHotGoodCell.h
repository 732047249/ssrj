//
//  RJHomeHotGoodCell.h
//  ssrj
//
//  Created by CC on 16/12/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RJHomeHotGoodModel,RJBaseGoodModel;
@protocol RJHomeHotGoodCellDelegate <NSObject>
@optional
- (void)hotCellDidTapedGoodWithId:(NSNumber *)goodId;
@end


@interface RJHomeHotGoodCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) RJHomeHotGoodModel * model;
@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (nonatomic, assign) id<RJHomeHotGoodCellDelegate> delegate;

@end
