
#import "RJSqlitManager.h"

@interface RJSqlitManager ()

@end

@implementation RJSqlitManager


+ (instancetype)sharedInstance {
	static RJSqlitManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}
- (void)openDBWithPath:(NSString *)dbPath{
    self.dbHelper = [[LKDBHelper alloc]initWithDBPath:dbPath];
}
- (void)closeDB{
    
}
@end
