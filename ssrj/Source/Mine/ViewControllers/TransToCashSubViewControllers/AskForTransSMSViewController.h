//
//  AskForTransSMSViewController.h
//  ssrj
//
//  Created by YiDarren on 16/9/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@interface AskForTransSMSViewController : RJBasicViewController

@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSMutableDictionary *paramDictionary;
@property (assign, nonatomic) BOOL isTelephoneRegistered;

@end
