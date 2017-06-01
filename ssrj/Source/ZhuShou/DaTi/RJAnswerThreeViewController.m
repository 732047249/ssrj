
#import "RJAnswerThreeViewController.h"
#import "RJAnswerTwoModel.h"
#import "RJAnswerOneViewController.h"
@interface RJAnswerThreeViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSMutableArray * selectIdArray;
@property (strong, nonatomic) RJAnswerTwoModel * model;
@property (assign, nonatomic) BOOL  allLikeSelect;
@end

@implementation RJAnswerThreeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    self.allLikeSelect = NO;
    self.dataArray = [NSMutableArray array];
    self.selectIdArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
    }];
    [self.collectionView.mj_header beginRefreshing];
}
- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v3/goods/findfeatruegrouplist?quetionId=3"];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *arr = responseObject[@"data"];
                if (arr.count == 0) {
                    [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                    return;
                }
                NSDictionary *dic = arr.firstObject;
                NSError __autoreleasing *e = nil;
                RJAnswerTwoModel *model = [[RJAnswerTwoModel alloc]initWithDictionary:dic error:&e];
                if (model) {
                    weakSelf.model = model;
                    weakSelf.dataArray = [NSMutableArray arrayWithArray:[self.model.answers copy]];
                    
                    [self.selectIdArray removeAllObjects];

                    if (model.answered.length) {
                        //答过题 有答案
                        NSString *str = model.answered;
                        NSArray * arr = [str componentsSeparatedByString:@","];
                        self.selectIdArray  = [NSMutableArray arrayWithArray:arr];
                        
                    }
                    [weakSelf.collectionView reloadData];
                }else{
                    [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
                
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            
        }
        [self.collectionView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [self.collectionView.mj_header endRefreshing];
        
    }];

}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.dataArray.count) {
        return self.dataArray.count +1;
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArray.count) {
        //显示“都喜欢”的cell
        RJAnswerThreeNolikeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RJAnswerThreeNolikeCollectionCell" forIndexPath:indexPath];
        cell.selectImageView.highlighted = NO;
        if (self.allLikeSelect) {
            cell.selectImageView.highlighted = YES;
        }
        return cell;
    }
    RJAnswerThreeCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RJAnswerThreeCollectionCell" forIndexPath:indexPath];
    RJSubAnswerModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.id.intValue];
    [cell.colorImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"default_1x1")];
    cell.titleLabel.text = model.name;
    cell.selectImageView.highlighted = NO;
    if ([self.selectIdArray containsObject:[NSString stringWithFormat:@"%d",model.id.intValue]]) {
        cell.selectImageView.highlighted = YES;
    }
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        RJAnswerThreeCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RJAnswerThreeCollectionHeaderView" forIndexPath:indexPath];
        if (self.model) {
            header.titleLabel.text = self.model.title;
        }
        return header;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        RJAnswerThreeCollectionFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RJAnswerThreeCollectionFooterView" forIndexPath:indexPath];
        [footer.nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return footer;
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat f = SCREEN_WIDTH - 16 -16;
    CGFloat cellW = (f -1)/3;
    CGFloat imageW = cellW - 20;
    
    CGFloat cellH = 128 - 75 + imageW;
    return CGSizeMake(cellW, cellH);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.dataArray.count) {
        //都喜欢的cell
        self.allLikeSelect = !self.allLikeSelect;
        if (self.allLikeSelect) {
            [self.selectIdArray removeAllObjects];
        }
    }else{
        
        RJSubAnswerModel *model = self.dataArray[indexPath.row];
        if ([self.selectIdArray containsObject:[NSString stringWithFormat:@"%d",model.id.intValue]]) {
            [self.selectIdArray removeObject:[NSString stringWithFormat:@"%d",model.id.intValue]];
        }else{
            [self.selectIdArray addObject:[NSString stringWithFormat:@"%d",model.id.intValue]];
            self.allLikeSelect = NO;
        }

    }
    /**
     *  因为这里reloadData了 Tracking哪里抓取不到cell 统计写到这里 性能考虑 不再替换Tacking时候的调用顺序
     */
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:cell.trackingId];
    }
    [self.collectionView reloadData];
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"穿衣助手问题三"];
    [TalkingData trackPageBegin:@"穿衣助手问题三"];


}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"穿衣助手问题三"];
    [TalkingData trackPageEnd:@"穿衣助手问题三"];


    if (self.delegate) {
        NSString *str =[self.selectIdArray componentsJoinedByString:@","];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (str.length == 0) {
            [self.delegate answerSaveWithDictionary:dic controllerIndex:2];
        }else{
            [dic addEntriesFromDictionary:@{@"shape":str}];
            [self.delegate answerSaveWithDictionary:dic controllerIndex:2];
        }

    }
}
- (void)nextButtonAction:(UIButton *)sender{
    if (self.delegate) {
        [self.delegate nextButtonClickedWithIndex:2];
    }
}
@end


@implementation RJAnswerThreeCollectionHeaderView


@end


@implementation RJAnswerThreeCollectionFooterView



@end



@implementation RJAnswerThreeCollectionCell
- (void)awakeFromNib{
    [super awakeFromNib];
}


@end


@implementation RJAnswerThreeNolikeCollectionCell



@end