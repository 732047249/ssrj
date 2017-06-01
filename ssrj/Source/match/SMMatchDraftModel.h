//
//  SMMatchDraftModel.h
//  ssrj
//
//  Created by MFD on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
//草稿箱中的cell模型
@interface SMMatchDraftModel : JSONModel

@property (nonatomic,strong)NSString *draft;
@property (nonatomic,strong)NSString *image;
@property (nonatomic,strong)NSString<Optional> *memo;
@property (nonatomic,strong)NSString *ID;
@property (nonatomic,strong)NSString *name;
@end
