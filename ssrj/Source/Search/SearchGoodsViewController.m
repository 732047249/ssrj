//
//  SearchGoodsViewController.m
//  ssrj
//
//  Created by YiDarren on 16/9/6.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SearchGoodsViewController.h"
#import "SearchHotWordsModel.h"
#import "SearchDetailViewController.h"
#import "NSString+Additions.h"

#define LeftRightMargin 20
#define BetweenMargin  8
#define TopMargin  15
#define ButtonHeight 24

//搜索用户未登录情况下创建的唯一标识符的安全加强随机数
#define RandomKey @"pze0NG46xD8DwGGAEhC72COyvZIAVkqX"

@interface SearchGoodsViewController ()<UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIView *textFieldBgView;
@property (weak, nonatomic) IBOutlet UITextField *searchText;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UITableView *searchResult;
@property (strong, nonatomic) UILabel *footerLabel;
@property (assign, nonatomic) BOOL isSearchResultShow;
@property (assign, nonatomic) int pageNumber;

//热门搜索
@property (strong, nonatomic) NSMutableArray *hotArray;
//历史记录
@property (strong, nonatomic) NSMutableArray *hisArray;
//索引数据（依输入变动）
@property (strong, nonatomic) NSMutableArray *indexArray;
//索引库数据
@property (strong, nonatomic) NSMutableArray *totalIndexArray;
//用户唯一标识,用于加盐
@property (strong, nonatomic) NSString *stringMD5ID;

@end

@implementation SearchGoodsViewController
- (IBAction)cancelButtonAction:(UIButton *)sender {
    if (!sender.trackingId.length) {
        sender.trackingId = [NSString stringWithFormat:@"%@&cancelButton",NSStringFromClass([self class])];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [MobClick beginLogPageView:@"搜索输入页面"];
    [TalkingData trackPageBegin:@"搜索输入页面"];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"搜索输入页面"];
    [TalkingData trackPageEnd:@"搜索输入页面"];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNumber = 0;
    _searchText.layer.cornerRadius = 5.0;
    _searchText.layer.masksToBounds = YES;
    
    //添加输入改变方法
    [_searchText addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    
    _textFieldBgView.layer.cornerRadius = 5.0;
    _textFieldBgView.layer.masksToBounds = YES;
    
    _hotArray = [NSMutableArray array];
    _hisArray = [NSMutableArray array];
    _indexArray = [NSMutableArray array];
    _totalIndexArray = [NSMutableArray array];
    
    //创建用户唯一标识ID   加盐！！！
    _stringMD5ID = [self MD5Change];
    
    _searchResult = [[UITableView alloc] initWithFrame:CGRectMake(0, 63, SCREEN_WIDTH, SCREEN_HEIGHT-63) style:UITableViewStylePlain];
    _searchResult.delegate = self;
    _searchResult.dataSource = self;
    _searchResult.backgroundColor = [UIColor colorWithHexString:@"#EFEFF4"];
    
    self.tableView.tableHeaderView = _headerView;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       
        [self getCacheHotWordsData];
        [self getHistoryWordsData];
        [self getCacheNetIndexData];

    }];
    [self.tableView.mj_header beginRefreshing];
    
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    tapGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapGestureRecognizer];

    self.searchText.trackingId = [NSString stringWithFormat:@"%@&searchText",NSStringFromClass([self class])];
}

#pragma mark - 删除所有历史搜索数据接口
- (void)deleteHistoryWordsData {
    
    __weak typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v1/search/deletehistory/?machineid=%@",_stringMD5ID];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *TempArray = [responseObject objectForKey:@"data"];
                
                [weakSelf.hisArray removeAllObjects];
                //历史搜索数据
                weakSelf.hisArray = TempArray.mutableCopy;
                
                [weakSelf.tableView reloadData];
            }
            else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];

}


#pragma mark - 保存历史搜索数据接口
- (void)saveHistoryWordsDataWithString:(NSString *)searchStr {
    
        __weak typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v1/search/savehistory/?machineid=%@&searchkey=%@",_stringMD5ID, searchStr];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *TempArray = [responseObject objectForKey:@"data"];
                
                [weakSelf.hisArray removeAllObjects];
                //历史搜索数据
                weakSelf.hisArray = TempArray.mutableCopy;
                
                [weakSelf.tableView reloadData];
            }
            else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
            }
            
        }
        else {
            [HTUIHelper addHUDToView:self.view withString:responseObject[@"msg"] hideDelay:1];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
}


#pragma mark - 获取历史搜索数据
- (void)getHistoryWordsData {
    
    __weak typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v1/search/gethistory/?machineid=%@",_stringMD5ID];
    
    requestInfo.URLString = urlStr;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *TempArray = [responseObject objectForKey:@"data"];
                
                [weakSelf.hisArray removeAllObjects];
                //历史搜索数据
                weakSelf.hisArray = TempArray.mutableCopy;
                
                [weakSelf.tableView reloadData];
            }
            else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            
        }
        else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
}


#pragma mark - 获取网络热词，缓存接口
- (void)getCacheHotWordsData {
    
    __weak typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/hotwords/?pagenum=0&pagesize=10&hotwordstype=0"];
    
    requestInfo.URLString = urlStr;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *TempArray = [responseObject objectForKey:@"data"];
                
                [weakSelf.hotArray removeAllObjects];
                //热搜
                weakSelf.hotArray = TempArray.mutableCopy;
                
                [self hotWordsDisplay];
                [weakSelf.tableView reloadData];
            }
            else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            
        }
        else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
}

//搜索下拉框数据接口
#pragma mark - 搜索下拉框数据接口，缓存接口
- (void)getCacheNetIndexData {
    
    _pageNumber = 0;
    __weak typeof (&*self)weakSelf = self;
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    //请求索引数据需要一次性获取所有数据，便于用户搜索时给出全部相关产品，此处取值2000（实际取1930）获取全部索引数据，故不会跳转至分页功能代码
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v2/search/hotwords/?pagenum=%d&pagesize=20000&hotwordstype=1",_pageNumber];
    
    requestInfo.URLString = urlStr;
    [[ZHNetworkManager sharedInstance] getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject objectForKey:@"state"]) {
            
            NSNumber *state = [responseObject objectForKey:@"state"];
            
            if (state.intValue == 0) {
                
                NSArray *TempArray = [responseObject objectForKey:@"data"];
                
                _pageNumber++;
                
                [weakSelf.totalIndexArray removeAllObjects];
                
                //下拉框
                weakSelf.totalIndexArray = TempArray.mutableCopy;
                
                [weakSelf.searchResult reloadData];
            }
            else if (state.intValue == 1){
                
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
            
        }
        else {
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
        }
        
        [weakSelf.searchResult.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [weakSelf.searchResult.mj_header endRefreshing];
        [HTUIHelper addHUDToView:self.view withString:[error localizedDescription] hideDelay:1];
        
    }];
    
}



#pragma mark - 热词自动显示
- (void)hotWordsDisplay {
    //热搜个数
    NSUInteger wordsNum = _hotArray.count;
    //记录下一个button的起点坐标
    CGFloat buttonOriginX = LeftRightMargin;
    //记录butto距离顶部的高度，以便换行
    CGFloat buttonOriginY = 40;
    //每一行的button的个数标记，跟随button换行数值大小自动对应变化
    int lineNumth = 0;
    for (UIView *subView in _headerView.subviews) {
        if ([subView isMemberOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    for (int i = 0; i < wordsNum; i++) {
        
        UIButton *wordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        wordButton.layer.cornerRadius = 12.0;
        wordButton.layer.borderColor = [UIColor colorWithHexString:@"#4919A6"].CGColor;
        wordButton.layer.borderWidth = 1;
        wordButton.clipsToBounds = YES;
        wordButton.tag = i;
        NSString *textStr = _hotArray[i];
        
        CGFloat buttonWidth = [self getSizeWithText:textStr].width;
        
        //第i个button（注意从第0个开始）说明有i＋1个button，button之间有i个间隙,(i-lineNumth)中lineNumth为上一行最后一个button的位置标签，防换行冲突
        if ( buttonWidth < (SCREEN_WIDTH - LeftRightMargin*2 - (i-lineNumth)*BetweenMargin)) {

            //i*BetweenMargin 该button前的空隙宽度
            //BetweenMargin该button后的间隙
            if (buttonOriginX >= (SCREEN_WIDTH - LeftRightMargin*2 - (i-lineNumth)*BetweenMargin)) {
                lineNumth = i;
                buttonOriginX = LeftRightMargin;
                buttonOriginY += TopMargin + ButtonHeight;
            }
            wordButton.frame = CGRectMake(buttonOriginX, buttonOriginY, buttonWidth, ButtonHeight);
            
            buttonOriginX += buttonWidth+BetweenMargin;
            
            [wordButton setTitle:textStr forState:UIControlStateNormal];
            
            [wordButton setTitleColor:[UIColor colorWithHexString:@"#4919A6"] forState:UIControlStateNormal];
            
            [wordButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            
            wordButton.backgroundColor = [UIColor whiteColor];
            /**
             *  统计ID
             */
            wordButton.trackingId = [NSString stringWithFormat:@"%@&hotWord&%@",NSStringFromClass(self.class),textStr];
            [_headerView addSubview:wordButton];
            
        }
        
        [wordButton addTarget:self action:@selector(wordButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    CGFloat headerHeight = buttonOriginY + 24 + TopMargin;
    _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, headerHeight);
    self.tableView.tableHeaderView = _headerView;
    
}


#pragma mark - 根据文字长度计算button宽度
- (CGSize)getSizeWithText:(NSString *)text {
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineBreakMode = NSLineBreakByCharWrapping;
    CGSize size = [text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 75, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:style} context:nil].size;
    return CGSizeMake(size.width + 25, 24);
    
}


#pragma mark - 热搜词点击跳转 & 历史数据记录
- (void)wordButtonTouched:(UIButton *)sender {
    
    /**
     *  存点击的历史搜索数据.
     */
    
    //不在本地存，后台处理，注意需去重
    //[_hisArray addObject:sender.titleLabel.text];
    
    [self saveHistoryWordsDataWithString:sender.titleLabel.text];
    
    //跳转至搜索详情页面
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    SearchDetailViewController *searchDetailVC = [story instantiateViewControllerWithIdentifier:@"SearchDetailViewController"];
    searchDetailVC.searchWords = sender.titleLabel.text;
    
    [self.navigationController pushViewController:searchDetailVC animated:YES];

}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (!textField.trackingId.length) {
        return;
    }
    [[RJAppManager sharedInstance]trackingWithTrackingId:textField.trackingId];
    
}


#pragma mark - 添加用来监测字符变动的方法
- (void)textFieldEditChanged:(UITextField *)textField {
    
    //索引列表刷新
    [_indexArray removeAllObjects];
    
    if (!textField.text.length) {
        
        [self.searchResult removeFromSuperview];
        _isSearchResultShow = NO;
        [self.tableView reloadData];
    }
    else {
        
        if (!_isSearchResultShow) {
            
            [self.view addSubview:_searchResult];
        }
        
        NSMutableArray *tempFilterArray = [NSMutableArray array];
        
        for (NSString *allStr in self.totalIndexArray) {
            
            NSRange range = [allStr rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            
            if (range.length) {
                
                NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:allStr];
                
                [attribute addAttributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:17]} range:range];
                
                [tempFilterArray addObject:attribute];
            }
        }
        
        NSArray *arr = [tempFilterArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            NSMutableAttributedString *attribute1 = obj1;
            NSMutableAttributedString *attribute2 = obj2;
            NSRange range1 = [attribute1.string rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            
            NSRange range2 = [attribute2.string rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            NSComparisonResult result = [[NSNumber numberWithInteger:range1.location] compare:[NSNumber numberWithInteger:range2.location]] ;
            return result;
        }];
        
        [_indexArray addObjectsFromArray:arr];
        
        [self.searchResult reloadData];
        
    }
    

}

#pragma mark - 监测输入文本是否为汉字
- (BOOL)isIncludeChineseInString:(NSString *)str {
    
    for (int i=0; i<str.length; i++) {
        unichar ch = [str characterAtIndex:i];
        if (0x4e00 < ch && ch < 0x9fff) {
            
            return true;
        }
    }
    return false;
}


#pragma mark - 输入框开始编辑，索引列表弹出
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    _isSearchResultShow = YES;

    [self.view addSubview:_searchResult];

    return YES;
}

#pragma mark - UITextField的事件，用来监测字符变动
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    NSString *inputWords = textField.text;
    
    //判断输入内容是否为空格
    if ([self isBlankString:inputWords]) {
        
        return NO;
    }
    
    //去除输入内容开头空格
    inputWords = [self deleteBeginBlankWithString:inputWords];
    
    if (inputWords.length) {
        //保存历史搜索
        [self saveHistoryWordsDataWithString:inputWords];
        
        //跳转至搜索详情页面
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
        
        SearchDetailViewController *searchDetailVC = [story instantiateViewControllerWithIdentifier:@"SearchDetailViewController"];
        //传值搜索关键词
        searchDetailVC.searchWords = inputWords;
        [self.navigationController pushViewController:searchDetailVC animated:YES];
    }

    return YES;
}

//TODO:去除输入内容开头空格
#pragma mark -- 去除输入内容开头空格
- (NSString *)deleteBeginBlankWithString:(NSString *)string {
    
    
    return string;
}

#pragma mark -- 判断输入内容是否为空格
- (BOOL)isBlankString:(NSString *)string {
    
    if (string == nil) {
        return YES;
    }
    
    if (string == NULL) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;


}

#pragma mark -- 加盐
#pragma mark -- MD5加密
- (NSString *)MD5Change {
 
    
    //需要编码的字符串
    NSString *identifierString = [[NSUserDefaults standardUserDefaults] objectForKey:SearchIdentifierKey];
    
    //用户登陆，使用手机号
    if ([[RJAccountManager sharedInstance]hasAccountLogin]) {
        
        identifierString = [NSString stringWithFormat:@"%@", [RJAccountManager sharedInstance].account.userid];
        
        identifierString = [identifierString stringFromMD5];
        
    }
    //用户未登录，使用本地唯一标识符 SearchIdentifierKey
    else {
        
        //未登录，第一次搜索，设置用户唯一标识并保存在本地
        if (!identifierString) {
            
            //时间戳
            NSDate *timesp = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval timeIntrl = [timesp timeIntervalSince1970];
            NSString *timeString = [NSString stringWithFormat:@"%f", timeIntrl];
            timeString = [timeString stringFromMD5];
        
            
            //TODO:存储文件
            NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            //每个应用程序只有一个路径，所以说我们可以从数组的0位置取得路径
            NSString *documentDirectory=[path objectAtIndex:0];
            
            //在获得的路径当中生成一个theFile.txt文件，filename将包含theFile.txt的完整路径
            NSString *filename=[documentDirectory stringByAppendingPathComponent:@"SearchIdentifierKey.txt"];
            
            [timeString  writeToFile:filename atomically:YES];
            
        }
        //未登录，搜索过且有用户唯一标识,直接取该唯一标识
        else {
            
            //取值存储的文件
            NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *documentdirectory=[paths objectAtIndex:0];
            NSString *filename=[documentdirectory stringByAppendingPathComponent:@"SearchIdentifierKey.txt"];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath: documentdirectory]) {
                
                identifierString = [[NSString alloc] initWithContentsOfFile:filename encoding:NSUTF8StringEncoding error:nil];
            }
        }
        
        identifierString = [NSString stringWithFormat:@"%@",identifierString];
    }
    
    return identifierString;
}


#pragma mark -- UITableView
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {

    return [[UIView alloc] initWithFrame:CGRectZero];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == _tableView) {
        
        if (_hisArray.count) {
            return 2;
        }
        else {
            return 1;
        }

    }
    else {
        
        return 1;
    }
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == _tableView) {
        
        return 30;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (tableView == _tableView) {
        
        if (section == 1) {
            
            return 30;
        }
        return 0.1;
    }
    
    return 1;//和footerLabel等高
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableView) {
        
        if (section == 0) {
            
            return _hisArray.count;
        }
        else {
            if (_hisArray.count) {
                
                return 1;//清除搜索记录cell
            }
            else {
                return 0;
            }
        }
    }
    else {
        
        if (!_indexArray.count) {
                
            return _totalIndexArray.count;
        }
        else {
            
            return _indexArray.count;
        }
    }

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _tableView) {
        
        /**
         *  清空历史数据
         */

        //清除按钮（_tableView的section＝0）
        if (indexPath.section == 1) {
            
            [self deleteHistoryWordsData];
            return;
        }
        else {
            
            [self saveHistoryWordsDataWithString:_hisArray[indexPath.row]];
        }
        
        //跳转至搜索详情页面
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
        
        SearchDetailViewController *searchDetailVC = [story instantiateViewControllerWithIdentifier:@"SearchDetailViewController"];
        searchDetailVC.searchWords = _hisArray[indexPath.row];
        
        [self.navigationController pushViewController:searchDetailVC animated:YES];
    }
    //索引列表tableView
    else {
        
        //点击searchResult cell
        //跳转至搜索详情页面
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
        
        SearchDetailViewController *searchDetailVC = [story instantiateViewControllerWithIdentifier:@"SearchDetailViewController"];
        
        if (!_indexArray.count) {
                
            //检验searchWords取值是否为空
            if (!_totalIndexArray[indexPath.row]) {
                    
                return;
            }
            else {
                    
                searchDetailVC.searchWords = _totalIndexArray[indexPath.row];
                [self saveHistoryWordsDataWithString:_totalIndexArray[indexPath.row]];
            }
                
        }
        else {
                
            searchDetailVC.searchWords = [_indexArray[indexPath.row] string];
            [self saveHistoryWordsDataWithString:[_indexArray[indexPath.row] string]];
        }
        
        [self.navigationController pushViewController:searchDetailVC animated:YES];
    }
    
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (tableView == _tableView) {
        
        if (indexPath.section == 0) {
            
            cell.textLabel.text = _hisArray[indexPath.row];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.textColor = [UIColor blackColor];
            cell.textLabel.font = [UIFont systemFontOfSize:17];
        }
        
        else {
            
            cell.textLabel.text = @"清空历史记录";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor lightGrayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:15];
        }

    }
    else {
        
        if (!_indexArray.count) {
                
            cell.textLabel.text = _totalIndexArray[indexPath.row];
        }
        else {
                
            cell.textLabel.attributedText = _indexArray[indexPath.row];
        }

    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == _tableView) {
        
        if (_hisArray.count) {
            
            if (section == 0) {
                return @"搜索记录";
            }
            else {
                return nil;
            }
        }
        else {
            
            return nil;
        }
    }
    else {
        
        return nil;
    }
    
}

#pragma mark -touches
-(void)keyboardHide:(UITapGestureRecognizer*)tap{

    if ([_searchText isFirstResponder]) {
        [_searchText resignFirstResponder];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([_searchText isFirstResponder]) {
        [_searchText resignFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}


@end
