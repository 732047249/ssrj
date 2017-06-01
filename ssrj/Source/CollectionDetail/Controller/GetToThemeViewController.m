//
//  GetToThemeViewController.m
//  ssrj
//
//  Created by YiDarren on 16/7/26.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "GetToThemeViewController.h"
#import "AddToNewThemeModel.h"
#import "GuideView.h"
#import "RJUserCenteRootViewController.h"
#import "SearchForCreateMatchViewController.h"
#import "UIButton+AFNetworking.h"
//加入合辑标签模型
#import "ThemeLabelForSearchModel.h"
#import "Masonry.h"


#define LeftRightMargin 15
#define BetweenMargin  8
#define TopMargin  8
#define ButtonHeight 24

@interface GetToThemeViewController ()<SearchForCreateMatchViewControllerDelegate>

@property (strong, nonatomic) NSMutableArray *labelArray;
//记录原始标签label的id的 数组
@property (strong, nonatomic) NSArray *originalArray;

@property (strong, nonatomic) IBOutlet UIView *buttonBackgroundView;
//label标签背景view高度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelBgViewHeightConstraint;
//合辑自动标签下方LineView
@property (strong, nonatomic) UIView *lineView;
//已有合辑
@property (strong, nonatomic) UILabel *existedAlreadyLabel;
//已经加入的合辑
@property (strong, nonatomic) UILabel *existLabel;



@end

@implementation GetToThemeViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self addBackButton];
    
    self.title = @"收集到合辑";
    
//  debug
//    _labelArray = [NSMutableArray arrayWithArray:@[@"秋日优雅",@"秋冬外套",@"毛毛外套",@"温暖高订单级灰",@"暖暖"]];
        //完成按钮
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(navBarButtonAction)];
    self.navigationItem.rightBarButtonItem = barButton;
    
    
    __weak __typeof(&*self)weakSelf = self;
    //标签label背景viewframe设置
    CGRect frame = _buttonBackgroundView.frame;
    frame.size.height = 0;
    _buttonBackgroundView.frame = frame;
    
    _LineHeight.constant = 0.7;
    
    self.themeImageView.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    self.themeImageView.layer.borderWidth = 0.7;
    self.searchBgView.layer.cornerRadius = 3;
    self.searchBgView.layer.masksToBounds = YES;
    
    _lineView = [[UIView alloc] init];
    _existedAlreadyLabel = [[UILabel alloc] init];
    _existLabel = [[UILabel alloc] init];
    
    //获取标签数据
    [weakSelf getThemeLabelData];
    
    
    //显示标签label
    [self displayLabelView];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        //获取已有合辑数据
        [weakSelf getNetData];
        //tableView数据
        [weakSelf getThemeNetData];

    }];
    
    [self.tableView.mj_header beginRefreshing];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self displayLabelView];

//    [self addGuideView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [MobClick beginLogPageView:@"添加到合辑页面"];
    [TalkingData trackPageBegin:@"添加到合辑页面"];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [MobClick endLogPageView:@"添加到合辑页面"];
    [TalkingData trackPageEnd:@"添加到合辑页面"];
    
}

#pragma mark -- 搜索合辑代理方法
//from SearchForCreateMatchViewController
-(void)reloadLabelDataWithModel:(ThemeLabelForSearchModel *)model {
    
    BOOL shouldReloadLabel = YES;
    
    if (model.isPublish) {
        
        //根据搭配id or name来区分是否重复
        NSString *newLabelStr = [model.id stringValue];
        
        for (ThemeLabelForSearchModel *tempModel in _labelArray) {
            if ([tempModel.id.stringValue isEqualToString:newLabelStr]) {
                
                shouldReloadLabel = NO;
            }
        }
        
        for (ThemeLabelForSearchModel *tempModel in _labelArray) {
            
            if ([tempModel.name isEqualToString:model.name]) {
                
                shouldReloadLabel = NO;
            }
        }
    } else {
    
        NSString *newLabelStr = model.id.stringValue;
    
        for (ThemeLabelForSearchModel *tempModel in _labelArray) {
            if ([tempModel.id.stringValue isEqualToString:newLabelStr]) {
                
                shouldReloadLabel = NO;
            }
        }
    }
    
    if (shouldReloadLabel) {
        
        [_labelArray addObject:model];
        
        for (UIView *tempView in _buttonBackgroundView.subviews) {
            
            [tempView removeFromSuperview];
        }
        
        CGRect frame = _buttonBackgroundView.frame;
        frame.size.height = 0;
        _buttonBackgroundView.frame = frame;
        
        //刷新标签显示
        [self displayLabelView];
        
        if (_labelArray.count==0) {
            
            CGRect frame = _buttonBackgroundView.frame;
            frame.size.height = 35;
            _buttonBackgroundView.frame = frame;
            
            CGRect tableFrame = _tableView.frame;
            tableFrame.origin.y = CGRectGetMaxY(_buttonBackgroundView.frame);
            _tableView.frame = tableFrame;
        }
        
        //刷新已有合辑
        [self getThemeNetData];
        
    } else {
        
        [HTUIHelper addHUDToView:self.view withString:@"请不要重复添加" hideDelay:1];
    }
    
}


/**
 *  3.0.0
 */

//获取已有合辑
- (void)getThemeNetData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    _pageNumber = 1;
    _pageSize = 10;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(_pageNumber) forKey:@"pagenum"];
    [dict setObject:@(_pageSize) forKey:@"pagesize"];
    requestInfo.URLString = @"/b180/api/v1/collocationupload/mytheme";
    requestInfo.getParams = dict;
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"state"] intValue] == 0) {
            
            _pageNumber++;
            [_themeMutableArr removeAllObjects];
            
            NSMutableArray *tempArr = [NSMutableArray array];
            
            for (NSDictionary *dict in responseObject[@"data"]) {
                NSError *error;
                SMThemeModel * model = [[SMThemeModel alloc] initWithDictionary:dict error:&error];
                if (!error) {
                    
                    [tempArr addObject:model];
                    
                }
            }
            
            weakSelf.themeMutableArr = tempArr.mutableCopy;
            
            [_tableView reloadData];
            [_tableView.mj_header endRefreshing];
            if (weakSelf.themeMutableArr.count < _pageSize) {
                [weakSelf.tableView.mj_footer setHidden:YES];
            }else {
                [weakSelf.tableView.mj_footer resetNoMoreData];
            }
        }else{
            [HTUIHelper addHUDToView:weakSelf.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            [_tableView.mj_header endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:weakSelf.view withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}
//获取已有合辑
- (void)getNextThemeData {
    __weak __typeof(&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:@(_pageNumber) forKey:@"pagenum"];
    [dict setObject:@(_pageSize) forKey:@"pagesize"];
    requestInfo.URLString = @"/b180/api/v1/collocationupload/mytheme";
    requestInfo.getParams = dict;
    
    if ([[RJAccountManager sharedInstance] hasAccountLogin]) {
        
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].account.token}];
    }
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([[responseObject objectForKey:@"state"] intValue] == 0) {
            _pageNumber++;
            if ([responseObject[@"data"] count] < _pageSize) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else {
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            
            NSMutableArray *tempArr = [NSMutableArray array];
            
            for (NSDictionary *dict in responseObject[@"data"]) {
                NSError *error;
                SMThemeModel * model = [[SMThemeModel alloc] initWithDictionary:dict error:&error];
                if (!error) {
                    
                    [tempArr addObject:model];
                }
            }
            
            self.themeMutableArr = tempArr.mutableCopy;

            [_tableView reloadData];
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            [_tableView.mj_header endRefreshing];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:2];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}



//- (void)addGuideView{
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"CreatNewThemeViewController"]) {
//        GuideView *guidView = [[GuideView alloc]initWithFrame:[UIScreen mainScreen].bounds];
//        guidView.identifier = @"CreatNewThemeViewController";
//        if (DEVICE_IS_IPHONE4) {
//            guidView.localImage = @"2-4s";
//        }
//        if (DEVICE_IS_IPHONE5) {
//            guidView.localImage = @"2-5s";
//        }
//        if (DEVICE_IS_IPHONE6) {
//            guidView.localImage = @"2-6";
//        }
//        if (DEVICE_IS_IPHONE6Plus) {
//            guidView.localImage = @"2-6p";
//        }
//        UIWindow *window = [UIApplication sharedApplication].keyWindow;
//        [window addSubview:guidView];
//        
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"CreatNewThemeViewController"];
//    }
//}


//设置所要添加的主题的信息：图片、title、描述、用户头像、用户Name、是否点赞、点赞num
- (void)setThemeInfoData{
    
    
    if (self.dataModel.name.length == 0) {
        self.themeTitleLabel.text = @"还尚未设置哦";
    } else {
        
        self.themeTitleLabel.text = self.dataModel.name;
    }
    
    if (self.dataModel.memo.length == 0) {
        self.themeDescribeLabel.text = @"还尚未设置哦";
    } else {
        
        self.themeDescribeLabel.text = self.dataModel.memo;
    }
    
    [self.themeImageView sd_setImageWithURL:[NSURL URLWithString:self.dataModel.picture] placeholderImage:[UIImage imageNamed:@"default_1x1"]];

    
}

#pragma mark -- 请求header部分网络数据
- (void)getNetData {
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    _pageNumber = 1;
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b82/api/v3/goods/findcollocationwiththeme?pageIndex=1&pageSize=10&colloctionId=%d", _collectionID.intValue];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.getParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    [[ZHNetworkManager sharedInstance]getWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                AddToNewThemeModel *model = [[AddToNewThemeModel alloc] initWithDictionary:[responseObject objectForKey:@"data"] error:nil];
                
                weakSelf.dataModel = model;
                
                //设置所要添加的主题的信息：图片、title、描述、用户头像、用户Name、是否点赞、点赞num
                [weakSelf setThemeInfoData];
                
                /**
                 *      [self displayLabelView];
                 */
                
                [weakSelf displayLabelView];

                
            }else if (state.intValue == 1){
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

#pragma mark -- 主题标签数据获取
- (void)getThemeLabelData {
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    //http://b82.ssrj.com/api/v5/goods/findthemeitemtag?collocaltionId=6031&token=xxx&appVersion=xxx
    
    NSString *urlStr = [NSString stringWithFormat:@"https://b82.ssrj.com/api/v5/goods/findthemeitemtag?collocaltionId=%@",_collectionID];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    
    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *state = [responseObject objectForKey:@"state"];
            if (state.intValue == 0) {
                
                NSArray *labelListArray = responseObject[@"data"];
                
                [weakSelf.labelArray removeAllObjects];
                
                NSMutableArray *tempArray = [NSMutableArray array];
                
                for (NSDictionary *dic in labelListArray) {
                    ThemeLabelForSearchModel *model = [[ThemeLabelForSearchModel alloc] initWithDictionary:dic error:nil];
                    
                    if (model) {
                        
                        [tempArray addObject:model];
                    }
                }
                
                weakSelf.labelArray = tempArray.mutableCopy;
                //记录原始标签数据
                weakSelf.originalArray = tempArray.mutableCopy;
                [weakSelf.tableView reloadData];
            }
            else if(state.intValue == 1) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            
        }else {
            
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
        
    }];
    
}

- (void)displayLabelView {

//自动添加标签
    //热搜个数
    NSUInteger wordsNum = _labelArray.count;
    //记录下一个button的起点坐标
    CGFloat buttonOriginX = LeftRightMargin;
    //记录butto距离顶部的高度，以便换行
    CGFloat buttonOriginY = 8;
    
    if (_labelArray.count) {
        
        buttonOriginY = 32;
    }

    //每一行的button的个数标记，跟随button换行数值大小自动对应变化
    int lineNumth = 0;
    
    CGRect frame = _buttonBackgroundView.frame;
    frame.size.height = 0;
    _buttonBackgroundView.frame = frame;
    for (int i = 0; i < wordsNum; i++) {
        
        UILabel *wordButton = [[UILabel alloc] init];
        wordButton.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
        wordButton.layer.cornerRadius = 12.0;
        wordButton.clipsToBounds = YES;
        wordButton.tag = i;
        ThemeLabelForSearchModel *model = _labelArray[i];
        NSString *textStr = model.name;
        textStr = [NSString stringWithFormat:@"  %@",textStr];
        CGFloat buttonWidth = [self getSizeWithText:textStr].width;
        [_buttonBackgroundView addSubview:wordButton];

        //第i个button（注意从第0个开始）说明有i＋1个button，button之间有i个间隙,(i-lineNumth)中lineNumth为上一行最后一个button的位置标签，防换行冲突
        if ( buttonWidth < (SCREEN_WIDTH - LeftRightMargin*2 - (i-lineNumth)*BetweenMargin-50)) {
            
            //i*BetweenMargin 该button前的空隙宽度
            //BetweenMargin该button后的间隙
            if (buttonOriginX >= (SCREEN_WIDTH - LeftRightMargin*2 - (i-lineNumth)*BetweenMargin-50)) {
                lineNumth = i;
                buttonOriginX = LeftRightMargin;
                buttonOriginY += TopMargin + ButtonHeight;
            }
            wordButton.frame = CGRectMake(buttonOriginX, buttonOriginY, buttonWidth, ButtonHeight);
            
            //标签上的删除按钮
            UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"match_delete1"]];
            img.tag = i;
            img.layer.cornerRadius = 10;
            img.layer.masksToBounds = YES;
            img.userInteractionEnabled = YES;
            img.frame = CGRectMake(buttonOriginX+buttonWidth - 22, buttonOriginY+4, 16, 16);
            [_buttonBackgroundView addSubview:img];
            //给删除按钮添加手势识别
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleImgTap:)];
            tap.delegate = self;
            [img addGestureRecognizer:tap];
            
            
            buttonOriginX += buttonWidth+BetweenMargin;
            wordButton.text = textStr;
            wordButton.textColor = [UIColor colorWithHexString:@"#424446"];
            wordButton.font = [UIFont systemFontOfSize:12];
        }
    }
    
    CGFloat buttonBgViewHeight = buttonOriginY;
    CGRect buttonBgframe = _buttonBackgroundView.frame;
    
    if (_labelArray.count == 0) {
        
        buttonBgframe.size.height = buttonBgViewHeight-8+35;
        
        _lineView.frame = CGRectMake(0, buttonBgViewHeight-8, SCREEN_WIDTH, 5);
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#EFEFF4"];
        [_buttonBackgroundView addSubview:_lineView];

        
        if (!_themeMutableArr.count) {
            
            _existedAlreadyLabel.text = @"暂无合辑";
        }
        else {
            
            _existedAlreadyLabel.text = @"已有合辑";

        }
        
        _existedAlreadyLabel.frame = CGRectMake(10, buttonBgViewHeight-8 + 10, 150, 20);
        _existedAlreadyLabel.font = [UIFont systemFontOfSize:12];
        _existedAlreadyLabel.textColor = [UIColor colorWithHexString:@"#424446"];
        [_buttonBackgroundView addSubview:_existedAlreadyLabel];

    }
    else {
        
        _existLabel.frame = CGRectMake(10, 0, 150, 20);
        _existLabel.text = @"已经加入的合辑";
        _existLabel.font = [UIFont systemFontOfSize:12];
        _existLabel.textColor = [UIColor colorWithHexString:@"#424446"];
        buttonBgframe.size.height = buttonBgViewHeight+70;
        [_buttonBackgroundView addSubview:_existLabel];
        
        _lineView.frame = CGRectMake(0, buttonBgViewHeight+35, SCREEN_WIDTH, 5);
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#EFEFF4"];
        [_buttonBackgroundView addSubview:_lineView];
        
        _existedAlreadyLabel.frame = CGRectMake(10, buttonBgViewHeight+45 , 150, 20);
        _existedAlreadyLabel.text = @"已有合辑";
        _existedAlreadyLabel.font = [UIFont systemFontOfSize:12];
        _existedAlreadyLabel.textColor = [UIColor colorWithHexString:@"#424446"];
        [_buttonBackgroundView addSubview:_existedAlreadyLabel];
        
    }
    _buttonBackgroundView.frame = buttonBgframe;

    CGRect tableViewFrame = _tableView.frame;
    tableViewFrame.origin.y = CGRectGetMaxY(_buttonBackgroundView.frame);
    _tableView.frame = tableViewFrame;
    
}

#pragma mark - 根据文字长度计算button宽度
- (CGSize) getSizeWithText:(NSString *)text {
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 16, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:style} context:nil].size;
    return CGSizeMake(size.width + 25, 24);
    
}

#pragma mark -- 标签img点击删除事件
- (void)handleImgTap:(UITapGestureRecognizer *)recognizer {
    
    [_labelArray removeObjectAtIndex:recognizer.view.tag];
    
    for (UIView *tempView in _buttonBackgroundView.subviews) {
        
        [tempView removeFromSuperview];
    }
    CGRect frame = _buttonBackgroundView.frame;
    frame.size.height = 0;
    _buttonBackgroundView.frame = frame;

    //刷新标签显示
    [self displayLabelView];
    
    if (_labelArray.count==0) {
        
        CGRect frame = _buttonBackgroundView.frame;
        frame.size.height = 35;
        _buttonBackgroundView.frame = frame;
        
        CGRect tableFrame = _tableView.frame;
        tableFrame.origin.y = CGRectGetMaxY(_buttonBackgroundView.frame);
        _tableView.frame = tableFrame;
    }

}


#pragma mark -搜索主题button事件
- (IBAction)searchThemeButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    SearchForCreateMatchViewController *searchVC = [story instantiateViewControllerWithIdentifier:@"SearchForCreateMatchViewController"];
    searchVC.collectionID = _collectionID;
    searchVC.createLabelDelegate = self;
    
    [self.navigationController pushViewController:searchVC animated:YES];
    
}


#pragma mark -- tableViewDelegate&dataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 59;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ExistingThemeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ExistingThemeTableViewCell"  forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[ExistingThemeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ExistingThemeTableViewCell"];
    }

    SMThemeModel *model = self.themeMutableArr[indexPath.row];
    
    cell.themeDescribeLabel.text = model.desp;
    cell.themeTitleLabel.text = model.title;
    
    [cell.themeImageView sd_setImageWithURL:[NSURL URLWithString:model.image] placeholderImage:[UIImage imageNamed:@"default_1x1"]];
    cell.themeImageView.layer.borderColor = [UIColor colorWithHexString:@"#E5E5E5"].CGColor;
    cell.themeImageView.layer.borderWidth = 0.7;
    
    BOOL isPublished = model.is_publish;
    
    if (isPublished) {
        
        cell.publishStatusLabel.hidden = YES;
    }
    else {
        
        cell.publishStatusLabel.hidden = NO;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _themeMutableArr.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SMThemeModel *model = self.themeMutableArr[indexPath.row];
    
    //根据搭配id or name来区分是否重复
    BOOL shouldReloadLabel = YES;

    if (model.is_publish) {
        
        NSString *newLabelStr = model.ID;

        for (ThemeLabelForSearchModel *tempModel in _labelArray) {
            if ([tempModel.id.stringValue isEqualToString:newLabelStr]) {
                
                shouldReloadLabel = NO;
            }
        }

        for (ThemeLabelForSearchModel *tempModel in _labelArray) {
            
            if ([tempModel.name isEqualToString:model.desp]) {
                
                shouldReloadLabel = NO;
            }
        }
    } else {
        
        NSString *newLabelStr = model.ID;
        
        for (ThemeLabelForSearchModel *tempModel in _labelArray) {
            if ([tempModel.id.stringValue isEqualToString:newLabelStr]) {
                
                shouldReloadLabel = NO;
            }
        }
    }
    
    
    if (shouldReloadLabel) {
        ThemeLabelForSearchModel *newModel = [[ThemeLabelForSearchModel alloc] init];
        newModel.name = model.title;
        newModel.id = [NSNumber numberWithInt:model.ID.intValue];
        
        [_labelArray addObject:newModel];
        
        for (UIView *tempView in _buttonBackgroundView.subviews) {
            
            [tempView removeFromSuperview];
        }
        
        CGRect frame = _buttonBackgroundView.frame;
        frame.size.height = 0;
        _buttonBackgroundView.frame = frame;
        
        //刷新标签显示
        [self displayLabelView];
    }
    else {
        
        [HTUIHelper addHUDToView:self.view withString:@"请不要重复添加" hideDelay:1];
    }
    
}


#pragma mark -- 完成按钮点击事件
#pragma makr --添加新主题到对应的已创建的主题集中去

- (void)navBarButtonAction {
    
    //http://b82.ssrj.com/api/v5/goods/associatethemeitem?collocationId=6031&themeItems=92,1175&token=xxx&appVersion=xxx
    
    NSString *themeIdsString = @"";
    
    for (int i=0; i<_labelArray.count; i++) {
        
        if (i < _labelArray.count-1) {
            
            ThemeLabelForSearchModel *model = _labelArray[i];
            
            themeIdsString = [NSString stringWithFormat:@"%@%@,",themeIdsString,model.id.stringValue];
        
        }
        if (i == _labelArray.count-1) {
            
            ThemeLabelForSearchModel *model = _labelArray[i];
            
            themeIdsString = [NSString stringWithFormat:@"%@%@",themeIdsString,model.id.stringValue];
        }
    }
    
    //将记录标签原始id数据的数组转变成NSString类型
    NSString *originalIdsString = @"";
    for (int i=0; i<_originalArray.count; i++) {
        
        if (i < _originalArray.count-1) {
            
            ThemeLabelForSearchModel *model = _originalArray[i];
            
            originalIdsString = [NSString stringWithFormat:@"%@%@,",originalIdsString,model.id.stringValue];
            
        }
        if (i == _originalArray.count-1) {
            
            ThemeLabelForSearchModel *model = _originalArray[i];
            
            originalIdsString = [NSString stringWithFormat:@"%@%@",originalIdsString,model.id.stringValue];
        }
    }
    
    
    [self sendThemeToExistedThemeSetWithCollocationIds:themeIdsString originalIds:originalIdsString];
    
}


- (void)sendThemeToExistedThemeSetWithCollocationIds:(NSString *)tthemeItemListIds originalIds:(NSString *)originalIds {
    
    __weak __typeof(&*self)weakSelf = self;
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    requestInfo.URLString = [NSString stringWithFormat:@"/b180/api/v1/content/publish/collocation/detail/%@/",_collectionID];
    
    [requestInfo.postParams addEntriesFromDictionary:@{@"collocationId":_collectionID?:@"",@"themeItems":tthemeItemListIds?:@"",@"originalIds":originalIds?:@"",@"appVersion":VERSION}];
    
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        [requestInfo.postParams addEntriesFromDictionary:@{@"token":[RJAccountManager sharedInstance].token}];
    }
    
    [[ZHNetworkManager sharedInstance]postWithRequestInfo:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
                
                NSDictionary *tempModelDic = [responseObject objectForKey:@"data"];
                
                RJHomeItemTypeTwoModel *tempModel = [[RJHomeItemTypeTwoModel alloc] initWithDictionary:tempModelDic error:nil];
                
                if (!tempModel) {
                    
                    tempModel = weakSelf.homeItemTypeTwoModel;
                }
                
                
                if (weakSelf.delegate) {
     
                    
                    if ([weakSelf.delegate isKindOfClass:NSClassFromString(@"HomeViewController")]) {
                        
                        if ([weakSelf.delegate respondsToSelector:@selector(reloadHomeViewCollocationCellDataWithModel:)]) {
                            
                            [weakSelf.delegate reloadHomeViewCollocationCellDataWithModel:tempModel];
                        }
                    }
                    else if ([self.delegate isKindOfClass:NSClassFromString(@"CollectionsViewController")]) {
                        
                        if ([self.delegate respondsToSelector:@selector(reloadCollocationViewCollocationCellDataWithModel:)]) {
                            
                            [self.delegate reloadCollocationViewCollocationCellDataWithModel:tempModel];
                        }
                    }
                    else if ([self.delegate isKindOfClass:NSClassFromString(@"RJUserCentePublishTableViewController")]) {
                        
                        if ([self.delegate respondsToSelector:@selector(reloadCollocationViewCollocationCellDataWithModel:)]) {
                            
                            [self.delegate reloadCollocationViewCollocationCellDataWithModel:tempModel];
                        }
                    }
                    else if ([self.delegate isKindOfClass:NSClassFromString(@"MineThumbupedCollectionsViewController")]) {
                        
                        if ([self.delegate respondsToSelector:@selector(reloadCollocationViewCollocationCellDataWithModel:)]) {
                            
                            [self.delegate reloadCollocationViewCollocationCellDataWithModel:tempModel];
                        }
                    }
                    
                    else {
                        
                        if ([self.delegate respondsToSelector:@selector(reloadCollocationViewCollocationCellDataWithModel:)]) {
                            
                            [self.delegate reloadCollocationViewCollocationCellDataWithModel:tempModel];
                        }
                    }
                }
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25* NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.navigationController popViewControllerAnimated:YES];
                });
                
            }else if (state.intValue == 1){
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:@"msg"] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                
                [alert show];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:2];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.1;
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    
}

@end




//已有合辑列表
@implementation ExistingThemeTableViewCell

- (void)awakeFromNib{
    [super awakeFromNib];
    
    self.publishStatusLabel.layer.cornerRadius = 3;
    self.publishStatusLabel.layer.masksToBounds = YES;
}

@end

