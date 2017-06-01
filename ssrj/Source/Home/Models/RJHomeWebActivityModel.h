//
//  RJHomeWebActivityModel.h
//  ssrj
//
//  Created by CC on 16/9/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
/**
 *  新增的在首页Cell中也能展示H5的活动
 */
@interface RJHomeWebActivityModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * path;
@property (strong, nonatomic) RJShareBasicModel<Optional> * inform;
@end
