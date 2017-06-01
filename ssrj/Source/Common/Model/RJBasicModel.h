//
//  RJBasicModel.h
//  ssrj
//
//  Created by CC on 16/5/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "JSONModel.h"

@interface RJBasicModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *msg;
@property (nonatomic, strong) NSNumber<Optional> *state;
@property (nonatomic, strong) NSString<Optional> *token;
@property (nonatomic,strong) id<Optional> data;
//@property (nonatomic, strong) NSString<Optional> *record_count;
//@property (nonatomic, strong) NSString<Optional> *page_count;

@end


