
#import "RJAnswerTwoViewController.h"
#import "RJAnswerTwoModel.h"
#import "RJAnswerOneViewController.h"

@interface RJAnswerTwoViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) RJAnswerTwoModel * model;
@property (strong, nonatomic) NSMutableArray * selectIdArray;
@property (strong, nonatomic) RJAnswerTwoCollectionFooterView *footerView;
@end

@implementation RJAnswerTwoViewController
- (void)viewDidLoad{
    [super viewDidLoad];
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
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v3/goods/findfeatruegrouplist?quetionId=9"];
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
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RJAnswerTwoCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RJAnswerTwoCollectionCell" forIndexPath:indexPath];
    RJSubAnswerModel *model = self.dataArray[indexPath.row];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.id.intValue];
    cell.titleLabel.text = model.name;
    [cell.colorImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:GetImage(@"220X60")];
    cell.iconImageView.highlighted = NO;
    if ([self.selectIdArray containsObject:[NSString stringWithFormat:@"%d",model.id.intValue]]) {
        cell.iconImageView.highlighted = YES;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    RJSubAnswerModel *model = self.dataArray[indexPath.row];
    if ([self.selectIdArray containsObject:[NSString stringWithFormat:@"%d",model.id.intValue]]) {
        [self.selectIdArray removeObject:[NSString stringWithFormat:@"%d",model.id.intValue]];
    }else{
        [self.selectIdArray addObject:[NSString stringWithFormat:@"%d",model.id.intValue]];
        if (self.footerView.noLikeButton.selected) {
            self.footerView.noLikeButton.selected = NO;
        }
    }
    /**
     *  因为这里reloadData了 Tracking哪里抓取不到cell 统计写到这里 性能考虑 不再替换Tacking时候的调用顺序
     */
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell.trackingId) {
        [[RJAppManager sharedInstance]trackingWithTrackingId:cell.trackingId];
    }
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self.collectionView reloadData];
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWid = SCREEN_WIDTH/2 - 25 - 15;
    CGFloat imageHei = imageWid/11 *3;
    return CGSizeMake(SCREEN_WIDTH/2, 102 - 33 + imageHei);
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        RJAnswerTwoCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RJAnswerTwoCollectionHeaderView" forIndexPath:indexPath];
        if (self.model) {
            header.titleLabel.text = self.model.title;
        }
        return header;
    }
    if (kind == UICollectionElementKindSectionFooter) {
        self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RJAnswerTwoCollectionFooterView" forIndexPath:indexPath];
        [self.footerView.noLikeButton addTarget:self action:@selector(noLikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        return self.footerView;

    }
    return nil;
}

- (IBAction)nextButtonAction:(UIButton *)sender {
    if (self.delegate) {
        [self.delegate nextButtonClickedWithIndex:1];
    }
}
- (void)noLikeButtonAction:(CCButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        [self.selectIdArray removeAllObjects];
        [self.collectionView reloadData];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"穿衣助手问题二"];
    [TalkingData trackPageBegin:@"穿衣助手问题二"];
    
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"穿衣助手问题二"];
    [TalkingData trackPageEnd:@"穿衣助手问题二"];
    if (self.delegate) {
        
        NSString *str =[self.selectIdArray componentsJoinedByString:@","];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if (str.length == 0) {
            [self.delegate answerSaveWithDictionary:dic controllerIndex:1];
        }else{
            [dic addEntriesFromDictionary:@{@"color":str}];
            [self.delegate answerSaveWithDictionary:dic controllerIndex:1];
        }
        
    }
}

@end



@implementation RJAnswerTwoCollectionCell



@end


@implementation RJAnswerTwoCollectionHeaderView



@end




@implementation RJAnswerTwoCollectionFooterView



@end