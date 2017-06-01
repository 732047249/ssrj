//
//  SMMatchCutoutModel.h
//  ssrj
//
//  Created by MFD on 16/11/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface SMMatchCutoutModel : JSONModel
@property (nonatomic,strong)NSString *thumbnail;
@property (nonatomic,strong)NSString *image;
@property (nonatomic,strong)NSString *goods;
@property (nonatomic,strong)NSString *ID;
@property (nonatomic,strong)NSString *title;
//自己加的属相，用来记录cell是否选中。
@property (nonatomic,strong)NSNumber <Optional> *selected;
@end
