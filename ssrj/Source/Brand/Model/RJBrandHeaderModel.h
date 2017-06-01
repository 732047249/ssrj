//
//  RJBrandHeaderModel.h
//  ssrj
//
//  Created by CC on 16/9/13.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface RJBrandHeaderModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * brandImg2;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSNumber<Optional> * isSubscribe;
@property (strong, nonatomic) NSNumber<Optional> * fansCount;
@property (strong, nonatomic) NSNumber<Optional> *subscribeCount;
/**
 *  3.0.0
 */
@property (strong, nonatomic) NSNumber<Optional> * goodsCount;
@property (strong, nonatomic) NSNumber<Optional> * releaseCount;
@property (strong, nonatomic) NSNumber<Optional> * thumbupCount;


@end
