
#import "RJAliPayManager.h"

@interface RJAliPayManager ()
@end

@implementation RJAliPayManager

+ (instancetype)shareInstance{
    static dispatch_once_t onceToken;
    static RJAliPayManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[RJAliPayManager alloc] init];
    });
    return instance;
}

@end
