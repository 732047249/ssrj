//
//  SMAddTagViewController.h
//  ssrj
//
//  Created by MFD on 16/11/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"
#import "EditImageView.h"

@interface SMAddTagViewController : RJBasicViewController
/** 背景图 */
@property (nonatomic,strong)UIImage *image;
/** 添加标签 或 修改标签 */
- (void)addTagWithTagModel:(TagModel *)model;
@end
