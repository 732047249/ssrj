//
//  ImageBrowserFlowLayout.m
//  ssrj
//
//  Created by MFD on 16/8/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ImageBrowserFlowLayout.h"

@implementation ImageBrowserFlowLayout

-(id)init {
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(SCREEN_WIDTH + 10.0f, SCREEN_HEIGHT);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 0.0f;
        self.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    }
    return self;
}


@end
