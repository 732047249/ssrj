//
//  RJHomeActivityTableViewCell.h
//  ssrj
//
//  Created by CC on 16/9/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RJHomeWebActivityModel;
@interface RJHomeActivityTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *activeImageView;
@property (strong, nonatomic) RJHomeWebActivityModel * normalModel;
@end
