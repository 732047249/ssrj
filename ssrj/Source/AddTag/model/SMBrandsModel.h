//
//  SMBrandsModel.h
//  ssrj
//
//  Created by MFD on 16/11/7.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMBrandsModel : JSONModel
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *ID;
/** 搜索关键字相匹配的文字加粗 */
@property (nonatomic,strong)NSMutableAttributedString<Optional> *attributeString;

@end
