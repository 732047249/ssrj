//
//  A-Z_brandsTableVIew.h
//  categoryDemo
//
//  Created by MFD on 16/5/25.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBrandModel.h"

@protocol brandsTableViewCellDelegate <NSObject>
- (void)didSelectCell:(NSString *)parameterName and:(NSNumber *)parameterId;
@end

@interface A_Z_brandsTableVIew : UITableView

@property (nonatomic,weak)id<brandsTableViewCellDelegate> brandsCellDelegate;

@property (nonatomic,strong) NSArray *brandsArray;

@end
