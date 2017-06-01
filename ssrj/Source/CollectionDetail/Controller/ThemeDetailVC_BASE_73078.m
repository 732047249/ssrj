//
//  ThemeDetailVC.m
//  ssrj
//
//  Created by MFD on 16/6/29.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "ThemeDetailVC.h"
#import "ThemeDetailCollectionViewCell.h"
#import "ThemeDetailHeaderView.h"
#import "ThemeDetailModel.h"
#import "CollectionsViewController.h"
#import "GetToThemeViewController.h"
#import "CollectionsHeaderTableViewCell.h"

@interface ThemeDetailVC ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,CollectionsViewControllerDelegate>
@property (nonatomic,strong)ThemeData *data;

//用以保存第一次请求数据后获取的主题详情的ID，以便用户第一次点赞时请求网络数据（需此ID）
@property (nonatomic,strong)NSNumber *themeCollectionId;

@property (nonatomic,assign)int pageNumber;
//存取主题详情下的collectionCell内的数组数据
@property (nonatomic,strong) NSMutableArray *collectionThemeMutableArray;
//存取主题详情下对该主题关注过的用户的数组数据 (暂不用，后续使用模型)
@property (nonatomic,strong) NSMutableArray *memberLoveTheThemeMutableArray;

//记录点击的cell的indexPath,用于下级UI返回时刷新该cell
@property (strong, nonatomic) NSIndexPath *indexPath;


@end

@implementation ThemeDetailVC

//搭配详情代理方法，通知本合辑详情刷新数据及cell
- (void)reloadZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    //模型重新赋值
    ThemeCollocationList *collocationList = self.collectionThemeMutableArray[_indexPath.row];
    collocationList.isThumbsup = btnSelected;
    //局部刷新
    [self.themesCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]]];
}

//collectionViewController多余的代理，防崩溃
- (void)reloadHomeZanMessageNetDataWithBtnstate:(BOOL)btnSelected{

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [MobClick beginLogPageView:@"合辑详情页面"];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"合辑详情页面"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"合辑详情" tappable:NO];
    [self addBackButton];
    self.collectionThemeMutableArray = [NSMutableArray array];

    __weak __typeof(&*self)weakSelf = self;
  
    self.themesCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];

    [self.themesCollectionView.mj_header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)getNetData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    _pageNumber = 1;
    
    //https://b82.ssrj.com/api/v3/goods/findcollocationlist?pageIndex=0&pageSize=20&thememItemId=77&token=xxx
    
    requestInfo.URLString = [NSString stringWithFormat:@"https://b82.ssrj.com/api/v4/goods/findcollocationlist?pageIndex=%d&pageSize=20", _pageNumber];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    else {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":@""}];
    }
    
    if (self.parameterDictionary) {
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [ThemeDetailModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            ThemeDetailModel *model = responseObject;
            NSNumber *state = model.state;
            if (state.boolValue == 0) {
                ThemeData *data = model.data;
                if (_data == data) {
                    return ;
                }
                if (data.collocationList.count) {
                    weakSelf.themesCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        
                        [weakSelf getNextPageData];
                    }];
                }
                _pageNumber += 1;
                //情况下拉刷新的数据，放置下拉数据重复加载 by 8.10
                [weakSelf.collectionThemeMutableArray removeAllObjects];
                //用以保存第一次请求数据后获取的主题详情的ID，以便用户第一次点赞时请求网络数据（需此ID）
                weakSelf.themeCollectionId = data.themeCollectionId;
            
                //TODO:collectionCell数据使用collectionThemeMutableArray的数据
                [weakSelf.collectionThemeMutableArray addObjectsFromArray:data.collocationList];
                
//                存取主题详情下对该主题关注过的用户的数组数据 (暂用，后续使用模型)
//                weakSelf.memberLoveTheThemeMutableArray = [NSMutableArray array];
//                [weakSelf.memberLoveTheThemeMutableArray addObjectsFromArray:data.memberList];
//                [weakSelf.memberLoveTheThemeMutableArray addObjectsFromArray:[responseObject objectForKey:@"memberList"]];
  
                weakSelf.data = data;
                [weakSelf.themesCollectionView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        [weakSelf.themesCollectionView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.themesCollectionView.mj_header endRefreshing];
    }];
}

- (void)getNextPageData {
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //https://b82.ssrj.com/api/v3/goods/findcollocationlist?pageIndex=0&pageSize=20&thememItemId=77&token=xxx
    
    requestInfo.URLString = [NSString stringWithFormat:@"https://b82.ssrj.com/api/v3/goods/findcollocationlist?pageIndex=%d&pageSize=20", _pageNumber];
    [requestInfo.getParams addEntriesFromDictionary:@{@"token":@""}];

//    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }else{
//        [requestInfo.getParams addEntriesFromDictionary:@{@"token":@""}];
//    }
    if (self.parameterDictionary) {
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [ThemeDetailModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (responseObject) {
            ThemeDetailModel *model = responseObject;
            NSNumber *state = model.state;
            if (state.boolValue == 0) {
                ThemeData *data = model.data;
                
                if (!data.collocationList.count) {
                    [weakSelf.themesCollectionView.mj_footer endRefreshingWithNoMoreData];
                    return ;
                }
                _pageNumber += 1;
                
                //TODO:collectionCell数据使用collectionThemeMutableArray的数据
                [weakSelf.collectionThemeMutableArray addObjectsFromArray:data.collocationList];
                
                weakSelf.data = data;
                [weakSelf.themesCollectionView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        [weakSelf.themesCollectionView.mj_footer endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.themesCollectionView.mj_footer endRefreshing];
    }];

}



#pragma -collectionView
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        ThemeDetailHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ThemeDetailHeaderView" forIndexPath:indexPath];
        header.data = self.data;
        
        //点赞button事件（不能取消）
        [header.zanButton addTarget:self action:@selector(zanButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [header.commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [header updateConstraintsIfNeeded];
        [header updateConstraints];
        return header;
    }
    return nil;
}



//headerView 点赞button事件
- (void)zanButtonClicked{
    
    //点赞主题之前用户必须已经登录，需要取用户对应token用于主题关联
    //去登录界面
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [mainStory instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        
        return;
    }
    
        //TODO:将主题放入用户收藏的主题中,设置thumbsup为true
        [self sendThumbUpToNetwork];
    
}

//headerView 评论button事件
- (void)commentButtonClicked {
    
    [HTUIHelper addHUDToView:self.view withString:@"谢谢评论" hideDelay:1];
    
}


- (void)sendThumbUpToNetwork{
    
    //https://b82.ssrj.com/api/v3/goods/addthemeitemthumbsup?themeItemId=主题id&token=79b9b82b354d17d21c8d024c9134c473
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"https://b82.ssrj.com/api/v3/goods/addthemeitemthumbsup?themeItemId=%@",self.themeCollectionId];
    
    [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];

    if (self.parameterDictionary) {
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
    }
    
    __weak __typeof(&*self)weakSelf = self;
//    requestInfo.modelClass = [ThemeDetailModel class];
    [[ZHNetworkManager sharedInstance] getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
//            ThemeDetailModel *model = responseObject;
//            NSNumber *state = model.state;
            
            //8.13
            //记录zanBtn状态，用于代理传值上级UI刷新
            BOOL zanBtnSelected = nil;
            
            if ([[responseObject objectForKey:@"data"] intValue] == 1) {
                
                //用户已点赞
                weakSelf.data.thumbsup = YES;
                
                int curThumbsupNum = [weakSelf.data.thumbsupCount intValue] + 1;
                
                weakSelf.data.thumbsupCount = [NSNumber numberWithInt:curThumbsupNum];
                
                [weakSelf.themesCollectionView reloadData];
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:0.5];
                
                //8.13
                zanBtnSelected = YES;

            }
            if ([[responseObject objectForKey:@"data"] intValue] == 0)
            {
                
                //用户取消点赞
                weakSelf.data.thumbsup = NO;
                
                int temp = [weakSelf.data.thumbsupCount intValue] - 1;
                int curThumbsupNum = temp?temp : 0;
                
                weakSelf.data.thumbsupCount = [NSNumber numberWithInt:curThumbsupNum];
                
                [weakSelf.themesCollectionView reloadData];

                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:0.5];
                
                //8.13
                zanBtnSelected = NO;
                
            }
            
            //header上主题点赞或取消点赞后通过代理给上级UI（RJHomeSubjectAndCollectionCell）发送更新数据请求
            if ([_delegate respondsToSelector:@selector(reloadHomeZanMessageNetDataWithBtnstate:)]) {
                
                [_delegate reloadHomeZanMessageNetDataWithBtnstate:zanBtnSelected];
            }
            
        } else {
         
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.themesCollectionView.mj_header endRefreshing];
    }];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.collectionThemeMutableArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ThemeDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThemeDetailCollectionViewCell" forIndexPath:indexPath];
    
    //喜欢button点击事件
    [cell.likeItButton addTarget:self action:@selector(likeItButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.likeItButton.tag = indexPath.row;
    
    //添加button点击事件
    [cell.plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.plusButton.tag = indexPath.row;
    
    cell.collocationList = self.collectionThemeMutableArray[indexPath.row];
    
    
    return cell;
}

#pragma mark --collection View Cell内的点赞button事件
- (void)likeItButtonClicked:(UIButton *)button{
    
    
    //点赞之前用户必须已经登录，需要取用户对应token用于主题关联
    //去登录界面
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [mainStory instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        
        return;
    }
    
    ThemeCollocationList *collectionList = self.collectionThemeMutableArray[button.tag];

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"https://b82.ssrj.com:443/api/v3/goods/addcollocationthumbsup?colloctionId=%@", collectionList.collocationId];
    [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    
    if (self.parameterDictionary) {
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
    }
    
    __weak __typeof(&*self)weakSelf = self;
//    requestInfo.modelClass = [ThemeDetailModel class];
    [[ZHNetworkManager sharedInstance] getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if (responseObject) {
//            ThemeDetailModel *model = responseObject;
//            BOOL data = model.data;
//            BOOL isOk = [responseObject objectForKey:@"data"];
            
            if ([[responseObject objectForKey:@"data"] intValue] == 1) {
                
                //点赞成功
                [self.collectionThemeMutableArray[button.tag] setValue:@"1" forKey:@"isThumbsup"];
                
                //局部刷新
                [weakSelf.themesCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:0.5];

            } else {
                
                //取消点赞成功
                [self.collectionThemeMutableArray[button.tag] setValue:@"0" forKey:@"isThumbsup"];
                
                [weakSelf.themesCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:0.5];
            }
        } else {
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.themesCollectionView.mj_header endRefreshing];
    }];
    
}

//collection View Cell 内的添加主题到我的收藏 button事件
- (void)plusButtonClicked:(UIButton *)button{
    
    //添加主题之前用户必须已经登录，需要取用户对应token
    //去登录界面
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {

        UIStoryboard *mainStory = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [mainStory instantiateViewControllerWithIdentifier:@"loginNav"];
    
        [self presentViewController:loginNav animated:YES completion:^{
        
        }];
        
        return;
    }
    
//    ThemeCollocationList *collectionList = self.data.collocationList[button.tag];

    ThemeCollocationList *collectionList = self.collectionThemeMutableArray[button.tag];

    //TODO:添加cell内主题是否已被点赞字段&是否已被添加至个人收藏字段
    //TODO:请求网络数据
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC.collectionID = collectionList.collocationId;
    getToThemeVC.parameterDictionary = @{@"colloctionId":collectionList.collocationId};
    
    [self presentViewController:getToThemeVC animated:YES completion:^{
        
    }];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(SCREEN_WIDTH/2 , SCREEN_WIDTH/2  + 60);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH*150/320 + 46);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

//    ThemeCollocationList *collocationList = self.data.collocationList[indexPath.row];
    
    //用全局变量记录被点击cell的indexPath,用于返回该UI时刷新
    _indexPath = indexPath;
    
    ThemeCollocationList *collocationList = self.collectionThemeMutableArray[indexPath.row];
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
    collectionViewController.collectionId = collocationList.collocationId;
    collectionViewController.delegate = self;
    [self.navigationController pushViewController:collectionViewController animated:YES];
    
}
@end
