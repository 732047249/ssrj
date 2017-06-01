
#import "RJZhuShouCollectionsViewController.h"
#import "ThemeDetailCollectionViewCell.h"
#import "ThemeDetailModel.h"
#import "CollectionsViewController.h"
#import "GetToThemeViewController.h"
#import "ZanModel.h"

#import "RJZhuShouViewController.h"

#define RecommentCollectionNetUrl @"/b82/api/v5/clad-aide/find-collocations"

@interface RJZhuShouCollectionsViewController ()<RJTapedUserViewDelegate,STCollectionViewDataSource,STCollectionViewDelegate>
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSNumber * startNumber;

@end

@implementation RJZhuShouCollectionsViewController
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self commonInit];

    __weak __typeof(&*self)weakSelf = self;
    self.dataArray = [NSMutableArray array];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetDataWithHUD:NO];
    }];
    
//    [self.collectionView.mj_header beginRefreshing];
    [self getNetDataWithHUD:YES];
    //ZhuShouCollectionCell
}
- (void)commonInit {
    self.stCollectionView =(STCollectionView *)self.collectionView;
    STCollectionViewFlowLayout * layout = self.st_collectionViewLayout;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.stCollectionView.stDelegate = self;
    self.stCollectionView.stDataSource = self;
}

- (STCollectionViewFlowLayout *)st_collectionViewLayout {
    return (STCollectionViewFlowLayout *)self.collectionViewLayout;
}
- (void)sceneDataChanged:(NSMutableArray *)arr{
    self.sceneArray = [NSMutableArray arrayWithArray:[arr mutableCopy]];
    [self.collectionView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self getNetDataWithHUD:YES];
}
- (void)getNetDataWithHUD:(BOOL)flag{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = RecommentCollectionNetUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":@"0",@"rows":@"10"}];
    self.startNumber = [NSNumber numberWithInt:0];
    if (self.sceneArray.count) {
        NSString *str = [self.sceneArray componentsJoinedByString:@","];
        [requestInfo.getParams addEntriesFromDictionary:@{@"scene":str}];
    }
    __weak __typeof(&*self)weakSelf = self;
  
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                weakSelf.startNumber = responseObject[@"start"];
                NSArray *arr = responseObject[@"data"];
                [weakSelf.dataArray  removeAllObjects];
                
//                NSNumber *goodNum = [responseObject objectForKey:@"goodsTotal"];
                NSNumber *collecNum = [responseObject objectForKey:@"collocationTotal"];
                
//                [self.delegate changeTopNumberWithNumber:goodNum numberTwo:collecNum];

//                if ([goodNum isKindOfClass:[NSNumber class]]) {
//                    [self.delegate changeTopNumberWithNumber:goodNum.integerValue index:0];
//                    
//                }
                if ([collecNum isKindOfClass:[NSNumber class]]) {
                    [self.delegate changeTopNumberWithNumber:collecNum.integerValue index:1];
                }

                if (!arr.count) {
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                    
                }else{
                    
                    weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextNetData];
                    }];
                }
                
            
                
                for (NSDictionary *dic in arr) {
                    ThemeCollocationList *model = [[ThemeCollocationList alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.collectionView reloadData];
                if (flag) {
                    [[HTUIHelper shareInstance]removeHUD];

                }

            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                if (flag) {
                    [[HTUIHelper shareInstance]removeHUD];
                    
                }
            }
            [weakSelf.collectionView.mj_header endRefreshing];
            if (flag) {
                [[HTUIHelper shareInstance]removeHUD];
                
            }

        }else{
            if (flag) {
                [[HTUIHelper shareInstance]removeHUD];
                
            }
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            [weakSelf.collectionView.mj_header endRefreshing];

            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (flag) {
            [[HTUIHelper shareInstance]removeHUD];
            
        }
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.collectionView.mj_header endRefreshing];

    }];
}
- (void)getNextNetData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = RecommentCollectionNetUrl;
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@"10"}];
    __weak __typeof(&*self)weakSelf = self;
    
    if (self.sceneArray.count) {
        NSString *str = [self.sceneArray componentsJoinedByString:@","];
        [requestInfo.getParams addEntriesFromDictionary:@{@"scene":str}];
    }
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                weakSelf.startNumber = responseObject[@"start"];
                NSArray *arr = responseObject[@"data"];
                if (!arr.count) {
                    
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                    
                }
                for (NSDictionary *dic in arr) {
                    ThemeCollocationList *model = [[ThemeCollocationList alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        [weakSelf.dataArray addObject:model];
                    }
                }
                [weakSelf.collectionView reloadData];
                
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            [weakSelf.collectionView.mj_footer endRefreshing];

        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            [weakSelf.collectionView.mj_footer endRefreshing];
            
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.collectionView.mj_footer endRefreshing];
        
    }];
}

- (NSInteger)stCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.dataArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(STCollectionViewFlowLayout *)layout numberOfColumnsInSection:(NSInteger)section {
    return 2;
}
- (UICollectionViewCell *)stCollectionView:(STCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ThemeDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ZhuShouCollectionCell" forIndexPath:indexPath];
    //喜欢button点击事件
    [cell.likeItButton addTarget:self action:@selector(likeItButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeItButton.tag = indexPath.row;
    cell.userDelegate = self;
    
    //添加button点击事件
    [cell.plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.plusButton.tag = indexPath.row;
    
    ThemeCollocationList *list = self.dataArray[indexPath.row];
    cell.collocationList = list;
    cell.likeItButton.selected = list.isThumbsup;
    
    /**
     *  统计ID
     */
    ThemeCollocationList *model = self.dataArray[indexPath.row];
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];
    cell.plusButton.trackingId = [NSString stringWithFormat:@"%@&plusButton&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];
    cell.likeItButton.trackingId = [NSString stringWithFormat:@"%@&likeItButton&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];

    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return CGSizeMake(SCREEN_WIDTH/2 , SCREEN_WIDTH/2  + 60);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ThemeCollocationList *collocationList = self.dataArray[indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = collocationList.collocationId;
    collectionViewController.zanBlock = ^(NSInteger buttonState){
        ThemeCollocationList *model= self.dataArray[indexPath.row];
        model.isThumbsup = buttonState;
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    };

    [self.fatherViewController.navigationController pushViewController:collectionViewController animated:YES];
    
}

- (void)likeItButtonClicked:(UIButton *)button{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=collocation";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    ThemeCollocationList *collocationList = self.dataArray[button.tag];
    if (collocationList.collocationId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":collocationList.collocationId}];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

    if ([responseObject objectForKey:@"state"]) {
        
        NSNumber *state = [responseObject objectForKey:@"state"];
        
        
        if (state.intValue == 0) {
            
            //NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
            
            NSNumber *thumb = [responseObject[@"data"] objectForKey:@"thumb"];
            
            //点赞成功
            [collocationList setValue:thumb forKey:@"isThumbsup"];
            
            //局部刷新
            [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
            
        } else if (state.intValue == 1){
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
    } else {
        
        [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
    }
} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
    [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
}];
    
}
- (void)plusButtonClicked:(UIButton *)button{

    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    ThemeCollocationList *collocationList = self.dataArray[button.tag];
    getToThemeVC.collectionID = collocationList.collocationId;
    
//    [self presentViewController:getToThemeVC animated:YES completion:^{
//        
//    }];
    
    [self.fatherViewController.navigationController pushViewController:getToThemeVC animated:YES];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"穿衣助手推荐搭配页面"];
    [TalkingData trackPageBegin:@"穿衣助手推荐搭配页面"];


}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"穿衣助手推荐搭配页面"];
    [TalkingData trackPageEnd:@"穿衣助手推荐搭配页面"];


}

- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString*)userName{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!userId) {
        return;
    }
    rootVc.userId = userId;
    rootVc.userName = userName;
    
    [self.fatherViewController.navigationController pushViewController:rootVc animated:YES];
}
@end
