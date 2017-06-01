//
//  YYLabelLayoutModel.h
//  ssrj
//
//  Created by MFD on 16/9/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYText.h"

@interface YYLabelLayoutModel : NSObject

@property (nonatomic,strong)YYTextLayout *textLayout;
@property (nonatomic,assign)CGFloat cellHeight;

@end
