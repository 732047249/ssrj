
#import "CCFirstInView.h"

@interface CCFirstInView ()
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic, assign) NSInteger index;
@end

@implementation CCFirstInView

- (instancetype)initWithImageArray:(NSMutableArray *)imageArray localIdentify:(NSString *)localIdentify{
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.imagesNames = [NSMutableArray arrayWithArray:[imageArray copy]];
        self.localIdentify = localIdentify;
        self.backgroundColor = [UIColor clearColor];
        self.imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        self.imageView.userInteractionEnabled = YES;
        if (self.imagesNames.count) {
            self.imageView.image = GetImage(self.imagesNames.firstObject);
            self.index = 0;
        }
        UITapGestureRecognizer *tapGesutre = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureAction:)];
        [self.imageView addGestureRecognizer:tapGesutre];
        [self addSubview:self.imageView];
    }
    return self;
}
- (void)tapGestureAction:(UITapGestureRecognizer *)sender{
    self.index ++;
    if (self.index == self.imagesNames.count) {
        [self close];
    }else{
        self.imageView.image = GetImage(self.imagesNames[self.index]);
    }
}
- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
}
- (void)close{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:self.localIdentify];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self removeFromSuperview];
}
@end
