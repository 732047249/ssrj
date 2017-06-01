//
//  RJTopicCategoryModel.h
//  ssrj
//
//  Created by CC on 16/11/24.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJTopicCategoryModel : JSONModel
@property (nonatomic,strong) NSNumber * id;
@property (nonatomic,strong) NSString<Optional> * name;
@property (nonatomic,strong) NSString<Optional> * uncheckedImage;
@property (nonatomic,strong) NSString<Optional> * checkedImage;
@end
