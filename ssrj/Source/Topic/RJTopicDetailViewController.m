//
//  RJTopicDetailViewController.m
//  ssrj
//
//  Created by YiDarren on 16/10/1.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "RJTopicDetailViewController.h"

#import "GoodsDetailViewController.h"
#import "CollectionsViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import "ZanModel.h"
#import "CommentCell.h"
#import "CommentCell2.h"
#import "CommentCell3.h"
#import "Masonry.h"
#import "NSAttributedString+YYText.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "RJUserCenteRootViewController.h"

#import "HomeGoodListViewController.h"
#import "RJBrandDetailRootViewController.h"
#import "RJPushWebViewController.h"

@interface RJTopicDetailViewController ()<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate,UMSocialUIDelegate, UITextFieldDelegate, CommentCellDelegate,NJKWebViewProgressDelegate>{
    
    CGFloat _totalKeybordHeight;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
    NSInteger reloadCount;
    int commentIndex;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (assign, nonatomic) CGFloat webViewHeight;

@property (nonatomic,strong) CommentModel* comment;
@property (nonatomic,strong) NSMutableArray* commentArray;
@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)UITextField *textField1;
@property (nonatomic,strong)NSNumber *commentId;
@property (nonatomic,strong)NSNumber *memberId;
@property (nonatomic,assign)BOOL clickMoreBtn;

@property (nonatomic,strong) CollectionsDataModel *dataModel;
@property (nonatomic,strong) NSArray *dataArray;

@property (nonatomic,strong)NSMutableArray *layoutModelList;


//当首次加载页面后4条评论被删除完的时候，保留最后一条作为参数传给更多评论
@property (nonatomic,strong)CommentListModel *moreCommentModel;


@end

@implementation RJTopicDetailViewController


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    _textField.hidden = YES;

    [_progressView removeFromSuperview];

    [MobClick endLogPageView:@"资讯详情页面"];
    [TalkingData trackPageEnd:@"资讯详情页面"];

    [[RJAppManager sharedInstance].statisticalModelArr removeLastObject];
    
    self.view.trackingId = [NSString stringWithFormat:@"RJTopicDetailViewController&informId=%@",self.informId];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _textField.hidden = YES;
    [self.navigationController.navigationBar addSubview:_progressView];

    [MobClick beginLogPageView:@"资讯详情页面"];
    [TalkingData trackPageBegin:@"资讯详情页面"];

    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    reloadCount = 0;
    [self addBackButton];
    self.layoutModelList = [NSMutableArray array];
    NSArray *arr = @[@2,@7];
    [self addBarButtonItems:arr onSide:RJNavRightSide];
    UIButton *btn = self.navigationItem.rightBarButtonItems[1].customView;
    btn.selected = self.isThumbUp.integerValue;
    
    commentIndex = 1;
    
    _progressProxy = [[NJKWebViewProgress alloc]init];
    self.webView.delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    
    CGFloat progressBarHeight = 2.f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    /**
     *  headerView webView相关
     */
    if (self.shareModel.showUrl) {
        
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.shareModel.showUrl]]];
        
    }
    
    /**
     *  Test Local
     */
    
//    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"test" ofType:@"html"];
//    NSString *htmlString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
//    [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:filePath]];
    
    self.webView.scrollView.bounces = NO;
    self.webView.scalesPageToFit = NO;
    [self.webView.scrollView setScrollEnabled:NO];
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    /**
     *  评论相关
     */
    [self.tableView registerClass:[CommentCell class] forCellReuseIdentifier:@"CommentCell"];
    [self.tableView registerClass:[CommentCell2 class] forCellReuseIdentifier:@"CommentCell2"];
    [self.tableView registerClass:[CommentCell3 class] forCellReuseIdentifier:@"CommentCell3"];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    
    self.bgView.height = self.view.height;
    self.webViewHeight = self.view.height;
    [self.bgView layoutSubviews];
    [self.tableView setTableHeaderView:self.bgView];
    [self.tableView reloadData];
    
    [self setupTextField];
    [self getNetData];

//    weakSelf.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        [weakSelf getNetData];
//    }];
}




- (void)setupTextField{
    _textField = [[UITextField alloc]init];
    _textField.delegate = self;
    //    _textField.layer.borderColor = [UIColor colorWithHexString:@"424446"].CGColor;
    //    _textField.layer.borderWidth = 1;
    //    _textField.backgroundColor = [UIColor whiteColor];
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.backgroundColor = [UIColor colorWithHexString:@"f1f0f6"];
    _textField.textColor = [UIColor colorWithHexString:@"424446"];
    _textField.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.width, 38);
    _textField.returnKeyType = UIReturnKeySend;
    [[UIApplication sharedApplication].keyWindow addSubview:_textField];
    
}





- (void)getNetData {
    
    self.clickMoreBtn = NO;
    [self.layoutModelList removeAllObjects];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //    线上接口
    requestInfo.URLString = @"/b82/api/v4/goods/findcommentlist?pageIndex=0&pageSize=4&type=inform";
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }else{
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":@""}];
    }
    
    if (self.informId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.informId}];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.boolValue == 0) {
                NSDictionary *data = responseObject[@"data"];
                NSError __autoreleasing *e = nil;
                weakSelf.comment = [[CommentModel alloc]initWithDictionary:data error:&e];
                [weakSelf.comment.commentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CommentListModel *model = obj;
                    YYLabelLayoutModel *model1 = [self setHighText:model];
                    [weakSelf.layoutModelList addObject:model1];
                }];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                if (e) {
                    [HTUIHelper addHUDToView:self.view withString:@"网络请求失败" hideDelay:2];
                    return ;
                }
                
            }else{
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:@"网络请求失败" hideDelay:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"网络请求失败" hideDelay:2];
    }];

}

#pragma mark --设置YYLabel高亮
- (YYLabelLayoutModel *)setHighText:(CommentListModel *)model{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:model.comment];
    
    NSArray *atResults = [[self regex_At] matchesInString:text.string options:kNilOptions range:text.yy_rangeOfAll];
    
    for (NSTextCheckingResult *at in atResults) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        if ([text yy_attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
            NSRange newRange = NSMakeRange(at.range.location, at.range.length -1);
            
            [text yy_setColor:[UIColor colorWithHexString:@"#1b82bd"] range:newRange];
            
            YYTextHighlight *highlight = [YYTextHighlight new];
            //            highlight.userInfo = @{@"name":[text.string substringWithRange:(NSMakeRange(at.range.location + 1, at.range.length - 1))]};
            
            if (model.replyMember.memberId) {
                highlight.userInfo = @{@"memberId":model.replyMember.memberId};
            }
            [text yy_setTextHighlight:highlight range:newRange];
            
            /**
             *  设置_commentLabel高度属性
             */
            //            text
        }
    }
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(SCREEN_WIDTH-10-34-10-15, MAXFLOAT)];
    YYTextLayout *textLayout = [YYTextLayout layoutWithContainer:container text:text];
    
    YYLabelLayoutModel *model1 = [[YYLabelLayoutModel alloc]init];
    model1.textLayout = textLayout;
    model1.cellHeight = textLayout.textBoundingSize.height;
    return model1;
}

- (NSRegularExpression *)regex_At{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"@[-_a-zA-Z0-9\u4E00-\u9FA5].*:" options:kNilOptions error:NULL];
    return regex;
}
#pragma mark -- 获取字体高度
- (CGFloat)getFontHeight{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize size = [@"相关NSString" boundingRectWithSize:CGSizeMake(SCREEN_WIDTH, 0) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    return size.height;
}


//////////////////////////////////////////

/**
 *  webView加载部分
 *
 */
#pragma mark -- 监听webView内容高度变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        
        CGFloat hei = self.webView.scrollView.contentSize.height;
        if (_webViewHeight!= hei) {
//            NSSLog(@"%f",hei);
            _webViewHeight = hei;
            reloadCount ++;
            if (reloadCount%5==0) {
//                NSSLog(@"刷新");
                self.bgView.height = _webViewHeight;
                [self.tableView setTableHeaderView:self.bgView];
            }
           
        }
  
        
    }
}


#pragma mark -- UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
//    [[HTUIHelper shareInstance]removeHUD];
    
//    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];

    _webViewHeight = [webView.scrollView contentSize].height;
    CGRect newFrame = webView.frame;
    newFrame.size.height = _webViewHeight;
    self.bgView.frame = newFrame;
    [self.tableView setTableHeaderView:self.bgView];
    
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
//    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"加载中" xOffset:0 yOffset:0];
}
#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [_progressView setProgress:progress animated:YES];
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setTitle:title tappable:NO];
    });
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
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(goodsDetaiVC.class);
//                    statisticalDataModel.entranceType = _informId;
//                    statisticalDataModel.entranceTypeId = goodId2;
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];
                    
                                        
                    [self.navigationController pushViewController:goodsDetaiVC animated:YES];
                }
                if ([value1 isEqualToString:@"collocationId"]) {
                    //搭配详情
                    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
                    CollectionsViewController *collectionViewController = [sb instantiateViewControllerWithIdentifier:@"CollectionsViewController"];
                    collectionViewController.collectionId = (NSNumber *)value2;
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(collectionViewController.class);
//                    statisticalDataModel.entranceType = _informId;
//                    statisticalDataModel.entranceTypeId = (NSNumber *)value2;
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    
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
                    
//                    /**
//                     *  add 12.20 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(goodListVc.class);
//                    statisticalDataModel.entranceType = _informId;
//                    NSNumber *tagsId = [dic objectForKey:@"tagsId"];
//                    if (tagsId) {
//                        statisticalDataModel.entranceTypeId = tagsId;
//                    }
//                    else {
//                        statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:0];
//                    }
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    [self.navigationController pushViewController:goodListVc animated:YES];
                    
                    
                }else if([type isEqualToString:@"2"]){
                    NSDictionary *dic = @{itemArr[2]:itemArr[3]};
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
                    RJBrandDetailRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJBrandDetailRootViewController"];
                    rootVc.parameterDictionary = dic;
                    NSString *idStr = itemArr.lastObject;
                    rootVc.brandId = [NSNumber numberWithInt:[idStr intValue]];
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(rootVc.class);
//                    statisticalDataModel.entranceType = _informId;
//                    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:[idStr intValue]];
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    [self.navigationController pushViewController:rootVc animated:YES];
                }
                else if([type isEqualToString:@"3"]){
                    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Can" bundle:nil];
                    RJPushWebViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"RJPushWebViewController"];
                    NSString *idStr = itemArr.lastObject;
                    vc.activityId = [NSNumber numberWithInt:[idStr intValue]];
                    
//                    /**
//                     *  add 12.19 统计上报
//                     */
//                    ReportStatisticalDataModel *statisticalDataModel = [[ReportStatisticalDataModel alloc] init];
//                    statisticalDataModel.currentVCName = NSStringFromClass(self.class);
//                    statisticalDataModel.NextVCName = NSStringFromClass(vc.class);
//                    statisticalDataModel.entranceType = _informId;
//                    statisticalDataModel.entranceTypeId = [NSNumber numberWithInt:[idStr intValue]];
//                    [[RJAppManager sharedInstance].statisticalModelArr addObject:statisticalDataModel];

                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
        }
        return NO;
    }
    self.webViewHeight = webView.scrollView.contentSize.height;
    return YES;
}



//webView 加载部分end
////////////////////////////////////////////////

/**
 *  评论相关tableView
 *
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.comment.commentList.count +1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.comment.commentList.count) {
        if (self.comment.countComment.integerValue > self.comment.commentList.count && !self.clickMoreBtn) {
            return 89;

        }
        return 51;
    }
    YYLabelLayoutModel *model = self.layoutModelList[indexPath.row];
    return 10+ [self getFontHeight]+ 10+ model.cellHeight +10 + [self getFontHeight] +10+1 ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.comment.commentList.count) {
        if (self.comment.countComment.integerValue > self.comment.commentList.count && !self.clickMoreBtn) {
            CommentCell2 *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell2" forIndexPath:indexPath];
            cell.textField.delegate = self;
            self.textField1 = cell.textField;
            cell.label.text = @"展开更多评论";
            [cell.sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
            [cell.moreCommentBtn addTarget:self action:@selector(moreComment) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
        CommentCell3 *cell1 = [tableView dequeueReusableCellWithIdentifier:@"CommentCell3" forIndexPath:indexPath];
        cell1.textField.delegate = self;
        self.textField1 = cell1.textField;
        [cell1.sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
        return cell1;
        
    }
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    cell.deleteButton.tag = indexPath.row;
    [cell.deleteButton addTarget:self action:@selector(deleteComment:) forControlEvents:UIControlEventTouchUpInside];
    CommentListModel *model = self.comment.commentList[indexPath.row];
    cell.commentListModel = model;
    YYLabelLayoutModel *model1 = self.layoutModelList[indexPath.row];
    cell.yyLabelLayoutModel = model1;
    
    cell.delegate = self;
    cell.indexPath = indexPath;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{

    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    UIView* titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    titleView.backgroundColor = [UIColor whiteColor];
    
    UIView* sepView = [[UIView alloc]initWithFrame:CGRectZero];
    sepView.backgroundColor = [UIColor colorWithHexString:@"#EFEFF4"];
    
    UILabel* title = [[UILabel alloc]initWithFrame:CGRectZero];
    title.font = [UIFont systemFontOfSize:15];
    title.textColor = [UIColor colorWithHexString:@"# 424446"];
    title.text = @"评论";
    
    UILabel* count = [[UILabel alloc]initWithFrame:CGRectZero];
    count.font = [UIFont systemFontOfSize:14];
    count.textColor = [UIColor colorWithHexString:@"898e90"];
    count.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.comment.countComment.integerValue];
    [titleView addSubview:sepView];
    [titleView addSubview:title];
    [titleView addSubview:count];

    [sepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleView.mas_top);
        make.height.mas_equalTo(10);
        make.width.mas_equalTo(titleView.width);
    }];
    
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleView.mas_left).offset(10);
        make.centerY.equalTo(titleView.mas_centerY).offset(10);
    }];
        
    [count mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(title.mas_right).offset(5);
        make.centerY.equalTo(titleView.mas_centerY).offset(10);
    }];
        
    return titleView;
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//   
//    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
//    footer.backgroundColor = [UIColor colorWithHexString:@"fafafa"];
//    return footer;
//
//}

#pragma mark --评论Textfield的代理方法
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    //    if (textField == _textField) {
    //        _textField.hidden = NO;
    //    }else{
    //        _textField.hidden = YES;
    //    }
    [self adjustTableViewToFitKeyboard];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    _textField.hidden = YES;
    textField.placeholder = nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return NO;
    }
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/inform/%@/comments/", self.informId];
    if (textField.text.length) {
        if (textField == self.textField && self.informId &&self.commentId) {
            [requestInfo.postParams setDictionary:@{@"review_member_id":self.memberId,@"id":self.informId ,@"comment":textField.text}];
        }else if(self.informId){
            [requestInfo.postParams setDictionary:@{@"id":self.informId ,@"comment":textField.text}];
        }
    }else{
        [HTUIHelper addHUDToWindowWithString:@"评论不能为空" hideDelay:2];
        return NO;
    }
    
    _textField.text = nil;
    [_textField resignFirstResponder];
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            self.comment.countComment = [NSNumber numberWithInteger:self.comment.countComment.integerValue +1];
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"评论成功" image:nil];
            NSDictionary *dict = responseObject[@"data"];
            CommentListModel *model = [[CommentListModel alloc]initWithDictionary:dict error:nil];
            if (model) {
                
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:self.comment.commentList];
                [temArray insertObject:model atIndex:0];
                self.comment.commentList = [temArray copy];
                YYLabelLayoutModel *model1 = [self setHighText:model];
                [self.layoutModelList insertObject:model1 atIndex:0];
                
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                
            }
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"网络请求失败,请稍后再试" image:nil];
    }];
    
    textField.text = nil;
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark --评论头像的代理方法
- (void)celldidClickUser:(CommentListModel *)commentListModel{
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!commentListModel.member.memberId) {
        
        return;
    }
    rootVc.userId = commentListModel.member.memberId;
    rootVc.userName = commentListModel.member.name;
    
    [self.navigationController pushViewController:rootVc animated:YES];
    
}



#pragma mark --评论的代理方法
- (void)celldidClickLabel:(YYLabel *)label textRange:(NSRange)textRange indexPath:(NSIndexPath *)indexPath{
    NSAttributedString *text = label.textLayout.text;
    if (textRange.location >= text.length) return;
    
    YYTextHighlight *highlight = [text yy_attribute:YYTextHighlightAttributeName atIndex:textRange.location];
    NSDictionary *info = highlight.userInfo;
    if (info[@"memberId"]) {
        NSLog(@"点击了姓名%@",info[@"memberId"]);
        /**
         *  去个人中心
         */
        NSNumber *userId = info[@"memberId"];
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
        RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
        if (!userId) {
            return;
        }
        rootVc.userId = userId;
        rootVc.userName = @"";
        
        [self.navigationController pushViewController:rootVc animated:YES];
        return;
    }
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    [_textField becomeFirstResponder];
    _textField.hidden = NO;
    CommentListModel *model = self.comment.commentList[indexPath.row];
    self.commentId = model.commentId;
    self.memberId = model.member.memberId;
    _textField.placeholder = [NSString stringWithFormat:@"回复: %@", model.member.name];
    
    CommentCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:[UIApplication sharedApplication].keyWindow];
    rect.origin.y = rect.origin.y + 44;
    [self adjustTableViewToFitKeyboardWithRect:rect];
    
}




#pragma mark --添加评论
- (void)sendComment{
    
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/inform/%@/comments/", self.informId];
    
    if (self.textField1.text.length && self.informId) {
        [requestInfo.postParams setDictionary:@{@"id":self.informId ,@"comment":self.textField1.text}];
    }else{
        [HTUIHelper addHUDToWindowWithString:@"评论不能为空" hideDelay:2];
        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"评论成功" image:nil];
            self.comment.countComment = [NSNumber numberWithInteger:self.comment.countComment.integerValue +1];
            
            NSDictionary *dict = responseObject[@"data"];
            CommentListModel *model = [[CommentListModel alloc]initWithDictionary:dict error:nil];
            if (model) {
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:self.comment.commentList];
                [temArray insertObject:model atIndex:0];
                weakSelf.comment.commentList = [temArray copy];
                YYLabelLayoutModel *model1 = [weakSelf setHighText:model];
                [weakSelf.layoutModelList insertObject:model1 atIndex:0];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                
            }
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"网络请求失败,请稍后再试" image:nil];
    }];
    
    self.textField1.text = nil;
    [self.textField1 resignFirstResponder];
}

#pragma mark --删除评论
- (void)deleteComment:(UIButton *)btn{
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    } 
    
    if (self.comment.commentList.count == 1) {
        self.moreCommentModel = [self.comment.commentList firstObject];
    }
    
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    CommentListModel *model = self.comment.commentList[btn.tag];
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/inform/comments/%@/",model.commentId];
    
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]deleteWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            self.comment.countComment = [NSNumber numberWithInteger:self.comment.countComment.integerValue -1];
            if (btn.tag != self.comment.commentList.count) {
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.comment.commentList];
                [temp removeObjectAtIndex:btn.tag];
                self.comment.commentList = [temp copy];
                [self.layoutModelList removeObjectAtIndex:btn.tag];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"网络请求失败,请稍后再试" image:nil];
    }];
}

#pragma mark --更多评论
- (void)moreComment{
    
    self.clickMoreBtn = YES;
    commentIndex++;
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/inform/%@/comments/?page_index=%d&page_size=4",self.informId, commentIndex];

    __weak __typeof(&*self)weakSelf = self;
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            [[HTUIHelper shareInstance] removeHUD];
            NSDictionary *dict = responseObject[@"data"];
            NSArray *arr = [dict objectForKey:@"commentList"];
            weakSelf.commentArray = [NSMutableArray arrayWithArray:self.comment.commentList];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CommentListModel *model = [[CommentListModel alloc]initWithDictionary:obj error:nil];
                
                YYLabelLayoutModel *model1 = [weakSelf setHighText:model];
                [weakSelf.layoutModelList addObject:model1];
                [weakSelf.commentArray addObject:model];
            }];
            weakSelf.comment.commentList = [weakSelf.commentArray copy];
            [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"网络请求失败,请稍后再试" image:nil];
    }];
    
}


- (void)like:(id)sender{
    
    
//    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
//    requestInfo.URLString = @"/b82/api/v5/thumb?type=inform";
//    
//    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
//        
//        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
//    }
//    
//    RJHomeTopicModel *model = self.dataSource[sender.tag];
//    if (model.id) {
//        [requestInfo.getParams addEntriesFromDictionary:@{@"id":model.informId}];
//    }
//    __weak __typeof(&*self)weakSelf = self;
//    
//    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        if ([responseObject objectForKey:@"state"]) {
//            
//            NSNumber *state = [responseObject objectForKey:@"state"];
//            
//            if (state.intValue == 0) {
//                
//                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
//                
//                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
//                
//                sender.selected = thumb;
//                
//                RJHomeTopicModel *model = self.dataSource[sender.tag];
//                
//                model.isThumbsup = [NSNumber numberWithBool:thumb];
//                
//                sender.titleLabel.text = [NSString stringWithFormat:@"%@",thumbCount];
//                
//            }
//            
//            else if (state.intValue == 1) {
//                
//                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
//            }
//        }
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        [HTUIHelper addHUDToView:weakSelf.view withString:[error localizedDescription]  hideDelay:1];
//        
//    }];

    
    
    
    //判断用户是否登录
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    CCButton *btn = sender;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb?type=inform";
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        requestInfo.getParams = [NSMutableDictionary dictionaryWithDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    if (self.informId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"id":self.informId}];
    }
    __weak __typeof(&*self)weakSelf = self;
//    requestInfo.modelClass = [ZanModel class];
    
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];

            if (state.intValue == 0) {
                
                BOOL thumb = [[responseObject[@"data"] objectForKey:@"thumb"] boolValue];
                
                btn.selected = thumb;
                
                if (self.zanBlock) {
                    
                    self.zanBlock([NSNumber numberWithBool:thumb].intValue);
                }
            }
            
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Net Error" hideDelay:2];
        
    }];
    
}

#pragma mark - ShareAction
- (void)share:(id)sender{
    
    NSArray *shareType = [NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,nil];
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
    
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UmengAppkey
                                      shareText:comment
                                     shareImage:nil
                                shareToSnsNames:shareType
                                       delegate:self];
    
}
-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        if (!self.informId) {
            self.informId = @0;
        }
        requestInfo.URLString =[NSString stringWithFormat:@"/b180/api/v1/point/variation?type=36&id=%d",self.informId.intValue];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //                        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //                        NSLog(@"%@",error);
        }];
    }
}

#pragma mark -- 键盘高度变化
- (void)keyboardFrameWillChange:(NSNotification *)notification{
    NSDictionary *dict = [notification userInfo];
    CGRect rect = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect textFieldRect = CGRectMake(0, rect.origin.y - 40, self.view.width, 40);
    if (rect.origin.y == [UIScreen mainScreen].bounds.size.height) {
        textFieldRect = rect;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        _textField.frame = textFieldRect;
    }];
    
    CGFloat h = rect.size.height;
    if (_totalKeybordHeight != h) {
        _totalKeybordHeight = h;
        [self adjustTableViewToFitKeyboard];
    }
    
}

- (void)adjustTableViewToFitKeyboard{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!self.clickMoreBtn) {
        CommentCell2 *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.comment.commentList.count inSection:0]];
        CGRect rect = [cell.superview convertRect:cell.frame toView:window];
        [self adjustTableViewToFitKeyboardWithRect:rect];
    }else{
        CommentCell3 *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.comment.commentList.count inSection:0]];
        CGRect rect = [cell.superview convertRect:cell.frame toView:window];
        [self adjustTableViewToFitKeyboardWithRect:rect];
    }
}

- (void)adjustTableViewToFitKeyboardWithRect:(CGRect)rect{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat delta = CGRectGetMaxY(rect) - (window.bounds.size.height - _totalKeybordHeight);
    CGPoint offset = self.tableView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    
    [self.tableView setContentOffset:offset animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow]endEditing:YES];
}

-(void)didFinishShareInShakeView:(UMSocialResponseEntity *)response
{
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)dealloc{
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];

}



@end
