//
//  cartOrBuyModel.h
//  ssrj
//
//  Created by MFD on 16/6/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface dataItem : JSONModel
@property (nonatomic, strong) NSString<Optional> *effectivePrice;
@property (nonatomic, strong) NSNumber<Optional> *productQuantity;
@property (nonatomic, strong) NSString<Optional> *cartItemId;
@end


@interface cartOrBuyModel : JSONModel
@property (nonatomic, strong) NSString<Optional> *token;
@property (nonatomic, strong) dataItem<Optional> *data;
@property (nonatomic, strong) NSNumber<Optional> *state;
@property (nonatomic, strong) NSString<Optional> *msg;
@end
