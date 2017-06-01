
#import "RJHomeSpecialWebModel.h"

@interface RJHomeSpecialWebModel ()
@end

@implementation RJHomeSpecialWebModel
+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc]initWithDictionary:@{@"url":@"show_url",@"login":@"isLogin"}];
}
@end
