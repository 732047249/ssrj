//
//  EditThemeManagerViewController.h
//  ssrj
//
//  Created by YiDarren on 16/12/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol EditThemeManagerViewControllerDelegate <NSObject>

- (void)reloadManagerThemeDataWithIndex:(NSInteger)index;

@end


@interface EditThemeManagerViewController : RJBasicViewController

@property (strong, nonatomic) NSNumber *themeId;

@property (strong, nonatomic) id<EditThemeManagerViewControllerDelegate>delegate;

@end
