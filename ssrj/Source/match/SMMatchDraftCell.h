//
//  SMMatchDraftCell.h
//  ssrj
//
//  Created by MFD on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
// 草稿cell

#import <UIKit/UIKit.h>
@interface SMMatchDraftCell : UICollectionViewCell

@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,assign)BOOL isShowDeleteBtn;
@property (nonatomic,copy) void (^deleteBlock)();
@end
