//
//  ImageItemScrollView.h
//  ssrj
//
//  Created by MFD on 16/8/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DetailImageBrowsweModel.h"

@protocol ImageItemEventDelegate <NSObject>

- (void)didClickedItemToHide;
- (void)didFinishRefreshThumbnailImageIfNeed;

@end


@interface ImageItemScrollView : UIScrollView

@property (nonatomic,weak) id <ImageItemEventDelegate> eventDelegate;

@property (nonatomic,strong) DetailImageBrowsweModel* imageModel;
@property (nonatomic,strong) UIImageView* imageView;
@property (nonatomic,assign,getter=isFirstShow) BOOL firstShow;

- (void)loadHdImage:(BOOL)animated;

@end
