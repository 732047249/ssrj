//
//  HHCollectionBorderCell.h
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HHCollectionBorderCell : UICollectionViewCell
//在setModel中调用
- (void)showAllLine;
//这两个方法要在setModel后调用
- (void)hiddenLeftLine;
- (void)hiddenTopLine;

@end
