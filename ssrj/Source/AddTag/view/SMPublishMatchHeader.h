//
//  SMPublishMatchHeader.h
//  ssrj
//
//  Created by MFD on 16/11/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SMPlaceHolderTextView.h"

@interface SMPublishMatchHeader : UIView

@property (nonatomic,strong)UITextField *matchNameTF;
@property (nonatomic,strong)SMPlaceHolderTextView *matchDiscriptTF;
@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UILabel *addThemeLabel;
@property (nonatomic,strong)UITextField *searchTF;

@end
