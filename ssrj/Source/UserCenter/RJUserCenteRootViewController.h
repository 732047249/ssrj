//
//  RJUserCenteRootViewController.h
//  ssrj
//
//  Created by CC on 16/9/21.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJBasicViewController.h"


@protocol RJTapedUserViewDelegate <NSObject>
@optional
- (void)didTapedUserViewWithUserId:(NSNumber *)userId;
- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString*)userName;

@end


@interface RJUserCenteRootViewController : RJBasicViewController
@property (strong, nonatomic) NSNumber * userId;
@property (strong, nonatomic) NSString * userName;
- (void)getUserHeaderData;
@end





@interface RJUserCenterHeaderModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSNumber<Optional> * subscribeCount;
@property (strong, nonatomic) NSString<Optional> * memberName;
@property (strong, nonatomic) NSString<Optional> * avatar;
@property (strong, nonatomic) NSNumber<Optional> * isSubscribe;
@property (strong, nonatomic) NSNumber<Optional> * fansCount;
@property (strong, nonatomic) NSNumber<Optional> * isSelf;
@property (strong, nonatomic) NSString<Optional> * introduction;
/**
 *  3.0.0
 */
@property (strong, nonatomic) NSNumber<Optional> * releaseCount;
@property (strong, nonatomic) NSNumber<Optional> * thumbupCount;
@property (strong, nonatomic) NSString<Optional> * attributeValue1;
/*
 * 3.0.1
 */
@property (strong, nonatomic) NSNumber<Optional> * recommendationCount;

@end