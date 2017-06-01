
#import "CCAppVersionModel.h"

@interface CCAppVersionModel ()
@end

@implementation CCAppVersionModel
+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"url": @"URI",
                                                       @"release_note": @"releaseNote",
                                                       @"required": @"minimalRequiredVersion"
                                                       }];
}


@end
