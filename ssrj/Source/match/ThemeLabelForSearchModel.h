//
//  ThemeLabelForSearchModel.h
//  ssrj
//
//  Created by YiDarren on 16/11/10.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface ThemeLabelForSearchModel : JSONModel

@property (strong, nonatomic) NSNumber<Optional> *id;
@property (strong, nonatomic) NSString<Optional> *name;
@property (strong, nonatomic) NSNumber<Optional> *isPublish;

@end
