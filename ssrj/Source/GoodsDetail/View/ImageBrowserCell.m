//
//  ImageBrowserCell.m
//  ssrj
//
//  Created by MFD on 16/8/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ImageBrowserCell.h"

@implementation ImageBrowserCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.imageItem = [[ImageItemScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [self.contentView addSubview:self.imageItem];
    }
    return self;
}

- (void)setImageModel:(DetailImageBrowsweModel *)imageModel {
    if (_imageModel != imageModel) {
        _imageModel = imageModel;
    }
    self.imageItem.imageModel = self.imageModel;
}


@end
