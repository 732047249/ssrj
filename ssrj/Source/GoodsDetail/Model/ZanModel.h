//
//  ZanModel.h
//  ssrj
//
//  Created by MFD on 16/7/28.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ZanModel : JSONModel
@property (nonatomic,strong) NSNumber *state;
@property (nonatomic,strong) NSString<Optional> *msg;
@property (nonatomic,strong) NSNumber<Optional> *data;
@property (nonatomic,strong) NSString<Optional> *token;
@end
