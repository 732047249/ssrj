
#import "RJTopicListGroupView.h"
#import "RJTopicCategoryModel.h"
#import "UIButton+WebCache.h"
#import "Masonry.h"
@interface RJTopicListGroupView ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (nonatomic,strong) UIActivityIndicatorView * activityView;
@property (nonatomic,strong) UIButton * reloadButton;
@end

@implementation RJTopicListGroupView
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        [self initCommon];
//    }
//    return self;
//}
//- (instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initCommon];
//    }
//    return self;
//}

- (void)initCommon{
    self.delegate = self;
    self.dataSource = self;
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
    }
    [self registerClass:[RJTopicListGroupViewCell class] forCellWithReuseIdentifier:@"Cell"];
    self.backgroundColor = APP_BASIC_COLOR;
    self.activityView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    self.activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self.activityView startAnimating];
    self.activityView.center = self.center;
    [self addSubview:_activityView];

    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    self.reloadButton = [UIButton buttonWithType:0];
    self.reloadButton.frame = CGRectMake(0, 0, self.width, self.height/2);
    [self addSubview:_reloadButton];

    [self.reloadButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    [self.reloadButton addTarget:self action:@selector(getCategoryData) forControlEvents:UIControlEventTouchUpInside];
    self.reloadButton.hidden = YES;
    [self.reloadButton setTitle:@"点击重新加载" forState:0];
    [self getCategoryData];
    
    [self reloadData];
    

}
- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)getCategoryData{
    self.reloadButton.hidden = YES;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"https://b82.ssrj.com/api/v5/index/infromcategorylist";
    requestInfo.modelClass = [RJBasicModel class];
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        RJBasicModel *basicModel = responseObject;
        if (basicModel.state.intValue == 0) {
            NSArray *dataArr = (NSArray *)basicModel.data;
            if (!dataArr.count) {
                weakSelf.activityView.hidden = YES;
                return ;
            }
            [weakSelf.dataArray removeAllObjects];
            
            for (NSDictionary *dic  in dataArr) {
                RJTopicCategoryModel *itemModel = [[RJTopicCategoryModel alloc]initWithDictionary:dic error:nil];
                if (itemModel) {
                    [weakSelf.dataArray addObject:itemModel];
                }
            }
            [weakSelf reloadData];
            
        }else{
            self.reloadButton.hidden = NO;
        }
        weakSelf.activityView.hidden = YES;

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        weakSelf.activityView.hidden = YES;
        self.reloadButton.hidden = NO;
    }];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RJTopicListGroupViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    RJTopicCategoryModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.id.intValue];
//    cell.button = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.id.intValue];
    [cell.button sd_setImageWithURL:[NSURL URLWithString:model.uncheckedImage] forState:0 placeholderImage:GetImage(@"default_1x1")];
    [cell.button sd_setImageWithURL:[NSURL URLWithString:model.checkedImage] forState:UIControlStateSelected placeholderImage:GetImage(@"default_1x1")];

//    [cell.button sd_setBackgroundImageWithURL:[NSURL URLWithString:model.uncheckedImage] forState:0 placeholderImage:GetImage(@"default_1x1")];
//    [cell.button sd_setBackgroundImageWithURL:[NSURL URLWithString:model.checkedImage] forState:UIControlStateSelected placeholderImage:GetImage(@"default_1x1")];
    
    cell.button.selected = NO;
    if (self.selectId.intValue == model.id.intValue) {
        cell.button.selected = YES;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    RJTopicCategoryModel *model = self.dataArray[indexPath.row];
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [[RJAppManager sharedInstance] trackingWithTrackingId:cell.trackingId];
    
    self.selectId = model.id;
    [self reloadData];
    if (self.groupDelegate && [self.groupDelegate respondsToSelector:@selector(didSelectItemWithCatagoryId:name:)]) {
        [self.groupDelegate didSelectItemWithCatagoryId:self.selectId name:model.name];
    }

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat wh = (collectionView.bounds.size.width - 60)/3.0;
    return CGSizeMake(wh, wh - 15);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 20, 0, 20);
}
@end


/**
 *  RJTopicListGropViewCell.m
 */
@implementation RJTopicListGroupViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.button = [UIButton buttonWithType:0];
        self.button.frame = CGRectMake(0, 0, self.contentView.width/2, self.contentView.width/2);
//        [self.button setBackgroundColor:[UIColor yellowColor]];
        [self.button setTitle:@"" forState:0];
        [self.contentView addSubview:_button];
        self.button.userInteractionEnabled = NO;
        self.button.center = self.contentView.center;
        self.button.imageView.contentMode = UIViewContentModeScaleAspectFit;

//        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.button.width/2, self.button.width/2)];
//        self.iconImageView.contentMode =  UIViewContentModeScaleToFill;
//        [self.contentView addSubview:_iconImageView];
//        self.iconImageView.center = self.button.center;
    }
    return self;
}

@end
