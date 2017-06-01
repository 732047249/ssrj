//
//  RJAnswerTwoModel.h
//  ssrj
//
//  Created by CC on 16/8/6.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@class RJSubAnswerModel;
@protocol RJSubAnswerModel;

@interface RJAnswerTwoModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * title;
@property (strong, nonatomic) NSNumber<Optional> * options;
@property (strong, nonatomic) NSString<Optional> * answered;
@property (strong, nonatomic) NSArray<RJSubAnswerModel,Optional>*answers;
@end



@protocol RJSubAnswerModel <NSObject>


@end


@interface RJSubAnswerModel : JSONModel
@property (strong, nonatomic) NSNumber * id;
@property (strong, nonatomic) NSString<Optional> * name;
@property (strong, nonatomic) NSString<Optional> * image;
@property (strong, nonatomic) NSString<Optional> * memo;
@end