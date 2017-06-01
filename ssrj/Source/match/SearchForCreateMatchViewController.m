//
//  SearchForCreateMatchViewController.m
//  ssrj
//
//  Created by YiDarren on 16/11/8.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "SearchForCreateMatchViewController.h"
#import "CreatNewThemeViewController.h"
//使用合辑model,用于主动搜索合辑
#import "RJHomeItemTypeFourModel.h"



@interface SearchForCreateMatchViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate,CreatNewThemeViewControllerDelegate,UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchViewBg;

@property (weak, nonatomic) IBOutlet UILabel *selfInputLabel;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UITextField *inputTextFeild;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopconstraint;


//搜索结果数组
@property (strong, nonatomic) NSMutableArray *themeListArray;
//输入时下拉框数据数组
@property (strong, nonatomic) NSMutableArray *dropDownBoxArray;

//记录用户是否开启过搜索服务，没有tableViewCell使用themeListArray，只要有过则使用dataArray
@property (assign, nonatomic) BOOL hasSearchTheme;


@end

@implementation SearchForCreateMatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBackButton];
    if (_searchViewBg.superview) {
        _searchViewBg.superview.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    }
    self.title = @"搜索合辑";
    
    //进入搜索合辑UI尚未开启过搜索功能
    _hasSearchTheme = NO;
    
    _themeListArray = [NSMutableArray array];
    _dropDownBoxArray = [NSMutableArray array];
    
    //添加输入改变方法
    [_inputTextFeild addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
    
    _searchViewBg.layer.cornerRadius = 5.0;
    _searchViewBg.layer.masksToBounds = YES;
    
    _createButton.hidden = YES;
    //tableView在没有使用搜索功能的时候挡住selfInputLabel
    _tableViewTopconstraint.constant = 44;
    
    __weak __typeof(&*self)weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
       
        [weakSelf getThemeTitleData];
    }];
    
    [self.tableView.mj_header beginRefreshing];
    /**
     *  收回键盘事件
     */
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark -创建新合辑代理刷新
- (void)reloadExitedThemeDataWithDic:(NSDictionary *)dic {
    
//    通知上级UI更新网络数据
//    NSDictionary *dic = @{@"name":_themeTitleText.text, @"describe":_themeDescribeText.text, @"isPublish":_buttonOn.stringValue};
    
    ThemeLabelForSearchModel *model = [[ThemeLabelForSearchModel alloc] init];
    model.id = [dic objectForKey:@"id"];
    model.name = [dic objectForKey:@"name"];
    model.isPublish = [dic objectForKey:@"isPublish"];

    
//    [HTUIHelper addHUDToView:self.view withString:@"创建新合辑" hideDelay:1];
    
    if (self.createLabelDelegate) {
        
        if ([self.createLabelDelegate isKindOfClass:NSClassFromString(@"GetToThemeViewController")]) {
            
            if ([self.createLabelDelegate respondsToSelector:@selector(reloadLabelDataWithModel:)]) {
                
                [self.createLabelDelegate reloadLabelDataWithModel:model];
            }
        }
    }

    
    
}


#pragma mark -- 获取已有合辑列表数组（id & name）方法
- (void)getThemeTitleData{
    
    ZHRequestInfo *requestInfo = [ZHRequestInfo new];
    
    
    NSString *urlStr = [NSString stringWithFormat:@"/b180/api/v1/goodsinfor/theme?pagenum=1&pagesize=200000"];
    
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    requestInfo.URLString = urlStr;

    __weak __typeof(&*self)weakSelf = self;
    [[ZHNetworkManager sharedInstance]getWithRequestInfoWithoutModel:requestInfo success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject objectForKey:@"state"]) {
            NSNumber *number = [responseObject objectForKey:@"state"];
            if (number.boolValue == 0) {
                NSArray *itemList = responseObject[@"data"];
                
                [weakSelf.themeListArray removeAllObjects];
                
                NSMutableArray *tempArray = [NSMutableArray array];
                
                for (NSDictionary *dic in itemList) {
                    ThemeLabelForSearchModel *model = [[ThemeLabelForSearchModel alloc]initWithDictionary:dic error:nil];
                    if (model) {
                        
                        [tempArray addObject:model];
                    }
                }
                weakSelf.themeListArray = tempArray.mutableCopy;
                
                [weakSelf.tableView reloadData];
            }else{
                [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            }
        }else{
            [HTUIHelper addHUDToView:self.view withString:[responseObject objectForKey:@"msg"] hideDelay:1];
            
        }
        [weakSelf.tableView.mj_header endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [HTUIHelper addHUDToView:self.view withString:@"Error" hideDelay:1];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

#pragma mark -- 取消按钮button点击事件
- (IBAction)cancelButtonAction:(id)sender {
    
    if ([_inputTextFeild isFirstResponder]) {
        [_inputTextFeild resignFirstResponder];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark -- 创建主题button点击事件
- (IBAction)createThemeButtonAction:(id)sender {
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Darren" bundle:nil];
    
    CreatNewThemeViewController *createNewVC = [story instantiateViewControllerWithIdentifier:@"CreatNewThemeViewController"];
    //传入主题名称
    if (!_inputTextFeild.text.length) {
        
        createNewVC.themeName = _selfInputLabel.text;
    }
    createNewVC.themeName = _inputTextFeild.text;
    createNewVC.creatThemeID = _collectionID;
    createNewVC.isFromCreateCollection = self.isFromCreateCollection;
    createNewVC.delegate = self;
    [self.navigationController pushViewController:createNewVC animated:YES];
    
}


#pragma mark -- UITextFieldDelegate &dataSource
#pragma mark - 添加用来监测字符变动的方法
- (void)textFieldEditChanged:(UITextField *)textField {
    
    [_dropDownBoxArray removeAllObjects];
    
    NSMutableArray *tempArray = [NSMutableArray array];
        
    for (ThemeLabelForSearchModel *model in _themeListArray) {
            
        NSRange range = [model.name rangeOfString:textField.text options:NSCaseInsensitiveSearch];
            
        if (range.length) {
                
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:model.name];
                
            [attribute addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17]} range:range];
                
            [tempArray addObject:attribute];
                
        }
    }
        
    NSArray *arr = [tempArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
           
        NSMutableAttributedString *attribute1 = obj1;
        NSMutableAttributedString *attribute2 = obj2;
            
        NSRange range1 = [attribute1.string rangeOfString:textField.text options:NSCaseInsensitiveSearch];
        NSRange range2 = [attribute2.string rangeOfString:textField.text options:NSCaseInsensitiveSearch];
        NSComparisonResult result = [[NSNumber numberWithInteger:range1.location] compare:[NSNumber numberWithInteger:range2.location]];
            
        return result;
    }];
        
    [_dropDownBoxArray addObjectsFromArray:arr];
        
    [self.tableView reloadData];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (_inputTextFeild.text.length==0) {
        [HTUIHelper addHUDToView:self.view withString:@"请输入查找的合辑名称" hideDelay:1];

        return NO;
    }
    else {
        //记录用户是否开启过搜索服务，没有tableViewCell使用themeListArray，只要有过则使用dataArray
        _hasSearchTheme = YES;
        
        _tableViewTopconstraint.constant = 96;
        
        _selfInputLabel.text = _inputTextFeild.text;
        _createButton.hidden = NO;
        [_createButton setTitle:@"创建" forState:UIControlStateNormal];
        
        
        /**
         *  检测完全匹配
         */
        BOOL isTheSameWithInputWord = NO;
        
        for (int i=0; i<_themeListArray.count; i++) {
            
            ThemeLabelForSearchModel *model = _themeListArray[i];
            
            NSString *inputWord = model.name;
            if ([textField.text isEqualToString:inputWord]) {
                
                isTheSameWithInputWord = YES;
            }
        }

        if (isTheSameWithInputWord) {
            
            //有完全匹配项，tableView上移，遮挡住inputTextField
            _tableViewTopconstraint.constant = 45;
        }
        else {
            
            //没有完全匹配项，tableView下移，显示inputTextField可创建新主题
            _tableViewTopconstraint.constant = 96;
        }
        
        if ([_inputTextFeild isFirstResponder]) {
            
            [_inputTextFeild resignFirstResponder];
            
        }
        
        //TODO: 搜索输入框内的主题,做匹配
        
        return YES;
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



#pragma mark -- UITableVivewDelegate&DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_dropDownBoxArray.count != 0) {
        
        return _dropDownBoxArray.count;
    }
    else {
        
        return self.themeListArray.count;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    if (_dropDownBoxArray.count != 0) {
        
        cell.textLabel.attributedText = self.dropDownBoxArray[indexPath.row];
    }
    else {
        
        ThemeLabelForSearchModel *model = self.themeListArray[indexPath.row];
        cell.textLabel.text = model.name;
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ThemeLabelForSearchModel *model = [[ThemeLabelForSearchModel alloc] init];
    
    if (_dropDownBoxArray.count != 0) {
        
        NSAttributedString *nameAttString = self.dropDownBoxArray[indexPath.row];
        
        for (ThemeLabelForSearchModel *searchModel in _themeListArray) {
            
            if ([nameAttString.string isEqualToString:searchModel.name]) {
                
                model = searchModel;
            }
        }
    }
    else {
        
        model = self.themeListArray[indexPath.row];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        //TODO:代理向上级传值刷新
        if ([self.createLabelDelegate respondsToSelector:@selector(reloadLabelDataWithModel:)]) {
            
            [self.createLabelDelegate reloadLabelDataWithModel:model];
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    });
    
    

}



-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    
    if ([_inputTextFeild isFirstResponder]) {
        [_inputTextFeild resignFirstResponder];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([_inputTextFeild isFirstResponder]) {
        [_inputTextFeild resignFirstResponder];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}




@end
