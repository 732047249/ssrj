//
//  RJShareBasicModel.h
//  ssrj
//
//  Created by CC on 16/9/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
/**
 *  分享信息模型 所有都为可选
    尽量使用这个模型 以后其余单独建立的模型讲逐步废除
 */
@interface RJShareBasicModel : JSONModel
@property (strong, nonatomic) NSString<Optional> * title;
@property (strong, nonatomic) NSString<Optional> * memo;
@property (strong, nonatomic) NSString<Optional> * img;
@property (strong, nonatomic) NSString<Optional> * showUrl;
@property (strong, nonatomic) NSString<Optional> * shareUrl;
@property (nonatomic,strong) NSNumber<Optional> * id;
@property (nonatomic,strong) NSNumber<Optional> * isLogin;
@property (nonatomic,strong) NSString<Optional> * shareType;

/**
 *  上方H5 下方原生 扩展
 */
@property (nonatomic,strong) NSString<Optional> * tagsId;
@end
