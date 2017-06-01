//
//  SMGoodsModel.h
//  ssrj
//
//  Created by MFD on 16/11/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMGoodsModel : JSONModel
@property (nonatomic,strong)NSString *ID;
@property (nonatomic,assign)CGFloat price;
@property (nonatomic,assign)CGFloat market_price;
@property (nonatomic,strong)NSString *brand_name;
@property (nonatomic,strong)NSString <Optional>*brand;
@property (nonatomic,strong)NSString <Optional>*name;
@property (nonatomic,strong)NSString <Optional>*image;

@property (nonatomic,strong)NSMutableAttributedString<Ignore> *attributeString;

@end
