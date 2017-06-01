//
//  HHInforDraftController.m
//  ssrj
//
//  Created by 夏亚峰 on 16/12/14.
//  Copyright © 2016年 ssrj. All rights reserved.
//

#import "HHInforDraftController.h"
#import "HHTextAttachment.h"
#import "HHInformationViewController.h"
#import "HHInforDraftCell.h"
#import "Masonry.h"
@interface HHInforDraftController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,assign)BOOL isEditState;
@end

@implementation HHInforDraftController
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [MobClick beginLogPageView:@"创建资讯-草稿页面"];
    [TalkingData trackPageBegin:@"创建资讯-草稿页面"];
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [MobClick endLogPageView:@"创建资讯-草稿页面"];
    [TalkingData trackPageEnd:@"创建资讯-草稿页面"];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configNav];
    [self configTableView];
}
- (void)configNav {
    [self addBackButton];
    [self setTitle:@"资讯草稿" tappable:NO];
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonClink:)];
    self.navigationItem.rightBarButtonItem = btn;
}
- (void)configTableView {
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self reloadData];
}
#pragma mark - 点击编辑
- (void)editButtonClink:(UIBarButtonItem *)item {
    _isEditState = !_isEditState;
    if (_isEditState) {
        item.title = @"取消";
    }else {
        item.title = @"编辑";
    }
    [self.tableView reloadData];
}
#pragma mark - 获取数据
- (void)reloadData {
    _dataArray = [self getRichTextModels];
    [self.tableView reloadData];
}
- (NSArray *)getRichTextModels {
    //创建文件夹
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentsDir stringByAppendingPathComponent:@"information_draft"];
    NSString *file = [filePath stringByAppendingPathComponent:@"richText.txt"];
    
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    if (array && array.count) {
        return array;
    }
    return nil;
}
#pragma mark - delegate 

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HHInforDraftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[HHInforDraftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.model = self.dataArray[indexPath.row];
    cell.isShowDeleteBtn = _isEditState;
    __weak __typeof(&*self)weakSelf = self;
    cell.deleteBlock = ^{
        
        [[HTUIHelper shareInstance] addHUDToView:weakSelf.view withString:nil xOffset:0 yOffset:0];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *array = [weakSelf getRichTextModels];
            NSMutableArray *arr = [NSMutableArray arrayWithArray:array];
            [arr removeObjectAtIndex:indexPath.row];
            
            NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *filePath = [documentsDir stringByAppendingPathComponent:@"information_draft"];
            NSString *file = [filePath stringByAppendingPathComponent:@"richText.txt"];
            BOOL isSaved = [NSKeyedArchiver archiveRootObject:arr toFile:file];
            if (isSaved) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [[HTUIHelper shareInstance] removeHUD];
                    [weakSelf reloadData];
                });
            }else {dispatch_sync(dispatch_get_main_queue(), ^{
                [[HTUIHelper shareInstance] removeHUD];
                [HTUIHelper addHUDToView:weakSelf.view withString:@"删除失败" hideDelay:0.3];
            });
            }
            
        });
        
        
    };
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScreenWidth / 16.0 * 9;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HHInforDraftModel *model = self.dataArray[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectDraftWithModel:)]) {
        [self.delegate didSelectDraftWithModel:model];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)attributeStringFromHtmlString:(NSString *)htmlString {
    
    NSMutableAttributedString * htmlAttributeString = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    
    
    [htmlAttributeString enumerateAttributesInRange:NSMakeRange(0, htmlAttributeString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSString *,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSTextAttachment * textAtt = attrs[@"NSAttachment"];//从字典中取得那一个图片
        if (textAtt){
            
        }
    }];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
