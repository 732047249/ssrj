
#import "RJTrackingModel.h"
#import "LKDBHelper.h"
@interface RJTrackingModel ()
@end

@implementation RJTrackingModel

+(NSString *)getPrimaryKey
{
    return @"id";
}
+(NSString *)getTableName
{
    return @"RJTrackingTable";
}
@end



@implementation RJTrackingArrayModel



@end


@implementation RJTrackingJsonStringModel

+(NSString *)getTableName
{
    return @"RJTrackingJsonTable";
}
+(NSString *)getPrimaryKey
{
    return @"id";
}
@end