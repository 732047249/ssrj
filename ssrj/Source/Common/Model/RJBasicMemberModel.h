//
//  RJBasicMemberModel.h
//  ssrj
//
//  Created by CC on 16/12/6.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJBasicMemberModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * mobile;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSString<Optional> *avatar;
@property (strong, nonatomic) NSString<Optional> *userid;
@end
