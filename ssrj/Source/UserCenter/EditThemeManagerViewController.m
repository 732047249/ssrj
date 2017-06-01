//
//  EditThemeManagerViewController.m
//  ssrj
//
//  Created by YiDarren on 16/12/23.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "EditThemeManagerViewController.h"
#import "ThemeDetailModel.h"
#import "ThemeDetailCollectionViewCell.h"

@interface EditThemeManagerViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic,strong)ThemeData *data;

//存取主题详情下的collectionCell内的数组数据
@property (nonatomic,strong) NSMutableArray *collectionThemeMutableArray;

@property (nonatomic,assign)int pageNumber;

@property (strong, nonatomic) NSMutableArray *deleteButtonArr;


@end

@implementation EditThemeManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    self.title = @"管理合辑内容";
    self.view.backgroundColor = [UIColor whiteColor];
    //完成按钮
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(navBarButtonAction)];
    self.navigationItem.rightBarButtonItem = barButton;

    self.collectionThemeMutableArray = [NSMutableArray array];
    self.deleteButtonArr = [NSMutableArray array];
    
    __weak __typeof(&*self)weakSelf = self;
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        [weakSelf getNetData];
    }];
    [self.collectionView.mj_header beginRefreshing];
}

- (void)getNetData {

    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        
    _pageNumber = 1;
        
    ///b82/api/v5/goods/findcollocationlist?pageIndex=0&pageSize=10&thememItemId=xxx&&appVersion=xxx)  v5 add 11.29
        
    //v5
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/goods/findcollocationlist?pageIndex=%d&pageSize=10", _pageNumber];
        
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
            
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    if (self.themeId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"thememItemId":self.themeId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [ThemeDetailModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        ThemeDetailModel *model = responseObject;
        NSNumber *state = model.state;
        if (state.integerValue == 0) {
            ThemeData *data = model.data;
                
            _pageNumber += 1;

            [weakSelf.collectionThemeMutableArray removeAllObjects];
            //用以保存第一次请求数据后获取的主题详情的ID，以便用户第一次点赞时请求网络数据（需此ID）
            weakSelf.themeId = data.themeCollectionId;
                
            //TODO:collectionCell数据使用dataArray的数据
            [weakSelf.collectionThemeMutableArray addObjectsFromArray:data.collocationList];
                
            weakSelf.data = data;
        
            [weakSelf.collectionView reloadData];
        
        }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
        }
            
        [weakSelf.collectionView.mj_header endRefreshing];
            
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    
}




- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [MobClick beginLogPageView:@"管理合辑内容页面"];
    [TalkingData trackPageBegin:@"管理合辑内容页面"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [MobClick endLogPageView:@"管理合辑内容页面"];
    [TalkingData trackPageEnd:@"管理合辑内容页面"];
}

#pragma mark －完成按钮点击
- (void)navBarButtonAction {

    for (UIButton *btn in _deleteButtonArr) {
        
        [btn setHidden:YES];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.navigationController popViewControllerAnimated:YES];
        
        _deleteButtonArr = [NSMutableArray array];
    });
    
}

#pragma mark -UICollectionViewDelegate&DataSource
#pragma mark - collectionView
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 1;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {

    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    return self.collectionThemeMutableArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    ThemeDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"editThemeCell" forIndexPath:indexPath];
        
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton setHidden:NO];
    [cell.deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.collocationList = self.collectionThemeMutableArray[indexPath.row];

    
    /**
     *  统计ID
     */    
    ThemeCollocationList *model = self.collectionThemeMutableArray[indexPath.row];

    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.collocationId.intValue];
    
    
    UIButton *deleteButton = cell.deleteButton;
    [_deleteButtonArr addObject:deleteButton];
    return cell;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(SCREEN_WIDTH/2-1, SCREEN_WIDTH/2+60);
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{

    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    [HTUIHelper addHUDToView:self.view withString:@"cell点击了" hideDelay:1];
    
}

#pragma mark -管理合辑内容 删除按钮点击事件
- (void)deleteButtonClicked:(UIButton *)sender {
    
    ThemeCollocationList * model = self.collectionThemeMutableArray[sender.tag];
    
    //https://ssrj.com/b180/api/v1/content/publish/theme_item/detail/
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *str = [NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/detail/%@/",_themeId];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION, @"remove_collocation_id":model.collocationId}];
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    
    str= [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    requestInfo.URLString = str;
    
    [[ZHNetworkManager sharedInstance] postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:@"删除成功" hideDelay:1];

                [weakSelf.collectionThemeMutableArray removeObjectAtIndex:sender.tag];
                
                [weakSelf.collectionView reloadData];
                
//                NSLog(@"sender.tag=%ld",(long)sender.tag);
                
                if (self.delegate) {
                    if ([weakSelf.delegate respondsToSelector:@selector(reloadManagerThemeDataWithIndex:)]) {
                        
                        [weakSelf.delegate reloadManagerThemeDataWithIndex:sender.tag];
                    }
                }
                
            } else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



@end
