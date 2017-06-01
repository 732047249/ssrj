//
//  SMPublishMatchController.h
//  ssrj
//
//  Created by MFD on 16/11/5.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"


typedef NS_ENUM(NSInteger,SMPublishType) {
    SMPublishTypeMatch = 2,
    SMPublishTypeDraftMatch,
    SMPublishTypeTag
};

@interface SMPublishMatchController : RJBasicViewController
/**
 发布类型
 */
@property (nonatomic,assign)SMPublishType publishType;
/** 创建搭配--草稿id */
@property (nonatomic,strong) NSString *matchDraftId;

/** 创建或上传搭配--打标签预留字段 */
@property (strong, nonatomic) NSString *jsonString;

/** 上传搭配--背景图 or 创建搭配--截图 */
@property (strong, nonatomic) UIImage *image;
/** 上传搭配 or 创建搭配 商品id 和素材*/
@property (nonatomic,strong)NSArray *goodsIdArr;

//添加合辑标签
- (void)addWLabelDataWithDict:(NSDictionary *)dict;
@end
