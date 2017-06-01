//
//  CollectionViewCell.m
//  categoryDemo
//
//  Created by MFD on 16/5/25.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell



- (void)awakeFromNib {
    self.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    self.imageView.image = nil;
    
}


- (void)prepareForReuse{
    self.backgroundColor = [UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1];
    self.imageView.image = nil;
}

@end
