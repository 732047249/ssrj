//
//  RJBrandModel.h
//  ssrj
//
//  Created by MFD on 16/6/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol data_Model;
@protocol category_data_Model;

@class category_data_Model;
@interface RJBrandModel : JSONModel
@property (nonatomic, strong)NSString<Optional> *token;
@property (nonatomic, strong)NSArray<data_Model,Optional> *data;
@property (nonatomic, strong)NSNumber *state;
@property (nonatomic, strong)NSString *msg;
@end


@protocol data_Model <NSObject>

@end
@interface data_Model : JSONModel
@property (nonatomic, strong)NSString<Optional> *category;
@property (nonatomic, strong)NSArray<category_data_Model,Optional> *category_data;
@end


@protocol  category_data_Model<NSObject>

@end
@interface category_data_Model : JSONModel
@property (nonatomic, strong) NSNumber *goodsId;
@property (nonatomic, strong) NSString<Optional> *brandFootage;
@property (nonatomic, strong) NSString<Optional> * logo;
@property (nonatomic, strong) NSString<Optional> * initial;
@property (nonatomic, strong) NSString<Optional> * name;
@property (nonatomic, strong) NSString<Optional> * shortName;
@property (nonatomic, strong) NSString<Optional> * url;

@end


