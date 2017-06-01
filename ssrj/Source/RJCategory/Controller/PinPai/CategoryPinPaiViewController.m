//
//  CategoryPinPaiViewController.m
//  ssrj
//
//  Created by MFD on 16/5/27.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CategoryPinPaiViewController.h"
#import "CollectionViewCell.h"
#import "A-Z_brandsTableVIew.h"
#import "RJBrandModel.h"
#import "HomeGoodListViewController.h"

#define MFDWIDTH     [UIScreen mainScreen].bounds.size.width
#define KHEIGHT    [UIScreen mainScreen].bounds.size.height


#import "RJBrandDetailRootViewController.h"
#import "SearchGoodsViewController.h"

static NSString *cellID = @"cellID";

@interface CategoryPinPaiViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,brandsTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
//@property (weak, nonatomic) IBOutlet UISearchBar *search;
@property (nonatomic,strong)UIButton *closeBtn;
@property (nonatomic,strong)A_Z_brandsTableVIew *brandsTableView;

@property (strong, nonatomic)NSMutableArray *dataArray;
@property (strong, nonatomic)NSMutableArray *brandsArray;
@end

@implementation CategoryPinPaiViewController

//- (A_Z_brandsTableVIew *)brandsTableView{
//    if (_brandsTableView == nil) {
//        _brandsTableView = [[A_Z_brandsTableVIew alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.collectionView.frame.size.height) style:UITableViewStylePlain];
//    }
//    _brandsTableView.brandsCellDelegate = self;
//    _brandsTableView.brandsArray = self.dataArray;
//    return _brandsTableView;
//}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"品牌页面"];
    [TalkingData trackPageBegin:@"品牌页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"品牌页面"];
    [TalkingData trackPageEnd:@"品牌页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataArray = [NSMutableArray arrayWithCapacity:10];
    self.brandsArray = [NSMutableArray arrayWithCapacity:11];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake((MFDWIDTH-2*2-2*4)/3, (KHEIGHT-2*3)/4);
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellID];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsVerticalScrollIndicator = NO;

    __weak __typeof(&*self)weakSelf = self;
 
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getRecommendBrandsData];
        [weakSelf getNetData];
    }];

    
//    [self.view addSubview:self.search];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView.mj_header beginRefreshing];
}


- (void)getNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/brand/list.jhtml";
//    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
//        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [RJBrandModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            RJBrandModel *model = responseObject;
            if (model.state.intValue == 0) {
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
            }else{
                [HTUIHelper addHUDToView:weakSelf.view withString:model.msg hideDelay:2];
            }
            [weakSelf.collectionView reloadData];
        }
        [weakSelf.collectionView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:2];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}


- (void)getRecommendBrandsData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/brand/listRecommend.jhtml";
//    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
//        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            if ([responseObject objectForKey:@"state"]) {
                NSNumber *state = [responseObject objectForKey:@"state"];
                if (state.intValue == 0) {
                    NSArray *array = [NSArray arrayWithArray:[responseObject objectForKey:@"data"]];
                    [weakSelf.brandsArray removeAllObjects];
                    if (array.count) {
                        for (NSDictionary *dic in array) {

                            [weakSelf.brandsArray addObject:[[category_data_Model alloc]initWithDictionary:dic error:nil]];
                        }
                    }
                    [weakSelf.collectionView reloadData];
                }else{
                    [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:2];
                }
            }
        }
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:2];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --collectionView
//TODO:header 搜索🔍
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (kind == UICollectionElementKindSectionHeader) {
        
        CategoryCollectionHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CategoryCollectionHeaderView" forIndexPath:indexPath];

        header.bgView.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
        header.layer.cornerRadius = 5.0;
        header.layer.masksToBounds = YES;
        //header.imageView.image = [UIImage imageNamed:@"search_icon2"];
        header.titleLabel.text = @"搜索单品、搭配、合辑";
        [header.topButton addTarget:self action:@selector(topButtonClickedAction) forControlEvents:UIControlEventTouchUpInside];
        
        [header updateConstraintsIfNeeded];
        [header updateConstraints];
        header.topButton.trackingId = [NSString stringWithFormat:@"%@&CategoryCollectionHeaderView&topButton",NSStringFromClass([self class])];
        return header;
    }
    
    return nil;
}

- (void) topButtonClickedAction {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    SearchGoodsViewController *searchVC = [story instantiateViewControllerWithIdentifier:@"SearchGoodsViewController"];
    
    [self.navigationController pushViewController:searchVC animated:YES];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.brandsArray.count) {
        return self.brandsArray.count +1;
    }
    return 0;
}

-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(CollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.brandsArray.count) {
        [cell.imageView setImage:[UIImage imageNamed:@"more"]];
        cell.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.brandsArray.count) {
        CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
        cell.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1];
        cell.imageView.image = [UIImage imageNamed:@"more"];
        return cell;
    }
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    category_data_Model *model = self.brandsArray[indexPath.row];

    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodsId.intValue];
    
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:GetImage(@"default_1x1")];
    
    
    
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row != self.brandsArray.count) {
        category_data_Model *model = self.brandsArray[indexPath.row];
        NSNumber *brandId = model.goodsId;

        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
        RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
        rootVc.parameterDictionary = @{@"brands":brandId};
        rootVc.brandId = brandId;
        
        [self.navigationController pushViewController:rootVc  animated:YES];

    }else{
        if (!self.brandsTableView) {
            if (self.dataArray.count) {
                
                A_Z_brandsTableVIew *brands = [[A_Z_brandsTableVIew alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.collectionView.frame.size.height-114) style:UITableViewStylePlain];
                brands.brandsCellDelegate = self;
                brands.brandsArray = self.dataArray;
                UIButton *closeBtn =[[UIButton alloc]initWithFrame:CGRectMake(self.collectionView.frame.size.width-18-6, self.collectionView.origin.y+8, 18, 18)];
                [closeBtn setBackgroundImage:[UIImage imageNamed:@"closed"] forState:UIControlStateNormal];
                [closeBtn setBackgroundColor:[UIColor clearColor]];
                [closeBtn addTarget:self action:@selector(clickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
                self.closeBtn = closeBtn;
                self.brandsTableView = brands;
                [self.view addSubview:self.brandsTableView];
                //            [UIView animateWithDuration:0.3 animations:^{
                //                brands.frame = self.collectionView.frame;
                //            }];
                [UIView animateWithDuration:0.3 animations:^{
                    brands.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-114);
//                    brands.frame = self.collectionView.frame;
                } completion:^(BOOL finished) {
                    [self.view addSubview:closeBtn];
                }];
           
            }
        }
    }
}

//collectionView header size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(SCREEN_WIDTH, 35);
}

#pragma mark -brandsTableViewCellDelegate
- (void)didSelectCell:(NSString *)parameterName and:(NSNumber *)parameterId{
    [self clickCloseBtn];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
    rootVc.parameterDictionary = @{@"brands":parameterId};
    rootVc.brandId = parameterId;
    
    [self.navigationController pushViewController:rootVc  animated:YES];

}

- (void)clickCloseBtn{
    [self.closeBtn removeFromSuperview];
    __weak __typeof(&*self)weakSelf = self;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.brandsTableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, self.collectionView.frame.size.height-114);
    } completion:^(BOOL finished) {
        
        [weakSelf.brandsTableView removeFromSuperview];

    }];
    self.brandsTableView = nil;
}

@end





/**
 *  collectionHeaderView.m文件
 */
@implementation CategoryCollectionHeaderView

-(void)awakeFromNib {
    
    [super awakeFromNib];
    self.bgView.layer.cornerRadius = 5.0;
    self.bgView.layer.masksToBounds = YES;
}

@end












