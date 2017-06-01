//
//  ResetKeyViewController.h
//  ssrj
//
//  Created by YiDarren on 16/5/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@interface ResetKeyViewController : RJBasicViewController

@property (weak, nonatomic) IBOutlet UITextField *inputNewKeyText;

@property (strong, nonatomic) NSString *phone;

@property (strong, nonatomic) NSString *keyForReset;

@property (strong, nonatomic) NSNumber *phoneOrEmailStyle;//0为手机密码重置 1为邮箱密码重置

@end
