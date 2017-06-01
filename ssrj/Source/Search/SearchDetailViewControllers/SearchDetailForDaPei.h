//
//  SearchDetailForDaPei.h
//  ssrj
//
//  Created by YiDarren on 16/8/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJBasicViewController.h"

@protocol SearchDetailForDaPeiDelegate <NSObject>

@end
@interface SearchDetailForDaPei : RJBasicViewController

@property (nonatomic,strong)NSDictionary * parameterDictionary;
@property (weak, nonatomic) id<SearchDetailForDaPeiDelegate>delegate;
@property (strong, nonatomic) NSString *searchWord;

@end
