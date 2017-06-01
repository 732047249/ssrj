//
//  ColorSelfDefinedModel.h
//  ssrj
//
//  Created by YiDarren on 16/10/31.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol SMBackgroundDraftModel <NSObject>

@end
@interface SelfDefinedModel : JSONModel

@end

@interface ColorModel : JSONModel

@property (strong, nonatomic) NSString <Optional> *color_value;
@property (strong, nonatomic) NSString <Optional> *picture;
@property (strong, nonatomic) NSString <Optional> *colorId;
@property (strong, nonatomic) NSString <Optional> *title;


@end


@interface SceneModel : JSONModel

@property (strong, nonatomic) NSString <Optional> *image;
@property (strong, nonatomic) NSString <Optional> *title;
@property (strong, nonatomic) NSString <Optional> *sceneId;
@property (strong, nonatomic) NSString <Optional> *thumbnail;
@property (strong, nonatomic) NSString <Optional> *choice;//选中后的图片

@end


@interface BackgroundModel : JSONModel

@property (strong, nonatomic) NSString <Optional> *image;
@property (strong, nonatomic) NSString <Optional> *title;
@property (strong, nonatomic) NSString <Optional> *backgroundId;
@property (strong, nonatomic) NSString <Optional> *thumbnail;
@property (strong, nonatomic) NSArray <Optional> *draft;
//@property (strong, nonatomic) NSArray <SMBackgroundDraftModel,Optional>*draft;

@end

@interface SMBackgroundDraftModel : NSObject
@property (assign, nonatomic) BOOL flipX;
@property (assign, nonatomic) BOOL flipY;
@property (assign, nonatomic) CGFloat width;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat top;
@property (assign, nonatomic) CGFloat scaleX;
@property (assign, nonatomic) CGFloat scaleY;
@property (assign, nonatomic) CGFloat angle;
@property (strong, nonatomic) NSString *src;
@property (strong, nonatomic) NSString *type;
@end

@interface SMBackgroundSize : NSObject
//指的是height
@property (assign, nonatomic) CGFloat bottom;
@property (assign, nonatomic) CGFloat left;
@property (assign, nonatomic) CGFloat top;
//指的是width
@property (assign, nonatomic) CGFloat right;
@end
