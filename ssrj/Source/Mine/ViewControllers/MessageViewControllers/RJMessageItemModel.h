//
//  RJMessageItemModel.h
//  ssrj
//
//  Created by CC on 17/2/22.
//  Copyright © 2017年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
/**
 *  消息列表里面的消息Model
 */
@interface RJMessageItemModel : JSONModel
@property (nonatomic,strong) NSString * info_id;
@property (nonatomic,strong) NSString<Optional> * content;
@property (nonatomic,strong) NSNumber<Optional> * readed;
@property (nonatomic,strong) NSString<Optional> * create_time;
@property (nonatomic,strong) NSString<Optional> * title;
@property (nonatomic,strong) NSString<Optional> * image;
@property (nonatomic,strong) NSString<Optional> * type;
@property (nonatomic,strong) NSNumber * id;
@property (nonatomic,strong) NSString<Optional> * icon;

@end
