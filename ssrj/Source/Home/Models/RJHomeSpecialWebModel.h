//
//  RJHomeSpecialWebModel.h
//  ssrj
//
//  Created by CC on 16/9/30.
//  Copyright © 2016年 ssrj. All rights reserved.
//
/**
 *   "id": 513,
 "path": "http://www.ssrj.com/upload/image/201609/2f2cc663-68b2-4870-acb2-22e540c09601.jpg",
 "isThumbsup": false,
 "url": "http://www.ssrj.com/mobile/app_lasvega.html",
 "share_url": "https://api.ssrj.com/api/v3/member/share/homePopShare.jhtml",
 "shareType": "0,1,2,3,4",
 "login": true
 */
#import <JSONModel/JSONModel.h>

@interface RJHomeSpecialWebModel : JSONModel
@property (strong, nonatomic) NSNumber<Optional> * id;
@property (strong, nonatomic) NSNumber<Optional> * isThumbsup;
@property (strong, nonatomic) NSString<Optional> * show_url;
@property (strong, nonatomic) NSString<Optional> * share_url;
@property (strong, nonatomic) NSString<Optional> * shareType;
@property (strong, nonatomic) NSNumber<Optional> * isLogin;
@property (strong, nonatomic) NSString<Optional> * path;



@end
