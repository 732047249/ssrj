
#import "RJNativeAndWebViewController.h"
#import "HomeGoodListCollectionViewCell.h"
#import "GoodsListModel.h"
#import "GoodsDetailViewController.h"
#import "ZanModel.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "RJHomeShareViewController.h"
#import "HomeGoodListViewController.h"
#import "RJBrandDetailRootViewController.h"
#import "RJPushWebViewController.h"
#import "CollectionsViewController.h"

@interface RJNativeAndWebViewController ()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource,HomeGoodListCollectionViewCellDelegate,UIWebViewDelegate,NJKWebViewProgressDelegate,UMSocialUIDelegate,CCGoodOrderViewDelegate>{
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (nonatomic,strong) RJNativeAndWebCollectionHeaderView * headerView;
@property (nonatomic,assign) CGFloat webViewHeight;
@property (nonatomic,strong) RJShareBasicModel * shareModel;
@property (strong, nonatomic) NSNumber * startNumber;
@property (strong, nonatomic) NSDictionary * parameterDictionary;

@property (nonatomic,strong) UIButton * shareButton;
@property (nonatomic,strong) UIWebView * webView;

@property (weak, nonatomic)  RJNativeAndWebCollectionOrderHeaderView *orderHeaderView;
@property (strong, nonatomic) NSString * selectSortStr;
@property (strong, nonatomic) NSMutableArray * sortArray;

@end

@implementation RJNativeAndWebViewController
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"上方H5下方原生商品列表页面"];
    [TalkingData trackPageEnd:@"上方H5下方原生商品列表页面"];
    [_progressView removeFromSuperview];

}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController.navigationBar addSubview:_progressView];

    [[SDImageCache sharedImageCache]clearMemory];
    
    [MobClick beginLogPageView:@"上方H5下方原生商品列表页面"];
    [TalkingData trackPageBegin:@"上方H5下方原生商品列表页面"];
    
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.dataArray = [NSMutableArray array];
    __weak __typeof(&*self)weakSelf = self;
    self.webViewHeight = SCREEN_HEIGHT - 64;
    [self addBackButton];
    [self addBarButtonItem:RJNavShareButtonItem onSide:RJNavRightSide];
    self.shareButton = self.navigationItem.rightBarButtonItem.customView;
    self.shareButton.enabled = NO;
    _progressProxy = [[NJKWebViewProgress alloc]init];
//    self.webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    self.sortArray = [NSMutableArray arrayWithObjects:@"goodsOrder_desc",@"promotionPrice_asc",@"promotionPrice_desc",@"goodsOrder3_desc", nil];
    self.selectSortStr = self.sortArray[0];
    
    [self.collectionView reloadData];
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    [self.collectionView.mj_header beginRefreshing];

}
- (void)getNetData{
    if (self.shareModel) {
        [self getGoodsData];
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"api/v5/event/nativeActivity.jhtml";
//    self.activeId = @1350;
    if (!self.activeId) {
        [HTUIHelper addHUDToView:self.view withString:@"数据异常" hideDelay:1];
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.activeId}];
    requestInfo.modelClass = [RJBasicModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        RJBasicModel *model = responseObject;
        if (model.state.intValue == 0) {
            NSDictionary *dic =(NSDictionary *)model.data;
            RJShareBasicModel *model = [[RJShareBasicModel alloc]initWithDictionary:dic error:nil];
            if (model) {
                self.shareModel = model;
                /**
                 *  再次请求数据
                 */
                self.shareButton.enabled = YES;
                [weakSelf getGoodsData];
                [self.headerView.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.shareModel.showUrl]]];
            }else{
                [weakSelf.collectionView.mj_header endRefreshing];
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
            }
            
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    
}
- (void)getGoodsData{
    if (!self.shareModel.tagsId) {
        [self.collectionView.mj_header endRefreshing];
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/api/v5/product/list.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":@"0",@"rows":@"10",@"orderStr":self.selectSortStr}];
    NSString *paramValue = self.shareModel.tagsId;
    NSArray *arr1 = [paramValue componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *str in arr1) {
        NSArray *arr = [str componentsSeparatedByString:@"="];
        if (arr.count ==2) {
            [dic addEntriesFromDictionary:@{arr[0]:arr[1]}];
        }
    }
    self.parameterDictionary= [dic mutableCopy];
    
    [requestInfo.getParams addEntriesFromDictionary:dic];
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            [[HTUIHelper shareInstance]removeHUD];
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.startNumber = model.start;
                [weakSelf.dataArray removeAllObjects];
                [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                [weakSelf.collectionView reloadData];
                if (model.data.count) {
                    weakSelf.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        [weakSelf getNextGoodsData];
                    }];
                }else{
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }else{
            [[HTUIHelper shareInstance]removeHUD];
            
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            
        }
        
        [weakSelf.collectionView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUD];
        
        [weakSelf.collectionView.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:2];
        
    }];

    
}
- (void)getNextGoodsData{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = @"api/v5/product/list.jhtml";
    requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"start":self.startNumber,@"rows":@"10",@"orderStr":self.selectSortStr}];
    
    if (self.parameterDictionary) {
        
        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
    }
    requestInfo.modelClass = [GoodsListModel class];
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[GoodsListModel class]]) {
            
            GoodsListModel *model = responseObject;
            if (model.state.boolValue == 0) {
                weakSelf.startNumber = model.start;
                if (model.data.count) {
                    [weakSelf.dataArray addObjectsFromArray:[model.data copy]];
                    
                    [weakSelf.collectionView.mj_footer endRefreshing];
                    
                    [weakSelf.collectionView reloadData];
                }else{
                    //没数据了 关闭上拉加载更多
                    [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
                    return;
                }
            }else{
                [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
                [weakSelf.collectionView.mj_footer endRefreshing];
                
            }
            
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
            [weakSelf.collectionView.mj_footer endRefreshing];
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"加载失败,请稍后再试" hideDelay:2];
        [weakSelf.collectionView.mj_footer endRefreshing];
        
    }];


}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return self.dataArray.count;

}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HomeGoodListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell hideRightLine];
    if (indexPath.row %2 == 0) {
        [cell showRightLine];
    }
    RJBaseGoodModel *model = self.dataArray[indexPath.row];

    /**
     *  统计ID
     */
    cell.trackingId = [NSString stringWithFormat:@"%@&id:%d",NSStringFromClass([self class]),model.goodId.intValue];
    
    cell.model = model;
    cell.contentView.tag = indexPath.row;
    cell.likeButton.tag = indexPath.row;
    [cell.likeButton addTarget:self action:@selector(likeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    cell.delegate = self;
    
    //li
    cell.zanImageView.highlighted = model.isThumbsup.boolValue;
    cell.likeButton.selected = model.isThumbsup.boolValue;
    
    
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader) {
        self.orderHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"RJNativeAndWebCollectionOrderHeaderView" forIndexPath:indexPath];
        self.orderHeaderView.orderView.delegate = self;
//        header.orderView.delegate = self;
//        [header.orderView.filterButton addTarget:self action:@selector(filterButtonTapAction) forControlEvents:UIControlEventTouchUpInside];
//        if (self.isHot) {
//            header.orderView.buttonThree.selected = YES;
//            header.orderView.buttonOne.selected = NO;
//            
//            self.isHot = NO;
//        }
        return self.orderHeaderView;
    }
    
    
    if (kind == UICollectionElementKindSectionFooter) {
        if (!self.headerView) {
            self.headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RJPushWebCollectionHeaderView" forIndexPath:indexPath];
            self.headerView.webView.delegate = _progressProxy;
            self.headerView.webView.scrollView.scrollsToTop = NO;
            [self.headerView.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            self.webView = self.headerView.webView;
        }
        self.headerView.height = self.webViewHeight;
        return self.headerView;
    }
    return nil;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return CGSizeZero;
    }
    return CGSizeMake(SCREEN_WIDTH, 44);
    
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (section==0) {
        return CGSizeMake(SCREEN_WIDTH, self.webViewHeight);;
    }
    return CGSizeZero;

}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageWid = (SCREEN_WIDTH)/2 -10 -10;
    CGFloat height = imageWid + 10 +15 + 69;
    return CGSizeMake(imageWid+10+10, height);
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

#pragma mark -webViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSString *urlstr = request.URL.absoluteString;
    if ([urlstr hasPrefix:@"app-ssrj:"]) {
        //        NSLog(@"拦截请求%@",urlstr);
        NSArray *arr = [urlstr componentsSeparatedByString:@":"];
        NSString *str = arr.lastObject;
        if (str.length) {
            NSArray *parametArr = [str componentsSeparatedByString:@"&"];
            NSString *str2 = parametArr.firstObject;
            NSArray *valueArr = [str2 componentsSeparatedByString:@"="];
            if (valueArr.count == 2) {
                NSString * value1 = [valueArr firstObject];
                NSString *value2 = [valueArr lastObject];
                if ([value1 isEqualToString:@"goodsId"]) {
                    //单品详情
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
                    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
                    NSNumber *goodId2 = (NSNumber *)value2;
                    goodsDetaiVC.goodsId = goodId2;
                    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
                }
                if ([value1 isEqualToString:@"collocationId"]) {
                    //搭配详情
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
                    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
                    collectionViewController.collectionId = (NSNumber *)value2;
                    [self.navigationController pushViewController:collectionViewController animated:YES];
                    
                }
                
            }
        }
        return NO;
        
    }
    else if ([urlstr hasPrefix:@"app-userid-ssrj:"]){
        if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
            NSString * func = [NSString stringWithFormat:@"app_ssrj_JSAction_userId('%@');",[RJAccountManager sharedInstance].account.id];
            [self.webView stringByEvaluatingJavaScriptFromString:func];
        }else{
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
            
            [self presentViewController:loginNav animated:YES completion:^{
                
            }];
            return NO;
        }
        return NO;
    }
    /**
     *  点击多个按钮 获取按钮的tag值，然后调用JS函数
     *
     *  @param hasPrefix:@"app-userid-ssrj-tag:"] 定义的拦截事件
     JS函数名固定app_ssrj_JSAction_userId_tag(userid,tag)
     */
    else if([urlstr hasPrefix:@"app-userid-ssrj-tag:"]){
        if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
            [self presentViewController:[[RJAppManager sharedInstance]getLoginViewController] animated:YES
                             completion:^{
                                 
                             }];
            return NO;
        }else{
            NSArray *arr = [urlstr componentsSeparatedByString:@":"];
            NSString *str = arr.lastObject;
            if (str.length) {
                NSArray *valueArr = [str componentsSeparatedByString:@"="];
                if (valueArr.count == 2) {
                    NSString *tag = valueArr.lastObject;
                    NSString * func = [NSString stringWithFormat:@"app_ssrj_JSAction_userId_tag('%@','%@');",[RJAccountManager sharedInstance].account.id,tag];
                    [self.webView stringByEvaluatingJavaScriptFromString:func];
                    
                }
            }
            
        }
        return NO;
    }
    /**
     *  2.2.0扩展的跳转原生界面
     *
     * 1、app-ssrj-pushNative:type=1&tagsId=88
     * 2、app-ssrj-pushNative:type=2&brands=99
     * 3、app-ssrj-pushNative:type=3&id=77(调用接口/api/v5/event/view.jhtml?appVersion=xx&token=xx&id=xx取数据)
     *  @param hasPrefix:@"app-ssrj-pushNative:"]
     
     */
    else if([urlstr hasPrefix:@"app-ssrj-pushnative:"]){
        NSArray *arr = [urlstr componentsSeparatedByString:@":"];
        NSLog(@"%@",arr);
        if (arr.count == 2) {
            NSString *str2 = arr.lastObject;
            NSArray *itemArr = [str2 componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&="]];
            if (itemArr.count == 4) {
                NSString *type = itemArr[1];
                if ([type isEqualToString:@"1"]) {
                    NSDictionary *dic = @{itemArr[2]:itemArr[3]};
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    HomeGoodListViewController *goodListVc = [storyBoard instantiateViewControllerWithIdentifier:@"HomeGoodListViewController"];
                    goodListVc.parameterDictionary = [dic copy];
                    [self.navigationController pushViewController:goodListVc animated:YES];
                    
                }else if([type isEqualToString:@"2"]){
                    NSDictionary *dic = @{itemArr[2]:itemArr[3]};
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
                    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
                    rootVc.parameterDictionary = dic;
                    NSString *idStr = itemArr.lastObject;
                    rootVc.brandId = [NSNumber numberWithInt:[idStr intValue]];
                    [self.navigationController pushViewController:rootVc animated:YES];
                }
                else if([type isEqualToString:@"3"]){
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Can" bundle:nil];
                    RJPushWebViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJPushWebViewController"];
                    NSString *idStr = itemArr.lastObject;
                    vc.activityId = [NSNumber numberWithInt:[idStr intValue]];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
        return NO;
    }
    
    return YES;
}
- (void)tapGsetureWithIndexRow:(NSInteger)tag{
    RJBaseGoodModel *model = self.dataArray[tag];
    NSNumber *goodId = (NSNumber *)model.goodId;
    /**
     *  在这里生成统计ID 要和Cell的tarkingID一样 
     */
    NSString * trackingId = [NSString stringWithFormat:@"%@&id=%@",NSStringFromClass(self.class),model.goodId];
    [[RJAppManager sharedInstance]trackingWithTrackingId:trackingId];

    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    GoodsDetailViewController *goodsDetaiVC = [storyBoard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetaiVC.goodsId = goodId;
    
    goodsDetaiVC.zanBlock = ^(NSInteger buttonState){
        RJBaseGoodModel *model = self.dataArray[tag];
        model.isThumbsup = [NSNumber numberWithInteger:buttonState];
        [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:tag inSection:0]]];
    };
    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
}
#pragma mark - 点赞 喜欢
- (void)likeButtonAction:(UIButton *)sender{
    //    NSLog(@"商品点赞");
    
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    //li
    [self zanNetRequest:sender];
    
}

//li--调用点赞接口
- (void)zanNetRequest:(UIButton *)sender{
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=goods"];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    RJBaseGoodModel *model = self.dataArray[sender.tag];
    if (model.goodId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.goodId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumb = [responseObject[@"data"] objectForKey:@"thumb"];
                
                sender.selected = thumb.boolValue;
                
                model.isThumbsup = thumb;
                
                [weakSelf.dataArray removeObjectAtIndex:sender.tag];
                
                [weakSelf.dataArray insertObject:model atIndex:sender.tag];
                
                [weakSelf.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:sender.tag inSection:0]]];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:weakSelf.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"]  hideDelay:1];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        
    }];
    
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    NSString *title = [self.headerView.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setTitle:title tappable:NO];
    });
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    NSLog(@"%@",NSStringFromCGSize(webView.scrollView.contentSize));
    self.webViewHeight =  webView.scrollView.contentSize.height;
    [self.collectionView reloadData];
}

#pragma mark -
#pragma mark 分享
- (void)share:(id)sender{
    if (!self.shareModel) {
        return;
    }
    //需要登录才可以分享 并且需要调用接口获取分享信息
    if (self.shareModel.isLogin.boolValue) {
        if (self.shareModel.shareUrl) {
            [self getShareData];
        }
    }
    /**
     *  就是普通的分享
     */
    else{
        
        NSArray *shareType = [NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,nil];
        
        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
        NSString *imageUrl = self.shareModel.img;
        NSString *comment = self.shareModel.memo;
        NSString *shareUrl = self.shareModel.shareUrl.length?self.shareModel.shareUrl:@"www.ssrj.com";
        [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
        [UMSocialData defaultData].extConfig.wechatSessionData.title = self.shareModel.title;
        
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qqData.title = self.shareModel.title;
        
        [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
        [UMSocialData defaultData].extConfig.qzoneData.title = self.shareModel.title;
        
        [UMSocialData defaultData].extConfig.sinaData.shareText =[NSString stringWithFormat:@"%@%@",comment,shareUrl];
        
        //调用快速分享接口
        [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
        //    if (!imageUrl.length) {
        //        [UMSocialData defaultData].shareImage = [UIImage imageNamed:@"Icon_for_share"];
        //    }
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:UmengAppkey
                                          shareText:comment
                                         shareImage:nil
                                    shareToSnsNames:shareType
                                           delegate:self];
    }
}
- (void)getShareData{
    
    if (![[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        [self presentViewController:[[RJAppManager sharedInstance]getLoginViewController] animated:YES completion:^{
            
        }];
        return;
    }
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = self.shareModel.shareUrl;
    if (self.activeId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"activityVersion":@1.0,@"id":self.activeId}];
    }
    [HTUIHelper addHUDToWindowWithString:@"获取分享地址中"];
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = responseObject[@"state"];
        if (state.intValue == 0) {
            if (!self.shareModel.shareType.length) {
                self.shareModel.shareType = @"0,1";
            }
            
            
            RJHomeShareModel *model = [[RJHomeShareModel alloc]initWithDictionary:responseObject[@"data"] error:nil];;
            [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
            
            NSString *imageUrl = model.share_img;
            NSString *comment =  model.content;
            NSString *shareUrl = model.redirectUrl;
            [UMSocialData defaultData].extConfig.wechatSessionData.url = shareUrl;
            [UMSocialData defaultData].extConfig.wechatSessionData.title = model.title;
            [UMSocialData defaultData].extConfig.wechatTimelineData.url = shareUrl;
            [HTUIHelper removeHUDToWindow];
            
            
            NSArray *types = [self.shareModel.shareType componentsSeparatedByString:@","];
            NSMutableArray *mArr = [NSMutableArray array];
            for (NSString *str in types) {
                if ([str isEqualToString:@"0"]) {
                    [mArr addObject:UMShareToWechatSession];
                }
                if ([str isEqualToString:@"1"]) {
                    [mArr addObject:UMShareToWechatTimeline];
                    
                }
                if ([str isEqualToString:@"2"]) {
                    [mArr addObject:UMShareToSina];
                    [UMSocialData defaultData].extConfig.sinaData.shareText =[NSString stringWithFormat:@"%@%@",comment,shareUrl];
                    
                }
                if ([str isEqualToString:@"3"]) {
                    [mArr addObject:UMShareToQQ];
                    [UMSocialData defaultData].extConfig.qqData.url = shareUrl;
                    [UMSocialData defaultData].extConfig.qqData.title = model.title;
                    
                }
                if ([str isEqualToString:@"4"]) {
                    [mArr addObject:UMShareToQzone];
                    [UMSocialData defaultData].extConfig.qzoneData.url = shareUrl;
                    [UMSocialData defaultData].extConfig.qzoneData.title = model.title;
                }
            }
            [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
            
            NSArray *shareType = [NSArray arrayWithArray:[mArr copy]];
            //调用快速分享接口
            //#warning  debug
            //            imageUrl =@"http://www.ssrj.com/resources/shop/mobile/images/huodong/160812/icon.png";
            [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeImage url:imageUrl];
            
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:UmengAppkey
                                              shareText:comment
                                             shareImage:nil
                                        shareToSnsNames:shareType
                                               delegate:self];
            [HTUIHelper removeHUDToWindow];
            
        }else if(state.intValue == 1){
            [HTUIHelper removeHUDToWindowWithEndString:responseObject[@"msg"] image:nil delyTime:2];
        }else if(state.intValue == 2){
            //            if ([RJAccountManager sharedInstance].token) {
            //                [[RJAppManager sharedInstance]showTokenDisableLoginVc];
            //            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper removeHUDToWindowWithEndString:@"请求失败，请稍后再试" image:nil delyTime:2];
    }];
    
}
//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        //        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        if (!self.activeId) {
            self.activeId = @0;
        }
        requestInfo.URLString =[NSString stringWithFormat:@"/b180/api/v1/point/variation?type=35&id=%d",self.activeId.intValue];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //                        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //                        NSLog(@"%@",error);
        }];
    }
}




#pragma mark -
#pragma mark KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"contentSize"]) {
//        NSLog(@"______%@",NSStringFromCGSize(self.headerView.webView.scrollView.contentSize));
        CGFloat hei = self.headerView.webView.scrollView.contentSize.height;
        if (hei != _webViewHeight) {
            _webViewHeight = hei;
            [self.collectionView reloadData];

        }

    }
}
- (void)dealloc{
    [self.headerView.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
    
}


#pragma mark - CCGoodOrderViewDelegate
- (void)changeOrderWithOrderType:(CCOrderType)type{
    self.selectSortStr = self.sortArray[type];
    //    NSLog(@"%@",self.selectSortStr);
//    [self.collectionView.mj_header beginRefreshing];
    [self getGoodsData];
}


@end


@implementation RJNativeAndWebCollectionHeaderView
- (void)awakeFromNib{
    [super awakeFromNib];
}
@end


@implementation RJNativeAndWebCollectionOrderHeaderView



@end
