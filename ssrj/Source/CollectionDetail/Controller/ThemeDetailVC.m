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
#import "ThemeCommentCell.h"
#import "ThemeCommentCell2.h"
#import "ThemeCommentCell3.h"
#import "ThemeDetailHeaderView2.h"
#import "NSAttributedString+YYText.h"
#import "HomeViewController.h"
#import "MineFavoriteGoodsViewController.h"
#import "EditThemeManagerViewController.h"
#import "EditPublishThemeViewController.h"
#import "RJUserCentePublishTableViewController.h"


@interface ThemeDetailVC ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,CollectionsViewControllerDelegate, RJTapedUserViewDelegate,UITextFieldDelegate,CommentCellDelegate,UMSocialUIDelegate,EditThemeManagerViewControllerDelegate,EditPublishThemeViewControllerDelegate, UIActionSheetDelegate>
{
    CGFloat _totalKeybordHeight;
    
    int commentIndex;
}
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

@property (strong, nonatomic) CommentModel *comment;
@property (nonatomic,strong) NSMutableArray* commentArray;


@property (nonatomic,strong)UITextField *textField;
@property (nonatomic,strong)UITextField *textField1;
@property (nonatomic,strong)NSNumber *commentId;
@property (nonatomic,strong)NSNumber *memberId;
@property (nonatomic,assign)BOOL clickMoreBtn;


//当首次加载页面后4条评论被删除完的时候，保留最后一条作为参数传给更多评论
@property (nonatomic,strong)CommentListModel *moreCommentModel;

//@property (nonatomic,strong)NSMutableArray *commentHeight;
@property (nonatomic,strong)NSMutableArray *layoutModelList;
@property (nonatomic,strong) UIButton * shareButton;
@property (nonatomic,strong) RJShareBasicModel * shareModel;
@property (nonatomic,strong) RJThemeDetailMatchListFooterView *footerView;


@end

@implementation ThemeDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.trackingId = [NSString stringWithFormat:@"ThemeDetailVC&viewWillAppear&themeItemId=%@",self.themeItemId];
    self.layoutModelList = [NSMutableArray array];
    NSArray *btnArray = @[@1,@2];
    [self addBarButtonItems:btnArray onSide:RJNavRightSide];
    self.shareButton = self.navigationItem.rightBarButtonItems[1].customView;
    self.shareButton.enabled = NO;
    commentIndex = 1;
    if (_isSelf) {
        
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"moreAction"] style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemClicked)];
        
        self.navigationItem.rightBarButtonItem = barButton;
    }
    
    [self setTitle:@"合辑详情" tappable:NO];
    [self addBackButton];
    self.collectionThemeMutableArray = [NSMutableArray array];
    
    __weak __typeof(&*self)weakSelf = self;
    
    self.themesCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getNetData];
        
    }];
    
    
    [self.themesCollectionView registerClass:[ThemeCommentCell class] forCellWithReuseIdentifier:@"ThemeCommentCell"];
    [self.themesCollectionView registerClass:[ThemeCommentCell2 class] forCellWithReuseIdentifier:@"ThemeCommentCell2"];
    [self.themesCollectionView registerClass:[ThemeCommentCell3 class] forCellWithReuseIdentifier:@"ThemeCommentCell3"];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [self.themesCollectionView registerClass:[ThemeDetailHeaderView2 class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ThemeDetailHeaderView2"];
    [self.themesCollectionView registerClass:[ThemeDetailFooterView2 class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ThemeDetailFooterView2"];
    [self.themesCollectionView.mj_header beginRefreshing];
    
    [self setupTextField];
}


#pragma mark -管理合辑内容代理方法
-(void)reloadManagerThemeDataWithIndex:(NSInteger)index {
    
    //优化前方法
    [self getNetData];
}

#pragma mark -未发布合辑的合辑详情UI点击发布按钮后刷新本UI
-(void)reloadThemeDetailData {
    
    [self getNetData];
}


#pragma mark -搭配详情代理方法，通知本合辑详情刷新数据及cell
- (void)reloadZanMessageNetDataWithBtnstate:(BOOL)btnSelected{
    //模型重新赋值
    ThemeCollocationList *collocationList = self.collectionThemeMutableArray[_indexPath.row];
    collocationList.isThumbsup = btnSelected;
    //局部刷新
    [self.themesCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_indexPath.row inSection:0]]];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    _textField.hidden = YES;
    [MobClick beginLogPageView:@"合辑详情页面"];
    [TalkingData trackPageBegin:@"合辑详情页面"];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _textField.hidden = YES;
    [MobClick endLogPageView:@"合辑详情页面"];
    [TalkingData trackPageEnd:@"合辑详情页面"];

    
    [_textField resignFirstResponder];
}


#pragma mark --编辑nav barButtonItemClicked
- (void)barButtonItemClicked {
    
    if (_event.intValue == 2) {
        
        //点赞
        UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:self.data.thumbsup?@"取消点赞":@"点赞",nil];
        menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [menu showInView:self.view];
        
    }
    else {
        
        if (!_isPublished) {
            
            UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发布",@"编辑",@"管理合辑内容",@"删除合辑",nil];
            menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [menu showInView:self.view];
            menu.tag = 100;//未发布
            
        }
        else {
            
            UIActionSheet *menu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"管理合辑内容",@"删除合辑",nil];
            menu.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
            [menu showInView:self.view];
            menu.tag = 101;//已发布
            
        }
        
    }
    
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    
    if (_event.intValue == 2) {
        
        if (buttonIndex == 0) {
            
            //TODO:调用取消点赞方法
            [self zanButtonClicked];

        }
        
    }
    else {
        
        //已发布
        if (actionSheet.tag == 101) {
            
            if (buttonIndex == 0) {
                
                //管理合辑内容
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                
                EditThemeManagerViewController *editMVC = [sb instantiateViewControllerWithIdentifier:@"EditThemeManagerViewController"];
                editMVC.themeId = _themeItemId;
                editMVC.delegate = self;
                [self.navigationController pushViewController:editMVC animated:YES];
                
            }
            else if (buttonIndex == 1) {
                
                //删除提示
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除合辑后将无法找回，确认要删除吗?" delegate:self cancelButtonTitle:@"再思考一下" otherButtonTitles:@"确定", nil];
                [alert show];
                alert.tag = actionSheet.tag;
            }
        }
        
        //未发布
        else if (actionSheet.tag == 100) {
            
            if (buttonIndex == 0 || buttonIndex == 1) {
                
                //编辑合辑
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                
                EditPublishThemeViewController *editThemeVC = [sb instantiateViewControllerWithIdentifier:@"EditPublishThemeViewController"];
                
                editThemeVC.creatThemeID = _themeItemId;
                editThemeVC.themeName = self.data.name;
                editThemeVC.themeDescribe = self.data.memo;
                //            editThemeVC.delegate = self;
                
                [self.navigationController pushViewController:editThemeVC animated:YES];
                
            }
            else if (buttonIndex == 2) {
                
                //管理合辑内容
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
                
                EditThemeManagerViewController *editMVC = [sb instantiateViewControllerWithIdentifier:@"EditThemeManagerViewController"];
                editMVC.themeId = _themeItemId;
                editMVC.delegate = self;
                [self.navigationController pushViewController:editMVC animated:YES];
                
            }
            else if (buttonIndex == 3) {
                
                //删除提示
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"删除合辑后将无法找回，确认要删除吗?" delegate:self cancelButtonTitle:@"再思考一下" otherButtonTitles:@"确定", nil];
                alert.tag = actionSheet.tag;
                [alert show];
            }
            
        }
        
    }
    
}

#pragma mark - UIAlertViewDelegate方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    //主题（合辑）
    if (buttonIndex == 1) {
            
        [HTUIHelper addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"删除合辑" hideDelay:1];
            
        [self deleteSelfPublishWithUrlstring:[NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/detail/%@/",_themeItemId] index:alertView.tag];
    }
}

#pragma mark -删除合辑方法
- (void)deleteSelfPublishWithUrlstring:(NSString *)urlStr index:(NSInteger) index {
    
    //    [self.dataArray removeObjectAtIndex:index];
    //
    //    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    
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
                
                if (weakSelf.delegate) {
                    
                    if ([weakSelf.delegate isKindOfClass:[RJUserCentePublishTableViewController class]]) {
                        
                        if ([weakSelf.delegate respondsToSelector:@selector(reloadUserCenterPublishTableViewData)]) {
                            
                            [weakSelf.delegate reloadUserCenterPublishTableViewData];
                        }
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


#pragma mark -- shareAction
- (void)share:(id)sender {
    
    NSArray *shareType = [NSArray arrayWithObjects:UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline,nil];
    [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    NSString *imageUrl = self.shareModel.img;
    NSString *comment = self.shareModel.memo.length?self.shareModel.memo:@"";
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

#pragma mark -- 下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        ZHRequestInfo *requestInfo = [ZHRequestInfo new];
        if (!self.themeItemId) {
            self.themeItemId = @0;
        }
        requestInfo.URLString =[NSString stringWithFormat:@"/b180/api/v1/point/variation?type=34&id=%d",self.themeItemId.intValue];
        
        [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //                        NSLog(@"%@",responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //                        NSLog(@"%@",error);
        }];
    }
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
    _textField.frame = CGRectMake(0., [UIScreen mainScreen].bounds.size.height, self.view.width, 38);
    _textField.returnKeyType = UIReturnKeySend;
    [[UIApplication sharedApplication].keyWindow addSubview:_textField];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (void)getNetData{  // v4 --> v5  add 11.29
    self.clickMoreBtn = NO;

    [self.layoutModelList removeAllObjects];
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    _pageNumber = 1;
    
    ///b82/api/v5/goods/findcollocationlist?pageIndex=0&pageSize=10&thememItemId=xxx&&appVersion=xxx)  v5 add 11.29
    
    //v5
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/goods/findcollocationlist?pageIndex=%d&pageSize=10", _pageNumber];

    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    
    if (self.themeItemId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"thememItemId":self.themeItemId}];
    }
    __weak __typeof(&*self)weakSelf = self;
    requestInfo.modelClass = [ThemeDetailModel class];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {

            ThemeDetailModel *model = responseObject;
            NSNumber *state = model.state;
            if (state.integerValue == 0) {
                ThemeData *data = model.data;
                if (data.shareInfo) {
                    self.shareModel =  data.shareInfo;
                    self.shareButton.enabled = YES;
                }
                weakSelf.comment = data.comment;
                [weakSelf.comment.commentList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    CommentListModel *model = obj;
                    YYLabelLayoutModel *model1 = [self setHighText:model];
                    [weakSelf.layoutModelList addObject:model1];
                }];
                
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
            
            [weakSelf.themesCollectionView.mj_header endRefreshing];
            [weakSelf.footerView setNormalState];


        [weakSelf.themesCollectionView.mj_header endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.themesCollectionView.mj_header endRefreshing];
        [weakSelf.footerView setNormalState];
    }];
}


#pragma mark --设置YYLabel高亮
- (YYLabelLayoutModel *)setHighText:(CommentListModel *)model{
    //NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:model.comment ];
    
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


#pragma -collectionView




#pragma mark --headerView 点赞button事件
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


#pragma mark -- headerView 评论button事件
- (void)commentButtonClicked {
    
    if (_collectionThemeMutableArray.count > 4) {
        
        CGFloat offsetY = self.themesCollectionView.contentSize.height - SCREEN_HEIGHT + 64;
        
        self.themesCollectionView.contentOffset = CGPointMake(0, offsetY);
    }
}


- (void)sendThumbUpToNetwork{
        
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=theme_item&id=%@",_themeItemId];
    if ([RJAccountManager sharedInstance].token) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }

//    if (self.parameterDictionary) {
//        [requestInfo.getParams addEntriesFromDictionary:self.parameterDictionary];
//    }
    
    __weak __typeof(&*self)weakSelf = self;

    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            
            if (state.intValue == 0) {
                
                NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                NSNumber *thumb = [responseObject[@"data"] objectForKey:@"thumb"];
                
                //用户已点赞
                weakSelf.data.thumbsup = thumb.boolValue;
                
                weakSelf.data.thumbsupCount = thumbCount;
                
                [weakSelf.themesCollectionView reloadData];
                
                //header上主题点赞或取消点赞后通过代理给上级UI（RJHomeSubjectAndCollectionCell）发送更新数据请求
                
                if (weakSelf.delegate &&[weakSelf.delegate respondsToSelector:@selector(reloadHomeZanMessageNetDataWithBtnstate:)]) {
                        
                    [weakSelf.delegate reloadHomeZanMessageNetDataWithBtnstate:thumb.boolValue];
                }
                
            }
            else if (state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:0.5];
            }
            

            
        } else {
         
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.themesCollectionView.mj_header endRefreshing];
    }];
}

//#pragma mark -计算cell评论内容的高度
////- (CGFloat)HeightForText:(NSString *)text withFontSize:(CGFloat)fontSize withTextWidth:(CGFloat)textWidth
//- (CGFloat)HeightForText:(NSString *)text
//{
//    // 获取文字字典
//    NSDictionary *dict = @{NSFontAttributeName: [UIFont systemFontOfSize:17]};
//    // 设定最大宽高
//    CGSize size = CGSizeMake(SCREEN_WIDTH - 10-34-10, MAXFLOAT);
//    // 计算文字Frame
//    CGRect frame = [text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:dict context:nil];
//    return frame.size.height;
//}


#pragma mark - collectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 2;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return self.collectionThemeMutableArray.count;
    }else{
        return self.comment.commentList.count + 1;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        
        ThemeDetailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThemeDetailCollectionViewCell" forIndexPath:indexPath];
        
        //喜欢button点击事件
        [cell.likeItButton addTarget:self action:@selector(likeItButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.likeItButton.tag = indexPath.row;
        
        //添加button点击事件
        [cell.plusButton addTarget:self action:@selector(plusButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.plusButton.tag = indexPath.row;
        ThemeCollocationList *list = self.collectionThemeMutableArray[indexPath.row];
        cell.collocationList = list;
        cell.userDelegate = self;
        cell.trackingId = [NSString stringWithFormat:@"%@&ThemeDetailCollectionViewCell&%@",NSStringFromClass([self class]),list.collocationId];
        cell.likeItButton.trackingId = [NSString stringWithFormat:@"%@&ThemeDetailCollectionViewCell&likeItButton&%@",NSStringFromClass([self class]),list.collocationId];
        return cell;
    }else{
        if (indexPath.item == self.comment.commentList.count) {
            if (self.data.comment.countComment.integerValue > self.data.comment.commentList.count && !self.clickMoreBtn) {
                ThemeCommentCell2 *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThemeCommentCell2" forIndexPath:indexPath];
                cell.textField.delegate = self;
                self.textField1 = cell.textField;
                cell.label.text = @"展开更多评论";
                [cell.sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
                [cell.moreCommentBtn addTarget:self action:@selector(moreComment) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
            ThemeCommentCell3 *cell1 = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThemeCommentCell3" forIndexPath:indexPath];
            cell1.textField.delegate = self;
            self.textField1 = cell1.textField;
            [cell1.sendButton addTarget:self action:@selector(sendComment) forControlEvents:UIControlEventTouchUpInside];
            return cell1;
            
            
        }
        ThemeCommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThemeCommentCell" forIndexPath:indexPath];
        cell.deleteButton.tag = indexPath.row;
        [cell.deleteButton addTarget:self action:@selector(deleteComment:) forControlEvents:UIControlEventTouchUpInside];
        CommentListModel *model = self.comment.commentList[indexPath.item];
        YYLabelLayoutModel *model1 = self.layoutModelList[indexPath.row];
        cell.yyLabelLayoutModel = model1;
        cell.commentListModel = model;
        cell.delegate = self;
        cell.indexPath = indexPath;
        
        return cell;
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (kind == UICollectionElementKindSectionHeader) {
        if (indexPath.section == 0) {
            
            ThemeDetailHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ThemeDetailHeaderView" forIndexPath:indexPath];
            header.data = self.data;
            header.headerUserDelegate = self;
            
            if (_isSelf && !_isPublished) {
                
                [header.publishedHeaderDataView setHidden:YES];
                [header.unPublishedHeaderDataView setHidden:NO];
                [header.zanBgView setHidden:YES];
                [header.commentBgView setHidden:YES];
                [header.publishButton setHidden:NO];
                [header.publishButton addTarget:self action:@selector(publishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
                
            }
            else if (_isSelf && _isPublished) {
                
                [header.publishedHeaderDataView setHidden:NO];
                [header.unPublishedHeaderDataView setHidden:YES];
                [header.zanBgView setHidden:NO];
                [header.commentBgView setHidden:NO];
                [header.publishButton setHidden:YES];
            }
                        
            //点赞button事件
            [header.zanButton addTarget:self action:@selector(zanButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
            [header.commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            
            [header updateConstraintsIfNeeded];
            [header updateConstraints];
            return header;
        }
        if (indexPath.section == 1) {
            ThemeDetailHeaderView2 *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ThemeDetailHeaderView2" forIndexPath:indexPath];
            header.count.text = [NSString stringWithFormat:@"%lu",(unsigned long)self.data.comment.countComment.integerValue];
            [header updateConstraintsIfNeeded];
            [header updateConstraints];
            return header;
        }
    }
    if (kind == UICollectionElementKindSectionFooter) {
        if (indexPath.section == 0) {
//            if (!self.footerView) {
                self.footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"RJThemeDetailMatchListFooterView" forIndexPath:indexPath];
//                self.footerView.activityView.hidden = YES;
                [self.footerView.button addTarget:self action:@selector(nextCollectionButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//            }
            return self.footerView;
        }else{
            ThemeDetailFooterView2 *view = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"ThemeDetailFooterView2" forIndexPath:indexPath];
//            view.backgroundColor = [UIColor redColor];
            return view;
        }
    }
    
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CGSizeMake(SCREEN_WIDTH/2 , SCREEN_WIDTH/2  + 60);
    }else{
        if (indexPath.item == self.comment.commentList.count) {
            if (self.data.comment.countComment.integerValue > self.data.comment.commentList.count && !self.clickMoreBtn) {
                return CGSizeMake(SCREEN_WIDTH, 89);
            }
            return CGSizeMake(SCREEN_WIDTH, 51);
        }
        YYLabelLayoutModel *model = self.layoutModelList[indexPath.row];
        CGFloat height = 10+ [self getFontHeight]+ 10+ model.cellHeight +10 + [self getFontHeight] +10+1 ;
        return CGSizeMake(SCREEN_WIDTH, height);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        
        CGFloat textHeight =0;
        
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineBreakMode = NSLineBreakByCharWrapping;
        CGSize size = [self.data.memo boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 16, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:style} context:nil].size;
        textHeight = size.height;
        
        return CGSizeMake(SCREEN_WIDTH, SCREEN_WIDTH*7/16+8+textHeight+51+5);
    }
    return CGSizeMake(SCREEN_WIDTH, 50);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeMake(SCREEN_WIDTH, 44);
    }
    return CGSizeZero;
;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
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
    
}

#pragma mark -未发布的合辑点击发布按钮响应事件
- (void)publishButtonClicked {
    
    //编辑合辑
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    EditPublishThemeViewController *editThemeVC = [sb instantiateViewControllerWithIdentifier:@"EditPublishThemeViewController"];
    
    editThemeVC.creatThemeID = _themeItemId;
    editThemeVC.themeName = self.data.name;
    editThemeVC.themeDescribe = self.data.memo;
    editThemeVC.delegate = self;
    
    [self.navigationController pushViewController:editThemeVC animated:YES];
    
}


#pragma mark -
#pragma mark 加载更多搭配
- (void)nextCollectionButtonAction:(id)sender{
    if (!self.footerView.state == FooterNormal) {
        return;
    }
    [self.footerView setLoadingState];
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //v5
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/goods/findcollocationlist?pageIndex=%d&pageSize=10", _pageNumber];
    
    if (self.themeItemId) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"thememItemId":self.themeItemId}];
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
                    [self.footerView setNomoreState];
                    return ;
                }
                [self.footerView setNormalState];
                _pageNumber += 1;
                
                //TODO:collectionCell数据使用collectionThemeMutableArray的数据
                [weakSelf.collectionThemeMutableArray addObjectsFromArray:data.collocationList];
//                weakSelf.data = data;
                [weakSelf.themesCollectionView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:model.msg hideDelay:2];
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [self.footerView setNormalState];

    }];

    
    
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
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v5/thumb?type=collocation&id=%@",_themeItemId];
    
    __weak __typeof(&*self)weakSelf = self;

    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {

            NSNumber *state = [responseObject objectForKey:@"state"];

            
            if (state.intValue == 0) {
                
                //NSNumber *thumbCount = [responseObject[@"data"] objectForKey:@"thumbCount"];
                
                NSNumber *thumb = [responseObject[@"data"] objectForKey:@"thumb"];
                
                //点赞成功
                [collectionList setValue:thumb forKey:@"isThumbsup"];
                
                //局部刷新
                [weakSelf.themesCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:button.tag inSection:0]]];
                
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

#pragma mark -- collection View Cell 内的添加合辑到我的收藏 button事件
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
    
    ThemeCollocationList *collectionList = self.collectionThemeMutableArray[button.tag];

    //TODO:添加cell内主题是否已被点赞字段&是否已被添加至个人收藏字段
    //TODO:请求网络数据
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    GetToThemeViewController *getToThemeVC = [story instantiateViewControllerWithIdentifier:@"GetToThemeViewController"];
    
    getToThemeVC.collectionID = collectionList.collocationId;
    getToThemeVC.parameterDictionary = @{@"colloctionId":collectionList.collocationId};
    
    [self.navigationController pushViewController:getToThemeVC animated:YES];
    
}

#pragma mark -
#pragma mark RJTapedUserViewDelegate
- (void)didTapedUserViewWithUserId:(NSNumber *)userId userName:(NSString*)userName{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Brand" bundle:nil];
    RJUserCenteRootViewController *rootVc = [storyBoard instantiateViewControllerWithIdentifier:@"RJUserCenteRootViewController"];
    if (!userId) {
        return;
    }
    rootVc.userId = userId;
    rootVc.userName = userName;
    
    [self.navigationController pushViewController:rootVc animated:YES];
}

#pragma mark --更多评论
- (void)moreComment{
    
    self.clickMoreBtn = YES;
    commentIndex++;
    ZHRequestInfo *requestInfo = [[ZHRequestInfo alloc] init];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/%@/comments/?page_index=%d&page_size=4", self.themeItemId, commentIndex];
    
    __weak __typeof(&*self)weakSelf = self;
    [[HTUIHelper shareInstance]addHUDToView:self.view withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            [[HTUIHelper shareInstance] removeHUD];
            NSDictionary *dict = responseObject[@"data"];
            NSArray *arr = [dict objectForKey:@"commentList"];
            self.commentArray = [NSMutableArray arrayWithArray:self.comment.commentList];
            [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CommentListModel *model = [[CommentListModel alloc]initWithDictionary:obj error:nil];
                YYLabelLayoutModel *model1 = [weakSelf setHighText:model];
                [weakSelf.layoutModelList addObject:model1];
                [self.commentArray addObject:model];

            }];
            self.comment.commentList = [self.commentArray copy];
            [self.themesCollectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
    }];
    
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
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/%@/comments/", self.themeItemId];
    
    if (self.textField1.text.length) {
        [requestInfo.postParams setDictionary:@{@"id":self.themeItemId ,@"comment":self.textField1.text}];
    }else{
        [HTUIHelper addHUDToWindowWithString:@"评论不能为空" hideDelay:1];

        return;
    }
    __weak __typeof(&*self)weakSelf = self;
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *number = responseObject[@"state"];
        
        if (number == nil) {
            [[HTUIHelper shareInstance] removeHUDWithEndString:@"评论失败" image:nil];
            [weakSelf.textField1 resignFirstResponder];
            return ;
        }
        
        if (number.boolValue == 0) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"评论成功" image:nil];
            
            weakSelf.data.comment.countComment = [NSNumber numberWithInteger:self.data.comment.countComment.integerValue + 1];
            NSDictionary *dict = responseObject[@"data"];

            CommentListModel *model = [[CommentListModel alloc]initWithDictionary:dict error:nil];
            if (model) {
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:self.comment.commentList];
                [temArray insertObject:model atIndex:0];
                weakSelf.comment.commentList = [temArray copy];
                YYLabelLayoutModel *model1 = [self setHighText:model];
                [weakSelf.layoutModelList insertObject:model1 atIndex:0];
                
//                CGFloat height = [weakSelf HeightForText:model.comment];
//                [_commentHeight addObject:[NSNumber numberWithFloat:height]];
                [weakSelf.themesCollectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
                
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                
            }
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
    }];
    
    self.textField1.text = nil;
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
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/comments/%@/",model.commentId];
    
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance] deleteWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSNumber *number = responseObject[@"state"];
        if (number.boolValue == 0) {
            self.data.comment.countComment = [NSNumber numberWithInteger:self.data.comment.countComment.integerValue - 1];
            
            if (btn.tag != self.comment.commentList.count) {
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.comment.commentList];
                [temp removeObjectAtIndex:btn.tag];
                self.comment.commentList = [temp copy];
                [self.layoutModelList removeObjectAtIndex:btn.tag];
//                [self.commentHeight removeObjectAtIndex:indexPath.item];
                [self.themesCollectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
            }
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
    }];
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
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/theme_item/%@/comments/", self.themeItemId];
    
    if (textField.text.length) {
        if (textField == self.textField && self.commentId &&self.themeItemId) {
            [requestInfo.postParams setDictionary:@{@"review_member_id":self.memberId,@"id":self.themeItemId ,@"comment":textField.text}];
        }else if(self.themeItemId){
            [requestInfo.postParams setDictionary:@{@"id":self.themeItemId,@"comment":textField.text}];
        }
    }else{
        [HTUIHelper addHUDToWindowWithString:@"评论不能为空" hideDelay:1];

        return NO;
    }
    _textField.text = nil;
    [_textField resignFirstResponder];
    __weak __typeof(&*self)weakSelf = self;
    [[HTUIHelper shareInstance]addHUDToView:[UIApplication sharedApplication].keyWindow withString:@"" xOffset:0 yOffset:0];
    [[ZHNetworkManager sharedInstance]postWithRequestInfoWithoutJsonModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSNumber *number = responseObject[@"state"];
        
        if (number == nil) {
            
            [[HTUIHelper shareInstance] removeHUDWithEndString:@"评论失败" image:nil];
            [textField resignFirstResponder];
            return ;
        }
        if (number.intValue == 0) {
            [[HTUIHelper shareInstance]removeHUDWithEndString:@"评论成功" image:nil];
            
            self.data.comment.countComment = [NSNumber numberWithInteger:self.data.comment.countComment.integerValue + 1];
            NSDictionary *dict = responseObject[@"data"];

            CommentListModel *model = [[CommentListModel alloc]initWithDictionary:dict error:nil];
            if (model) {
                
                NSMutableArray *temArray = [NSMutableArray arrayWithArray:weakSelf.comment.commentList];
                [temArray insertObject:model atIndex:0];
                weakSelf.comment.commentList = [temArray copy];
//                CGFloat height = [weakSelf HeightForText:model.comment];
//                [_commentHeight addObject:[NSNumber numberWithFloat:height]];
                YYLabelLayoutModel *model1 = [self setHighText:model];
                [weakSelf.layoutModelList insertObject:model1 atIndex:0];
                [weakSelf.themesCollectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
              
            }else{
                [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
                
            }
            
        }else{
            
            [[HTUIHelper shareInstance]removeHUDWithEndString:responseObject[@"msg"] image:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[HTUIHelper shareInstance]removeHUDWithEndString:[error localizedDescription] image:nil];
    }];
    
    textField.text = nil;
    
    return YES;
}


#pragma mark --评论头像的代理方法
- (void)celldidClickUser:(CommentListModel *)commentListModel{
//    NSLog(@"点击了用户头像");
    
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
//        NSLog(@"点击%@",info[@"memberId"]);
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
    
    ThemeCommentCell *cell =(ThemeCommentCell *)[self.themesCollectionView cellForItemAtIndexPath:indexPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:[UIApplication sharedApplication].keyWindow];
    rect.origin.y = rect.origin.y + 44;
    [self adjustTableViewToFitKeyboardWithRect:rect];
    
}

#pragma mark -- 监听键盘处理方法
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
        ThemeCommentCell2 *cell =(ThemeCommentCell2 *) [self.themesCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.comment.commentList.count inSection:1]];
        CGRect rect = [cell.superview convertRect:cell.frame toView:window];
        [self adjustTableViewToFitKeyboardWithRect:rect];
    }else{
        ThemeCommentCell3 *cell =(ThemeCommentCell3 *)[self.themesCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.comment.commentList.count inSection:1]];
        CGRect rect = [cell.superview convertRect:cell.frame toView:window];
        [self adjustTableViewToFitKeyboardWithRect:rect];
    }
}

- (void)adjustTableViewToFitKeyboardWithRect:(CGRect)rect{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGFloat delta = CGRectGetMaxY(rect) - (window.bounds.size.height - _totalKeybordHeight);
    CGPoint offset = self.themesCollectionView.contentOffset;
    offset.y += delta;
    if (offset.y < 0) {
        offset.y = 0;
    }
    
    [self.themesCollectionView setContentOffset:offset animated:YES];
}




- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [[[UIApplication sharedApplication] keyWindow]endEditing:YES];
}

@end



@implementation RJThemeDetailMatchListFooterView
- (void)awakeFromNib{
    [super awakeFromNib];
}
- (void)setNormalState{
    self.button.hidden = NO;
    self.button.titleLabel.text = @"展开更多搭配";
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
    self.state = FooterNormal;
}
- (void)setLoadingState{
    self.button.hidden = YES;
    self.activityView.hidden = NO;
    [self.activityView startAnimating];
    self.state = FooterLoading;

}
- (void)setNomoreState{
    self.button.hidden = NO;
    self.button.titleLabel.text = @"已经没有了～";
    self.activityView.hidden = YES;
    [self.activityView stopAnimating];
    self.state = FooterNoMore;
}

@end
