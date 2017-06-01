//
//  RJNetWorkMessageModel.h
//  ssrj
//
//  Created by CC on 16/6/4.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJNetWorkMessageModel : JSONModel
@property (strong, nonatomic) NSString * type;
@property (strong, nonatomic) NSString * content;
@end
