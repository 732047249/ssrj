//
//  RJCommentListModel.h
//  ssrj
//
//  Created by CC on 16/12/28.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>
#import "YYText.h"
/**
 *  评论model  和之前建立的做区分
 */
@protocol RJCommentModel;
@protocol RJCommentMemberModel;
@class RJCommentMemberModel;

@interface RJCommentListModel : JSONModel
@property (nonatomic,strong)NSNumber<Optional>* id;
@property (nonatomic,strong)NSNumber<Optional>* countComment;
@property (nonatomic,strong)NSArray<Optional,RJCommentModel>* commentList;
@end

@protocol RJCommentModel <NSObject>

@end
@interface RJCommentModel : JSONModel
@property (strong,nonatomic)RJCommentMemberModel<Optional>* replyMember;
@property (strong,nonatomic)RJCommentMemberModel<Optional>* member;
@property (strong,nonatomic)NSNumber<Optional>* isActiveUser;
@property (strong,nonatomic)NSString<Optional>* comment;
@property (strong,nonatomic)NSString<Optional>* createDate;
@property (strong,nonatomic)NSNumber<Optional>* commentId;
@property (nonatomic,strong) NSMutableAttributedString<Ignore> * attributeText;
@end

@protocol RJCommentMemberModel <NSObject>



@end
@interface RJCommentMemberModel : JSONModel
@property (strong,nonatomic)NSNumber<Optional> *memberId;
@property (strong,nonatomic)NSString<Optional> *mobile;
@property (strong,nonatomic)NSString<Optional> *name;
@property (strong,nonatomic)NSString<Optional> *avatar;
@property (strong,nonatomic)NSNumber<Optional> *userid;
@end