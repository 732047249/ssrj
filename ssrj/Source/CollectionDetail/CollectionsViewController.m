//
//  CollectionsViewController.m
//  ssrj
//
//  Created by MFD on 16/6/16.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "CollectionsViewController.h"
#import "CollectionsHeaderTableViewCell.h"
#import "RelatedGoodsTableViewCell.h"
#import "RecommendCollectionsTableViewCell.h"
#import "RecommendCollectionsModel.h"
#import "ThemeDetailVC.h"
#import "CollectionsAddCartVC.h"
#import "CommentCell.h"
#import "UITableView+FDTemplateLayoutCell.h"
#import "Masonry.h"
#import "CommentCell2.h"
#import "CommentCell3.h"
#import "NSAttributedString+YYText.h"
#import "GuideView.h"
#import "YYLabelLayoutModel.h"
#import "NSAttributedString+YYText.h"
#import "EditCollocationViewController.h"
#import "GetToThemeViewController.h"

@interface CollectionsViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIActionSheetDelegate ,CollectionsHeaderTableViewCellDelegate,CommentCellDelegate,RJTapedUserViewDelegate,UMSocialUIDelegate,EditCollocationViewControllerDelegate,GetToThemeViewControllerDelegate>
{
    CGFloat _totalKeybordHeight;
    int pagesize;
    int page;
    int commentIndex;//点击更多评论，记录请求页数
}

@property (weak, nonatomic) IBOutlet UITableView *collectionsTableView;

@property (weak, nonatomic) IBOutlet UIButton *addCartBtn;


@property (nonatomic,strong) CollectionsDataModel *dataModel;
@property (nonatomic,strong) NSArray *dataArray;

@property (nonatomic,assign) CGFloat descriptionHeight;

@property (nonatomic,strong) TagsFrames *tagsFrames;


@property (nonatomic,strong) CommentModel* comment;
@property (nonatomic,strong) NSMutableArray* commentArray;

@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)UITextField *textField1;
@property (nonatomic,strong)NSNumber *commentId;
@property (nonatomic,strong)NSNumber *memberId;
@property (nonatomic,assign)BOOL clickMoreBtn;

//当首次加载页面后4条评论被删除完的时候，保留最后一条作为参数传给更多评论
@property (nonatomic,strong)CommentListModel *moreCommentModel;

//记录评论TableView的cell点击时的第indexPath.row个用户评论模型 （clickedCommentModel, commentListModel类）
//@property (strong, nonatomic) commentListModel *clickedCommentModel;
@property (nonatomic,strong)NSMutableArray *layoutModelList;
@property (nonatomic,strong) UIButton * shareButton;
@property (nonatomic,strong) RJShareBasicModel * shareModel;


@end

@implementation CollectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.trackingId = [NSString stringWithFormat:@"CollectionsViewController&viewWillAppear&collectionId=%@",self.collectionId];
    page = 1;
    commentIndex = 1;

    pagesize = 15;
    self.layoutModelList = [NSMutableArray array];
    [self setTitle:@"搭配详情" tappable:NO];
    [self addBackButton];
    NSArray *btnArray = @[@1,@2];
    [self addBarButtonItems:btnArray onSide:RJNavRightSide];
   
    self.shareButton = self.navigationItem.rightBarButtonItems[1].customView;
    self.shareButton.enabled = NO;
    
    if (_isSelf) {
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreAction"] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemClicked)];
        
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    
    self.collectionsTableView.separatorInset = UIEdgeInsetsZero;
    [self.collectionsTableView registerClass:[CommentCell class] forCellReuseIdentifier:@"CommentCell"];
    [self.collectionsTableView registerClass:[CommentCell2 class] forCellReuseIdentifier:@"CommentCell2"];
    [self.collectionsTableView registerClass:[CommentCell3 class] forCellReuseIdentifier:@"CommentCell3"];
    
    self.addCartBtn.layer.cornerRadius = 4;
    self.addCartBtn.layer.masksToBounds = YES;
    
    _tagsFrames = [[TagsFrames alloc]init];
    self.dataArray = [NSArray array];
    __weak __typeof(&*self)weakSelf = self;

    self.collectionsTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    [self.collectionsTableView.mj_header beginRefreshing];
    
    //如果获取当前viewControl比较困难的时候
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self setupTextField];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //引导页
//    [self addGuideView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _textField.hidden = YES;
    [MobClick beginLogPageView:@"搭配详情页面"];
    [TalkingData trackPageBegin:@"搭配详情页面"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"搭配详情页面"];
    [TalkingData trackPageEnd:@"搭配详情页面"];
    
    _textField.hidden = YES;
    
    [_textField resignFirstResponder];
    
}

#pragma mark --编辑nav barButtonItemClicked
- (void)barButtonItemClicked {
    
    if (_event.intValue == 2) {

        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:self.dataModel.nowCollocation.thumbsup.integerValue == 1? @"取消点赞":@"点赞",nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];

    }
    else {
        
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"编辑",@"删除搭配",nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];

    }
    
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (_event.intValue == 2) {
        //点赞
        if (buttonIndex == 0) {
            
            [self zanButtonClickedAction];
        }
        
    }
    else {
        
        if (buttonIndex == 0) {
            
            //编辑搭配
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
            
            EditCollocationViewController *editVC = [sb instantiateViewControllerWithIdentifier:@"EditCollocationViewController"];
            
            NowCollocationModel *model = self.dataModel.nowCollocation;
            
            editVC.collectionID = _collectionId;
            editVC.collocationTitStr = model.name;
            editVC.collocationDesStr = model.memo;
            editVC.delegate = self;
            editVC.homeItemTypeTwoModel = self.homeItemTypeTwoModel;
            [self.navigationController pushViewController:editVC animated:YES];
            
        }
        else if (buttonIndex == 1) {
            
            //删除提示
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除搭配后，其他用户将看不到此搭配，真的要删除吗?" delegate:self cancelButtonTitle:@"我再思考一下" otherButtonTitles:@"确定", nil];
            [alert show];
            
        }

    }
    
}

#pragma mark - 取消点赞
- (void)zanButtonClickedAction {
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = @"/b82/api/v5/thumb";
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@"collocation" forKey:@"type"];
    if (self.collectionId) {
        [dict setObject:self.collectionId forKey:@"id"];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.getParams = dict;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject[@"state"] intValue] == 0) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                NSNumber *thumb = [responseObject[@"data"] objectForKey:@"thumb"];
                
                NowCollocationModel *model = self.dataModel.nowCollocation;
                
                model.thumbsup = thumb;
                
                model.thumbsupCount = thumbCount;
                
                [weakSelf.collectionsTableView reloadData];
            }
  
        }else {
            [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:responseObject[@"msg"] hideDelay:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow  withString:@"Error" hideDelay:2];
    }];

}



#pragma mark - UIAlertViewDelegate方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
   
    if (buttonIndex == 1) {
        
        [self deleteSelfPublishWithUrlstring:[NSString stringWithFormat:@"/b180/api/v1/content/publish/collocation/detail/%@/",_collectionId] index:alertView.tag];
    }
}

#pragma mark -删除搭配方法
- (void)deleteSelfPublishWithUrlstring:(NSString *)urlStr index:(NSInteger) index {
    
    
    //[HTUIHelper addHUDToView:self.view withString:@"正在取消中..." xOffset:0 yOffset:50];
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"appVersion":VERSION}];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    [[ZHNetworkManager sharedInstance] deleteWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
                
                if ([weakSelf.delegate isKindOfClass:NSClassFromString(@"RJUserCentePublishTableViewController")]) {
                    
                    if ([weakSelf.delegate respondsToSelector:@selector(reloadUserCenterPublishDataWithDelete)]) {
                        
                        [weakSelf.delegate reloadUserCenterPublishDataWithDelete];
                    }
                }
                
                [weakSelf.navigationController popViewControllerAnimated:YES];
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
            //[[HTUIHelper shareInstance] removeHUD];
            
        }
        else {
            
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
        //[[HTUIHelper shareInstance] removeHUD];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        //[[HTUIHelper shareInstance] removeHUD];
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];
    
}


- (void)setupTextField{
    _textField = [[UITextField alloc]init];
    _textField.delegate = self;
    _textField.borderStyle = UITextBorderStyleRoundedRect;
    _textField.backgroundColor = [UIColor colorWithHexString:@"#f1f0f6"];
    _textField.textColor = [UIColor colorWithHexString:@"#424446"];
    _textField.frame = CGRectMake(0., [UIScreen mainScreen].bounds.size.height, self.view.width, 38);
    _textField.returnKeyType = UIReturnKeySend;
    [[UIApplication sharedApplication].keyWindow addSubview:_textField];
    
}

- (void)getNetData{
    page = 1;
    self.clickMoreBtn = NO;
    [self.layoutModelList removeAllObjects];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    //add 11.30  v5
    ///b82/api/v5/goods/findcollocation?pageIndex=0&pageSize=10&colloctionId=xxx&&appVersion=xxx&token=xxx)

    requestInfo.URLString = @"/b82/api/v5/goods/findcollocation";

    if (self.collectionId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"pageIndex":@(page),@"pageSize":@(pagesize),@"colloctionId":self.collectionId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = [responseObject objectForKey:@"state"];
        if (state.boolValue == 0) {
            page++;
            NSDictionary *data = responseObject[@"data"];
            NSError __autoreleasing *error = nil;
            weakSelf.dataModel = [[CollectionsDataModel alloc]initWithDictionary:data error:&error];
            if (!error) {
                if (weakSelf.dataModel.nowCollocation.shareInfo) {
                    weakSelf.shareButton.enabled = YES;
                    weakSelf.shareModel = weakSelf.dataModel.nowCollocation.shareInfo;
                }
                weakSelf.dataArray = weakSelf.dataModel.collocations;
                weakSelf.comment = weakSelf.dataModel.nowCollocation.comment;
                [weakSelf.comment.commentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CommentListModel *model = obj;
                    YYLabelLayoutModel *model1 = [self setHighText:model];
                    [weakSelf.layoutModelList addObject:model1];
                }];
                
                NSMutableArray *temp = [NSMutableArray array];
                [weakSelf.dataModel.nowCollocation.themeItemList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ThemeItemListModel *model = obj;
                    [temp addObject:model.name];
                }];
                weakSelf.tagsFrames.titlesArray = [temp copy];
                
                
                NSMutableArray *temp1 = [NSMutableArray array];
                [weakSelf.dataModel.nowCollocation.themeItemList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    ThemeItemListModel *model = obj;
                    [temp1 addObject:model.themeItemId];
                }];
                weakSelf.tagsFrames.themeIdsArray = [temp1 copy];
            }
            
            [weakSelf.collectionsTableView reloadData];
            [weakSelf.collectionsTableView.mj_header endRefreshing];
            if (weakSelf.dataArray.count) {
                weakSelf.collectionsTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                    [weakSelf getNextData];
                }];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
            [weakSelf.collectionsTableView.mj_header endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.collectionsTableView.mj_header endRefreshing];
    }];
    
}

- (void)getNextData{// v3-> v5
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];

    requestInfo.URLString = @"/b82/api/v5/goods/findcollocation";

    if (self.collectionId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"pageIndex":@(page),@"pageSize":@(pagesize),@"colloctionId":self.collectionId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *state = [responseObject objectForKey:@"state"];
        if (state.boolValue == 0) {
            page++;
            NSDictionary *data = responseObject[@"data"];
            NSError __autoreleasing *error = nil;
            CollectionsDataModel *dataModel = [[CollectionsDataModel alloc]initWithDictionary:data error:&error];
            
            NSMutableArray *temp = [NSMutableArray arrayWithArray:self.dataArray];
            if (!error) {
                [temp addObjectsFromArray:dataModel.collocations];
                self.dataArray = [temp copy];
                [self.collectionsTableView reloadData];
            }
            [weakSelf.collectionsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:2]] withRowAnimation:UITableViewRowAnimationAutomatic];
            if (dataModel.collocations.count < pagesize) {
                
                [weakSelf.collectionsTableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [self.collectionsTableView.mj_footer endRefreshing];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:2];
            [self.collectionsTableView.mj_footer endRefreshing];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.collectionsTableView.mj_footer endRefreshing];
    }];
}

//搭配详情的代理方法，通知本VC执行响应操作
- (void)letMeNotificateTheSuperVCToReloadData:(BOOL)btnSelected{
    //下delegatepush过来的上级VC，因同时给两个页面的代理方法名称不同，故此处写两个
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadZanMessageNetDataWithBtnstate:)]) {
        [_delegate reloadZanMessageNetDataWithBtnstate:btnSelected];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(reloadHomeZanMessageNetDataWithBtnstate:)]) {
        [_delegate reloadHomeZanMessageNetDataWithBtnstate:btnSelected];
    }
    
}

#pragma mark -加入合辑编辑代理刷新
- (void)reloadCollocationViewCollocationCellDataWithModel:(RJHomeItemTypeTwoModel *)collocationModel {
    
    [self.collectionsTableView.mj_header beginRefreshing];
    
    if ([self.delegate isKindOfClass:NSClassFromString(@"HomeViewController")]) {
        
        if ([self.delegate respondsToSelector:@selector(reloadHomeCollocationCellDataWithHomeModel:)]) {
            
            [self.delegate reloadHomeCollocationCellDataWithHomeModel:collocationModel];
        }
    }
    else if ([self.delegate isKindOfClass:NSClassFromString(@"RJUserCentePublishTableViewController")]) {
        
        if ([self.delegate respondsToSelector:@selector(reloadUserCenterPublishDataWithCollocationModel:)]) {
            
            [self.delegate reloadUserCenterPublishDataWithCollocationModel:collocationModel];
        }
        
    }
}

- (void)reloadEditedCollocationDataWithCollocationModel:(RJHomeItemTypeTwoModel *)collocationModel {
    
    [self.collectionsTableView.mj_header beginRefreshing];

    if ([self.delegate isKindOfClass:NSClassFromString(@"RJUserCentePublishTableViewController")]) {
        
        [self.delegate reloadUserCenterPublishDataWithCollocationModel:collocationModel];
    }
    
}


- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    NowCollocationModel *model = self.dataModel.nowCollocation;
    if (![model.memo  isEqual: @""]) {
        self.descriptionHeight = [self heightWithContent:model.memo andWidth:SCREEN_WIDTH - 10*2];
    }else{
        self.descriptionHeight = 0;
    }
}


- (CGFloat)heightWithContent:(NSString *)content andWidth:(CGFloat)width{
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:14]};
    CGRect temRect = [content boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil];
    return temRect.size.height;
}

#pragma mark --设置YYLabel高亮
- (YYLabelLayoutModel *)setHighText:(CommentListModel *)model{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:model.comment];
    
    NSArray *atResults = [[self regex_At] matchesInString:text.string options:kNilOptions range:text.yy_rangeOfAll];
    
    for (NSTextCheckingResult *at in atResults) {
        if (at.range.location == NSNotFound && at.range.length <= 1) continue;
        if ([text yy_attribute:YYTextHighlightAttributeName atIndex:at.range.location] == nil) {
            NSRange newRange = NSMakeRange(at.range.location, at.range.length -1);
            
            [text yy_setColor:[UIColor colorWithHexString:@"1b82bd"] range:newRange];
        
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


#pragma mark --tableView
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        return 40;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 3) {
        return 0.1;
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return [[UIView alloc]initWithFrame:CGRectZero];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 2) {
        UIView* titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        titleView.backgroundColor = [UIColor whiteColor];
        UILabel* title = [[UILabel alloc]initWithFrame:CGRectZero];
        title.font = [UIFont systemFontOfSize:15];
        title.textColor = [UIColor colorWithHexString:@"424446"];
        title.text = @"评论";
        UILabel* count = [[UILabel alloc]initWithFrame:CGRectZero];
        count.font = [UIFont systemFontOfSize:14];
        count.textColor = [UIColor colorWithHexString:@"898e90"];
        count.text = [NSString stringWithFormat:@"%lu", (unsigned long)self.comment.countComment.intValue];
        [titleView addSubview:title];
        [titleView addSubview:count];
        
        [title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleView.mas_left).offset(10);
            make.centerY.equalTo(titleView.mas_centerY);
        }];
        
        [count mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(title.mas_right).offset(5);
            make.centerY.equalTo(title.mas_centerY);
        }];
        
        return titleView;
    }
    return [[UIView alloc]initWithFrame:CGRectZero];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 1) {
        if (self.dataModel.singleProduct.count == 0) {
            return 0;
        }
    }
    if (section == 2) {
        return self.comment.commentList.count + 1;
    }
    
    if (section == 3) {
        if (self.dataModel.collocations.count == 0) {
            return 0;
        }
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            CollectionsHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionsHeaderTableViewCell" forIndexPath:indexPath];
            cell.parentClassName = NSStringFromClass(self.class);

            cell.dataModel = self.dataModel.nowCollocation;
            cell.tagsFrames = self.tagsFrames;
            cell.delegate = self;
            cell.zanBlock = self.zanBlock;
            
            cell.zanBtn.trackingId = [NSString stringWithFormat:@"%@&zanBtn&id=%@",NSStringFromClass(self.class),self.dataModel.nowCollocation.nowCollectionId];
            cell.addThemeBtn.trackingId = [NSString stringWithFormat:@"%@&addThemeBtn&id=%@",NSStringFromClass(self.class),self.dataModel.nowCollocation.nowCollectionId];
            cell.userDelegate = self;
            if ([cell.dataModel.memo isEqual:@""]) {
                cell.descriptionToTop.constant = 0;
            }
            
            [cell.addThemeBtn addTarget:self action:@selector(addThemeBtnClickedAction) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
            break;
        }
            
        case 1:{
            RelatedGoodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RelatedGoodsTableViewCell" forIndexPath:indexPath];
            cell.dataArray = self.dataModel.singleProduct;
            cell.fromCollectionId = self.collectionId;
            
            return cell;
            break;
        }
            
        case 2:{
            if (indexPath.row == self.comment.commentList.count) {
                if (self.comment.countComment.integerValue > self.comment.commentList.count  && !self.clickMoreBtn) {
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
            break;
        }
            
        case 3:{
            RecommendCollectionsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecommendCollectionsTableViewCell"];
            cell.dataArray = self.dataArray;
            cell.collectionID = _collectionId;
//            cell.delegate = self;//collectionsViewController作为RecommendCollectionsTableViewCell的代理获取collection View的点击indexPath变量
            
            [cell.recommendCollectionsColView reloadData];
            return cell;
            break;
        }
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (0 == self.descriptionHeight) {
            return SCREEN_WIDTH/320*320 +20 +10 + self.tagsFrames.tagsHeight +5 +15 +24 +15;
        }
        return SCREEN_WIDTH/320*320 +10 +20 +10 + self.descriptionHeight + self.tagsFrames.tagsHeight +5 +15 +24 +15;
    }
    if (indexPath.section == 1) {
        if (self.dataModel.singleProduct.count == 0) {
            return 0;
        }
        return 40 + SCREEN_WIDTH/320*160 +67;
    }
    if (indexPath.section == 2) {
        if (indexPath.row == self.comment.commentList.count) {
            if (self.comment.countComment.integerValue > self.comment.commentList.count && !self.clickMoreBtn) {
                return [tableView fd_heightForCellWithIdentifier:@"CommentCell2" configuration:^(CommentCell2* cell) {
                    
                }];
            }
            return [tableView fd_heightForCellWithIdentifier:@"CommentCell3" configuration:^(CommentCell3* cell) {
                
            }];
        }
        //return [tableView fd_heightForCellWithIdentifier:@"CommentCell" configuration:^(CommentCell* cell) {
         //   if (self.comment.commentList.count) {
          //      commentListModel *model = self.comment.commentList[indexPath.row];
           //     cell.commentListModel = model;
           //     cell.yyLabelLayoutModel = self.layoutModelList[indexPath.row];
           // }
            
       // }];
        YYLabelLayoutModel *model = self.layoutModelList[indexPath.row];
        return 10+ [self getFontHeight]+ 10+ model.cellHeight +10 + [self getFontHeight] +10+1 ;
    }else{
//        return 30 + 2*(22 + SCREEN_WIDTH/320 *140 + 10 + 63);
//        return 550;
        if (self.dataModel.collocations.count == 0) {
            return 0;
        }
        return 40 + (self.dataArray.count+1)/2*(22 + SCREEN_WIDTH/320 *140 + 10 + 63);
    }
}


- (void)addThemeBtnClickedAction {
    if(![[RJAccountManager sharedInstance]hasAccountLogin]) {
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UINavigationController *loginNav = [story instantiateViewControllerWithIdentifier:@"loginNav"];
        
        [self presentViewController:loginNav animated:YES completion:^{
            
        }];
        return;
    }
    
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC.collectionID = self.collectionId;
    
    getToThemeVC.delegate = self;
    
    getToThemeVC.homeItemTypeTwoModel = self.homeItemTypeTwoModel;

    [self.navigationController pushViewController:getToThemeVC animated:YES];
    
}


#pragma mark -- shareAction
- (void)share:(id)sender{
    if (!self.shareModel) {
        return;
    }

    NSArray *shareType = [NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,nil];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    
    NSString *imageUrl = self.shareModel.img;
    NSString *comment = self.shareModel.memo.length?self.shareModel.memo:@" ";
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


//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        if (!self.collectionId) {
            self.collectionId = @0;
        }
        requestInfo.URLString =[NSString stringWithFormat:@"/b180/api/v1/point/variation?type=32&id=%d",self.collectionId.intValue];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //                        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //                        NSLog(@"%@",error);
        }];
    }
}





#pragma mark - headerView上的用户头像点击
#pragma mark RJTapedUserViewDelegate
- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString*)userName{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!userId) {
        
//        [HTUIHelper addHUDToView:self.view withString:@"去用户中心" hideDelay:1];
        return;
    }
    rootVc.userId = userId;
    rootVc.userName = userName;
    
    [self.navigationController pushViewController:rootVc animated:YES];
}


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
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/collocation/%@/comments/",self.collectionId];
    
    if (textField.text.length) {
        //对评论进行评论
        if (textField == self.textField &&self.collectionId &&self.commentId) {
            [requestInfo.postParams setDictionary:@{@"review_member_id":self.memberId,@"id":self.collectionId ,@"comment":textField.text}];
        }//直接评论
        else if(self.collectionId) {
            [requestInfo.postParams setDictionary:@{@"id":self.collectionId ,@"comment":textField.text}];
        }
    }else{
        [HTUIHelper addHUDToWindowWithString:@"评论不能为空" hideDelay:1];

        return NO;
    }
    textField.text = nil;
    [textField resignFirstResponder];
    
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
                [self.collectionsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
                
            }
            else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                
            }
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"评论失败,请稍后再试" image:nil];
    }];
    
    textField.text = nil;
    
    return YES;
}


#pragma mark --评论头像的代理方法
- (void)celldidClickUser:(CommentListModel *)commentListModel{

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!commentListModel.member.memberId) {
        
//        [HTUIHelper addHUDToView:self.view withString:@"去用户中心" hideDelay:1];
        return;
    }
    rootVc.userId = commentListModel.member.memberId;
    rootVc.userName = commentListModel.member.name;
    
//    [HTUIHelper addHUDToView:self.view withString:@"已可去用户中心" hideDelay:1];

    [self.navigationController pushViewController:rootVc animated:YES];
    
}



#pragma mark --评论的代理方法
- (void)celldidClickLabel:(YYLabel *)label textRange:(NSRange)textRange indexPath:(NSIndexPath *)indexPath{
    NSAttributedString *text = label.textLayout.text;
    if (textRange.location >= text.length) return;
    
    YYTextHighlight *highlight = [text yy_attribute:YYTextHighlightAttributeName atIndex:textRange.location];
    NSDictionary *info = highlight.userInfo;
    if (info[@"memberId"]) {
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
    self.memberId = model.member.memberId;
    self.commentId = model.commentId;
    _textField.placeholder = [NSString stringWithFormat:@"回复: %@", model.member.name];
    
    CommentCell *cell = [self.collectionsTableView cellForRowAtIndexPath:indexPath];
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
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/collocation/%@/comments/",self.collectionId];
    
    if (self.textField1.text.length) {
        
        if (self.collectionId) {
            
            [requestInfo.postParams setDictionary:@{@"id":self.collectionId ,@"comment":self.textField1.text}];
        }
        
    }else{
        [HTUIHelper addHUDToWindowWithString:@"评论不能为空" hideDelay:1];

        return;
    }
    
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"评论成功" image:nil];
            NSDictionary *dict = responseObject[@"data"];
//            NSArray *arr = [dict objectForKey:@"commentList"];
            CommentListModel *model = [[CommentListModel alloc]initWithDictionary:dict error:nil];
            self.comment.countComment = [NSNumber numberWithInteger:self.comment.countComment.integerValue +1];
            if (model) {
                
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:self.comment.commentList];
                [temArray insertObject:model atIndex:0];
                self.comment.commentList = [temArray copy];
                YYLabelLayoutModel *model1 = [self setHighText:model];
                [self.layoutModelList insertObject:model1 atIndex:0];

                [self.collectionsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
                
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
    [self.textField resignFirstResponder];
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
    
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    CommentListModel *model = self.comment.commentList[btn.tag];
    if (self.comment.commentList.count == 1) {
        self.moreCommentModel = [self.comment.commentList firstObject];
    }
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/collocation/comments/%@/",model.commentId];

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
                [self.collectionsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/collocation/%@/comments/?page_index=%d&page_size=4",self.collectionId, commentIndex];

    __weak __typeof(&*self)weakSelf = self;
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            [[HTUIHelper shareInstance] removeHUD];
            NSDictionary *dict = responseObject[@"data"];
            NSArray *arr = [dict objectForKey:@"commentList"];
            
            weakSelf.commentArray = [NSMutableArray arrayWithArray:weakSelf.comment.commentList];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CommentListModel *model = [[CommentListModel alloc]initWithDictionary:obj error:nil];
                YYLabelLayoutModel *model1 = [weakSelf setHighText:model];
                [weakSelf.layoutModelList addObject:model1];
                [weakSelf.commentArray addObject:model];
            }];
            self.comment.commentList = [self.commentArray copy];
            [self.collectionsTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:@"网络请求失败,请稍后再试" image:nil];
    }];
    
}


#pragma mark -- 监听键盘处理方法
/**
 *  Description
 */
//- (void)keyboardWillAppear:(NSNotification *)notification{
//    CGRect currentFrame = self.view.frame;
//    CGFloat change = [self keyboardEndingFrameHeight:[notification userInfo]];
//    currentFrame.origin.y = currentFrame.origin.y - change;
//    self.view.frame = currentFrame;
//}
//
//- (void)keyboardWillDisappear:(NSNotification *)notification{
//    
//    CGRect currentFrame = self.view.frame;
//    CGFloat change = [self keyboardEndingFrameHeight:[notification userInfo]];
//    currentFrame.origin.y = currentFrame.origin.y + change;
//    self.view.frame = currentFrame;
//    
//}

//-(CGFloat)keyboardEndingFrameHeight:(NSDictionary *)userInfo//计算键盘的高度
//{
//    CGRect keyboardEndingUncorrectedFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
//    CGRect keyboardEndingFrame = [self.view convertRect:keyboardEndingUncorrectedFrame fromView:nil];
//    return keyboardEndingFrame.size.height;
//}

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
        CommentCell2 *cell = [self.collectionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.comment.commentList.count inSection:2]];
        CGRect rect = [cell.superview convertRect:cell.frame toView:window];
        [self adjustTableViewToFitKeyboardWithRect:rect];
    }else{
        CommentCell3 *cell = [self.collectionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.comment.commentList.count inSection:2]];
        CGRect rect = [cell.superview convertRect:cell.frame toView:window];
        [self adjustTableViewToFitKeyboardWithRect:rect];
    }
}

- (void)adjustTableViewToFitKeyboardWithRect:(CGRect)rect{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat delta = CGRectGetMaxY(rect) - (window.bounds.size.height - _totalKeybordHeight);
    CGPoint offset = self.collectionsTableView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    
    [self.collectionsTableView setContentOffset:offset animated:YES];
}

- (IBAction)clickAddCartsBtn:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Feng" bundle:nil];
    CollectionsAddCartVC *vc = [sb instantiateViewControllerWithIdentifier:@"CollectionsAddCartVC"];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow]endEditing:YES];
}


@end
