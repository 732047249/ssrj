//
//  ActivityModel.h
//  ssrj
//
//  Created by MFD on 16/8/9.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

//isLogin":true,"id":297,"share_url":"http://www.ssrj.com/activity/hd/dparty/dparty.jhtml","name":"test","image":null,"show_url":"http://www.ssrj.com/activity/hd/dparty/dparty.jhtml

@protocol  ActivityDataModel<NSObject>
@end
@interface  ActivityDataModel: JSONModel
@property (nonatomic,strong)NSNumber <Optional>*isLogin;
@property (nonatomic,strong)NSNumber<Optional> *id;
@property (nonatomic,strong)NSString <Optional>*name;
@property (nonatomic,strong)NSString<Optional> *image;
@property (nonatomic,strong)NSString<Optional> *show_url;
@property (nonatomic,strong)NSString<Optional> *share_url;
/**
 *  新增支持的分享平台 0,1,2,3 
    0代表微信
    1代表朋友圈
    2代表微博
    3代表qq朋友
    4代表qq空间
 */
@property (strong, nonatomic) NSString<Optional> * shareType;
@end

@interface ActivityModel : JSONModel
@property (nonatomic,strong)NSString <Optional>*activityVersion;
@property (nonatomic,strong)NSString <Optional>*appVersion;
//@property (nonatomic,strong)NSString <Optional>*token;
@property (nonatomic,strong)NSArray <Optional,ActivityDataModel>*data;
//@property (nonatomic,strong)NSNumber <Optional>*state;
//@property (nonatomic,strong)NSString <Optional>*msg;

@end



