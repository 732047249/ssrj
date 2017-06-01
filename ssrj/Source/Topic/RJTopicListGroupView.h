//
//  RJTopicListGropView.h
//  ssrj
//
//  Created by CC on 16/11/18.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RJTopicListGroupViewDelegate <NSObject>
- (void)didSelectItemWithCatagoryId:(NSNumber *)selectId name:(NSString *)name;
@end


@interface RJTopicListGroupView : UICollectionView
@property (nonatomic,strong) NSMutableArray * dataArray;
@property (nonatomic,strong) NSNumber * selectId;
@property (nonatomic,weak) id<RJTopicListGroupViewDelegate> groupDelegate;
- (void)initCommon;
@end




@interface RJTopicListGroupViewCell : UICollectionViewCell
@property (nonatomic,strong) UIButton * button;
@property (nonatomic,strong) UIImageView * iconImageView;
@end