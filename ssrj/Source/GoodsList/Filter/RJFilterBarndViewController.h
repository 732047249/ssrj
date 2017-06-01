//
//  RJFilterBarndViewController.h
//  ssrj
//
//  Created by CC on 16/7/2.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"

@interface RJFilterBarndViewController : RJBasicViewController
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSMutableArray * selectIdArray;


@end

@interface RJFilterBarndViewCell: UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView * selectImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@end