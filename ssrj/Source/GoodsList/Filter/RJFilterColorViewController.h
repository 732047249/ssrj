//
//  RJFilterColorViewController.h
//  ssrj
//
//  Created by CC on 16/7/3.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@interface RJFilterColorViewController : RJBasicViewController
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSMutableArray * selectIdArray;

@end



@interface RJFilterColorTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView * selectImageView;
@property (weak, nonatomic) IBOutlet UILabel * nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView * colorImageView;

@end