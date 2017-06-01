//
//  HHInforMatchCell.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/11.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforMatchCell.h"
#import "HHInforMatchGoodsCell.h"
#import "Masonry.h"
#define kLineH 7
@interface HHInforMatchCell()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) UIImageView *bigImageView;
@property (nonatomic,strong) UIImageView *lineImageView;
@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray *dataArray;

@end
@implementation HHInforMatchCell
// height = kScreenWidth + (kScreenWidth / 3.0 + 59)

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.clipsToBounds = YES;
        _dataArray = [NSMutableArray array];
        _bigImageView = [[UIImageView alloc] init];
        _bigImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_bigImageView];
        [_bigImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.left.equalTo(self);
            make.height.mas_equalTo(kScreenWidth);
        }];
        
        [self configCollectionView];
        
        _lineImageView = [[UIImageView alloc] init];
        _lineImageView.contentMode = UIViewContentModeCenter;
        _lineImageView.image = GetImage(@"infor_match_line");
        [self.contentView addSubview:_lineImageView];
        [_lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.mas_equalTo(_bigImageView.mas_bottom);
            make.height.mas_equalTo(kLineH);
        }];
        
        
    }
    return self;
}
- (void)setModel:(RJHomeItemTypeTwoModel *)model {
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:model.goodsList];
    [_collectionView reloadData];
    [_bigImageView sd_setImageWithURL:[NSURL URLWithString:model.path] placeholderImage:GetImage(@"match_placeholder")];
}
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = kScreenWidth / 3.0;
    CGFloat cellHeight = cellWidth + 59;
    layout.itemSize = CGSizeMake(cellWidth, cellHeight);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.scrollEnabled = NO;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[HHInforMatchGoodsCell class] forCellWithReuseIdentifier:@"HHInforMatchGoodsCell"];
    [self.contentView addSubview:_collectionView];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(cellHeight);
        make.top.equalTo(_bigImageView.mas_bottom);
    }];
    
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HHInforMatchGoodsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HHInforMatchGoodsCell" forIndexPath:indexPath];
    cell.model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    RJBaseGoodModel *model = self.dataArray[indexPath.row];
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    
    
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}
@end
