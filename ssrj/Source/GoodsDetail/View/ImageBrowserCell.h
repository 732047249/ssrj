//
//  ImageBrowserCell.h
//  ssrj
//
//  Created by MFD on 16/8/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailImageBrowsweModel.h"
#import "ImageItemScrollView.h"

@interface ImageBrowserCell : UICollectionViewCell

@property (nonatomic,strong) DetailImageBrowsweModel* imageModel;
@property (nonatomic,strong) ImageItemScrollView* imageItem;


@end
