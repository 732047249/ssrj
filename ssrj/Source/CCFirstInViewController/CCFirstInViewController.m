
#import "CCFirstInViewController.h"
#import "OLImage.h"
NSString *const CCFirstInVersionKey = @"CCFirstInVersionKey";

@interface CCFirstInViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView * collectionView;
@property (nonatomic,strong) NSMutableArray * dataArry;
@property (nonatomic,copy) void(^enterBlock)();
@end

@implementation CCFirstInViewController
+ (instancetype)newFirstInViewControllerWithImageName:(NSArray *)images enterBlock:(void(^)())enterBlock{
    CCFirstInViewController *vc = [[CCFirstInViewController alloc]init];
    vc.dataArry = [NSMutableArray arrayWithArray:[images copy]];
    vc.enterBlock = enterBlock;
    return vc;
}
// 是否应该显示版本新特性页面
+ (BOOL)canShowNewFeature{
    
    //系统直接读取的版本号
    NSString *versionValueStringForSystemNow = VERSION;
    //读取本地版本号
    NSString *versionLocal = [[NSUserDefaults standardUserDefaults]objectForKey:CCFirstInVersionKey];
    if(versionLocal!=nil && [versionValueStringForSystemNow isEqualToString:versionLocal]){//说明有本地版本记录，且和当前系统版本一致
        
        return NO;
        
    }else{ // 无本地版本记录或本地版本记录与当前系统版本不一致
        
        //保存
        [[NSUserDefaults standardUserDefaults]setObject:versionValueStringForSystemNow forKey:CCFirstInVersionKey];
        
        return YES;
    }
}
- (void)viewDidLoad{
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.itemSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self.collectionView registerClass:[CCFirstInViewGifImageCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArry.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CCFirstInViewGifImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *imgName = self.dataArry[indexPath.row];
    cell.gifImageView.image = [OLImage imageNamed:imgName];

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArry.count -1) {
        if (self.enterBlock) {
            self.enterBlock();
        }
    }
  
}
@end


@implementation CCFirstInViewGifImageCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.gifImageView = [[OLImageView alloc]initWithFrame:CGRectZero];
        self.gifImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_gifImageView];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    self.gifImageView.frame = self.contentView.bounds;
    
//    self.imageView.frame = self.contentView.bounds;
}
- (void)prepareForReuse{
    [super prepareForReuse];
    self.gifImageView.image = nil;
}

@end
