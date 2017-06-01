//
//  TagModel.h
//  20161101
//
//  Created by MFD on 16/11/2.
//  Copyright © 2016年 MFD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SMGoodsModel.h"


typedef NS_ENUM(NSInteger,TagDirectionType) {
    TagDirectionTypeLeft,//默认，小点在左边
    TagDirectionTypeRight
};
@interface TagModel : NSObject

/**
 记录标签信息
 */

@property (nonatomic,strong)NSString *tagText;
@property (nonatomic,strong)NSString *brandId;
@property (nonatomic,strong)NSString *goodsId;
//记录标签的左边中点位置坐标
@property (nonatomic,assign)CGPoint point;
@property (nonatomic,assign)TagDirectionType direction;
//添加tag。不是编辑tag
@property (nonatomic,assign)BOOL isAddTag;

/**
 记录标签对应的商品信息。用cell
 */
@property (nonatomic,strong)SMGoodsModel *goodsModel;

@end
