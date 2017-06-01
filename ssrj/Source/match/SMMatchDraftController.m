//
//  SMMatchDraftController.m
//  ssrj
//
//  Created by MFD on 16/11/12.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SMMatchDraftController.h"
#import "SMMatchDraftCell.h"
#import "SMMatchDraftModel.h"
#import "Masonry.h"
static NSString *const DraftUrl = @"/b180/api/v1/collocation/draft";
@interface SMMatchDraftController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,assign)BOOL isEditState;
@end

@implementation SMMatchDraftController
{
    int page;
    int pageSize;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [MobClick beginLogPageView:@"创建搭配-我的草稿页面"];
    [TalkingData trackPageBegin:@"创建搭配-我的草稿页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"创建搭配-我的草稿页面"];
    [TalkingData trackPageEnd:@"创建搭配-我的草稿页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    page = 1;
    pageSize = 15;
    // Do any additional setup after loading the view.
    _dataArray = [NSMutableArray array];
    [self setNavBar];
    [self configCollectionView];
    __weak __typeof(&*self)weakSelf = self;
    _collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getData];
    }];
    [_collectionView.mj_header beginRefreshing];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getNextData];
    }];
    self.collectionView.mj_footer.automaticallyHidden = YES;
    
}
- (void)setNavBar {
    
    [self addBackButton];
    self.title = @"我的草稿";
    UIButton *editBtn = [[UIButton alloc] init];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitle:@"取消" forState:UIControlStateSelected];
    [editBtn sizeToFit];
    editBtn.frame = CGRectMake(0, 0, editBtn.bounds.size.width, 44);
    editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [editBtn addTarget:self action:@selector(editBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
}
- (void)configCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    CGFloat cellWidth = self.view.bounds.size.width / 3.0;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerClass:[SMMatchDraftCell class] forCellWithReuseIdentifier:@"SMMatchDraftCell"];
    [self.view addSubview:_collectionView];
    
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}
#pragma mark - event
- (void)editBtnClick:(UIButton *)button {
    button.selected = !button.selected;
    _isEditState = button.selected;
    BOOL hiddenFooter = _collectionView.mj_footer.isHidden;
    [self.collectionView reloadData];
    _collectionView.mj_footer.hidden = hiddenFooter;
}

#pragma mark - network
- (void)getNextData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = DraftUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(page) forKey:@"pagenum"];
    [dict setObject:@(pageSize) forKey:@"pagesize"];
    requestInfo.getParams = dict;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            page++;
            NSArray *dictArr = responseObject[@"data"];
            for (NSDictionary *dict in dictArr) {
                NSError *error = nil;
                SMMatchDraftModel *model = [[SMMatchDraftModel alloc]initWithDictionary:dict error:&error];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [weakSelf.collectionView reloadData];
            if (dictArr.count < pageSize) {
                [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [weakSelf.collectionView.mj_footer endRefreshing];
            }
        }else{
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
}
- (void)getData {
    page = 1;
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = DraftUrl;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(page) forKey:@"pagenum"];
    [dict setObject:@(pageSize) forKey:@"pagesize"];
    requestInfo.getParams = dict;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            page++;
            [weakSelf.dataArray removeAllObjects];
            NSArray *dictArr = responseObject[@"data"];
            for (NSDictionary *dict in dictArr) {
                NSError *error = nil;
                SMMatchDraftModel *model = [[SMMatchDraftModel alloc]initWithDictionary:dict error:&error];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                }
            }
            [weakSelf.collectionView reloadData];
            if (weakSelf.dataArray.count < pageSize) {
                [weakSelf.collectionView.mj_footer setHidden:YES];
            }else {
                [weakSelf.collectionView.mj_footer resetNoMoreData];
            }
        }else{
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
        }
        [_collectionView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
        [_collectionView.mj_header endRefreshing];
    }];
}
- (void)deleteCellWithModel:(SMMatchDraftModel *)model {
    [[HTUIHelper shareInstance] addHUDToView:self.view withString:nil xOffset:0 yOffset:0];
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/collocation/deldraft?id=%@",model.ID];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if ([responseObject[@"state"] intValue] == 0) {
                
                [weakSelf.dataArray removeObject:model];
                
                BOOL hiddenFooter = weakSelf.collectionView.mj_footer.isHidden;
                [weakSelf.collectionView reloadData];
                weakSelf.collectionView.mj_footer.hidden = hiddenFooter;
            }else{
                [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:responseObject[@"msg"] hideDelay:1];
            }
        }
        [[HTUIHelper shareInstance] removeHUD];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
        [[HTUIHelper shareInstance] removeHUD];
    }];
}
#pragma mark - collectionDeledate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SMMatchDraftModel *model = self.dataArray[indexPath.row];
    SMMatchDraftCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SMMatchDraftCell" forIndexPath:indexPath];
    
    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.ID.intValue];
    
    cell.isShowDeleteBtn = _isEditState;
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"match_placeholder"]];
    __weak __typeof(&*self)weakSelf = self;
    cell.deleteBlock = ^(){
        [weakSelf deleteCellWithModel:model];
    };
    return cell;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    SMMatchDraftModel *model = self.dataArray[indexPath.row];
    if (self.selectedDraftBlock) {
        self.selectedDraftBlock(model);
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
